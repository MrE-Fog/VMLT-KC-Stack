// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "blog",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        // 2
        .package(url: "https://github.com/vapor/vapor.git", from: "4.41.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.1.0"),

        // 3
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.0.0"),
        .package(url: "https://github.com/OpenKitten/MongoKitten.git", from: "6.6.0"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
              .product(name: "Vapor", package: "vapor"),
              
              //4
              .product(name: "Leaf", package: "leaf"),
              .product(name: "JWTKit", package: "jwt-kit"),
              .product(name: "MongoKitten", package: "MongoKitten")
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
