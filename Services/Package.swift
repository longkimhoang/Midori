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
        .library(name: "MidoriServicesLive", targets: ["MidoriServicesLive"]),
    ],
    dependencies: [
        .package(path: "MangaDexAPIClient"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.4.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MidoriServices",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
            ],
            path: "Sources/Services"
        ),
        .target(
            name: "MidoriServicesLive",
            dependencies: [
                "MidoriServices",
                "MangaDexAPIClient",
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
            path: "Sources/ServicesLive"
        ),
        .testTarget(
            name: "ServicesTests",
            dependencies: ["MidoriServices"]
        ),
    ]
)
