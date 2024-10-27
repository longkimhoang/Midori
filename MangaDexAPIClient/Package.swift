// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MangaDexAPIClient",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to
        // other packages.
        .library(
            name: "MangaDexAPIClient",
            targets: ["MangaDexAPIClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Get", from: "2.2.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.4.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MangaDexAPIClient",
            dependencies: [
                "Get",
                .product(name: "Dependencies", package: "swift-dependencies"),
            ]
        ),
        .testTarget(
            name: "MangaDexAPIClientTests",
            dependencies: ["MangaDexAPIClient"],
            resources: [.process("Resources")]
        ),
    ]
)
