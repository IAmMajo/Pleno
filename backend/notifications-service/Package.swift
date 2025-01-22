// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "notifications-service",
    platforms: [
       .macOS(.v13)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.3"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🐘 Fluent driver for Postgres.
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
        // 🍃 An expressive, performant, and extensible templating language built for Swift.
        .package(url: "https://github.com/vapor/leaf.git", from: "4.3.0"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // 🧬 KIVoP Models
        .package(path: "../models"),
        // 🎁 KIVoP DTOs
        .package(path: "../../DTOs"),
        // 📄 Generate OpenAPI documentation from Vapor routes
        .package(url: "https://github.com/dankinsoid/VaporToOpenAPI.git", from: "4.7.1"),
        // 🔐 JWT
        .package(url: "https://github.com/vapor/jwt.git", from: "4.0.0"),
        // 📧 APNS
        .package(url: "https://github.com/vapor/apns.git", from: "4.2.0"),
        // 📧 Firebase Cloud Messaging
        .package(url: "https://github.com/MihaelIsaev/FCM.git", from: "2.13.0"),
        // 📧 SMTP protocol support for the Vapor web framework
        .package(url: "https://github.com/Mikroservices/Smtp.git", from: "3.1.2")
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "Models", package: "models"),
                .product(name: "ConfigServiceDTOs", package: "dtos"),
                .product(name: "NotificationsServiceDTOs", package: "dtos"),
                .product(name: "VaporToOpenAPI", package: "VaporToOpenAPI"),
                .product(name: "JWT", package: "jwt"),
                .product(name: "VaporAPNS", package: "apns"),
                .product(name: "FCM", package: "FCM"),
                .product(name: "Smtp", package: "Smtp")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        )
    ],
    swiftLanguageModes: [.v5]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("StrictConcurrency"),
] }
