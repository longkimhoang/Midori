// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "App",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to
        // other packages.
        .library(
            name: "MidoriApp",
            targets: ["MidoriApp"]
        ),
    ],
    dependencies: [
        .package(path: "Features"),
        .package(path: "UI"),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture",
            from: "1.15.1"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MidoriApp",
            dependencies: [
                .product(name: "MidoriFeatures", package: "Features"),
                .product(name: "MidoriUI", package: "UI"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "MidoriAppTests",
            dependencies: ["MidoriApp"]
        ),
    ]
)
