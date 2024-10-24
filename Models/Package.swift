// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Models",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to
        // other packages.
        .library(
            name: "MidoriModels",
            targets: ["MidoriModels"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-tagged", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-nonempty", from: "0.5.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MidoriModels",
            dependencies: [
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "NonEmpty", package: "swift-nonempty"),
            ]
        ),
        .testTarget(
            name: "ModelsTests",
            dependencies: ["MidoriModels"]
        ),
    ]
)
