// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    defaultLocalization: "en",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to
        // other packages.
        .library(
            name: "MidoriFeatures",
            targets: ["MidoriFeatures"]
        ),
    ],
    dependencies: [
        .package(path: "Storage"),
        .package(path: "Services"),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.15.1"
        ),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MidoriFeatures",
            dependencies: [
                .product(name: "MidoriStorage", package: "Storage"),
                .product(name: "MidoriServices", package: "Services"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Algorithms", package: "swift-algorithms"),
            ]
        ),
        .testTarget(
            name: "FeaturesTests",
            dependencies: ["MidoriFeatures"]
        ),
    ]
)
