// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Services",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to
        // other packages.
        .library(
            name: "MidoriServices",
            targets: ["MidoriServices"]
        ),
        .library(name: "LiveServices", targets: ["LiveServices"]),
    ],
    dependencies: [
        .package(path: "MangaDexAPIClient"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MidoriServices",
            dependencies: ["MangaDexAPIClient"],
            path: "Sources/Services"
        ),
        .target(name: "LiveServices"),
        .testTarget(
            name: "ServicesTests",
            dependencies: ["MidoriServices"]
        ),
    ]
)
