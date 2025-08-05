// swift-tools-version:6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IMSRepository",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "IMSRepository",
            targets: ["IMSRepository"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.12.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.10.1"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        .package(url: "https://github.com/cmarioRV/vapor-firestore.git", branch: "master"),
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.52.2"),
        .package(url: "https://github.com/rosecoder/google-cloud-auth-swift.git", from: "1.2.2"),
        .package(name: "IMSDomain", path: "../IMSDomain"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "IMSRepository",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "VaporFirestore", package: "vapor-firestore"),
                .product(name: "FluentKit", package: "fluent-kit"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "GoogleCloudAuth", package: "google-cloud-auth-swift"),
                "IMSDomain",
            ]
            ),
        .testTarget(
            name: "IMSRepositoryTests",
            dependencies: ["IMSRepository"]
        ),
    ]
)
