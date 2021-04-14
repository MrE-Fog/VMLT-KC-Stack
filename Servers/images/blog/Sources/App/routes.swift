//    Copyright (c) 2020 Razeware LLC
//
//    Permission is hereby granted, free of charge, to any person
//    obtaining a copy of this software and associated documentation
//    files (the "Software"), to deal in the Software without
//    restriction, including without limitation the rights to use,
//    copy, modify, merge, publish, distribute, sublicense, and/or
//    sell copies of the Software, and to permit persons to whom
//    the Software is furnished to do so, subject to the following
//    conditions:
//
//    The above copyright notice and this permission notice shall be
//    included in all copies or substantial portions of the Software.
//
//    Notwithstanding the foregoing, you may not use, copy, modify,
//    merge, publish, distribute, sublicense, create a derivative work,
//    and/or sell copies of the Software in any work that is designed,
//    intended, or marketed for pedagogical or instructional purposes
//    related to programming, coding, application development, or
//    information technology. Permission for such use, copying,
//    modification, merger, publication, distribution, sublicensing,
//    creation of derivative works, or sale is expressly withheld.
//
//    This project and source code may use libraries or frameworks
//    that are released under various Open-Source licenses. Use of
//    those libraries and frameworks are governed by their own
//    individual licenses.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//    NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//    DEALINGS IN THE SOFTWARE.

import Vapor
import MongoKitten
import JWTKit

struct HomepageContext: Codable {
    let posts: [ResolvedTimelinePost]
    let suggestedUsers: [User]
}

func routes(_ app: Application) throws {
    app.get { request -> EventLoopFuture<View> in
        // Get the "socialbird" cookie's string value
        guard let token = request.cookies["socialbird"]?.string else {
            return request.view.render("login")
        }
        
        let accessToken = try request.application.jwt.verify(token, as: AccessToken.self)
        
        let posts = Repository.getFeed(
            forUser: accessToken.subject,
            inDatabase: request.mongoDB
        )
            
        let suggestedUsers = Repository.findSuggestedUsers(
            forUser: accessToken.subject,
            inDatabase: request.mongoDB
        )
            
        return posts.and(suggestedUsers).flatMap { posts, suggestedUsers in
            let context = HomepageContext(
                posts: posts,
                suggestedUsers: suggestedUsers
            )
            
            return request.view.render("index", context)
        }
    }
    
    app.post("login") { request -> EventLoopFuture<Response> in
        let credentials = try request.content.decode(Credentials.self)
        
        return Repository.findUser(
            byUsername: credentials.username,
            inDatabase: request.mongoDB
        ).flatMap { user -> EventLoopFuture<Response> in
            do {
                guard
                    let user = user,
                    try user.credentials.matchesPassword(credentials.password)
                else {
                    return request.view.render("login", [
                        "error": "Incorrect credentials"
                    ]).flatMap { view in
                        return view.encodeResponse(for: request)
                    }
                }
                
                let accessToken = AccessToken(subject: user)
                let token = try request.application.jwt.sign(accessToken)
                
                let response = request.redirect(to: "/")
                var cookie = HTTPCookies.Value(string: token)
                cookie.expires = accessToken.expiration.value
                response.cookies["socialbird"] = cookie
                return request.eventLoop.makeSucceededFuture(response)
            } catch {
                return request.eventLoop.makeFailedFuture(error)
            }
        }
    }
    
    app.group(AuthenticationMiddleware()) { authenticated in
        authenticated.post("post") { request -> EventLoopFuture<Response> in
            guard let accessToken = request.accessToken else {
                return request.eventLoop.makeSucceededFuture(request.redirect(to: "/"))
            }
            
            let createdPost = try request.content.decode(CreatePost.self)
            let post = TimelinePost(
                _id: ObjectId(),
                text: createdPost.text,
                creationDate: Date(),
                creator: accessToken.subject
            )
            
            // Insert the newly created post into MongoDB
            return request.mongoDB[TimelinePost.collection].insertEncoded(post).map { _ in
                return request.redirect(to: "/")
            }
        }
        
        authenticated.get("follow", ":userId") { request -> EventLoopFuture<Response> in
            guard
                let userId = request.parameters.get("userId", as: ObjectId.self),
                let accessToken = request.accessToken,
                userId != accessToken.subject
            else {
                return request.eventLoop.makeSucceededFuture(request.redirect(to: "/"))
            }
            
            return Repository.findUser(byId: userId, inDatabase: request.mongoDB).flatMap { otherUser in
                return Repository.findUser(byId: accessToken.subject, inDatabase: request.mongoDB).flatMap { currentUser in
                    return Repository.followUser(otherUser, fromAccount: currentUser, inDatabase: request.mongoDB)
                }
            }.map { _ in
                return request.redirect(to: "/")
            }
        }
    }
}
