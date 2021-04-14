import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    print(app.directory.publicDirectory)
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // use leaf
    app.views.use(.leaf)

    // register routes
    try routes(app)

    // Cconnection string for database (mongo)

    try app.initializeMongoDB(connectionString: app.mongDBConnectionString)

    // seed test data
    try createTestingUsers(inDatabase: app.mongoDB)
}
