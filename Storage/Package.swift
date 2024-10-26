// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Storage",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to
        // other packages.
        .library(
            name: "MidoriStorage",
            targets: ["MidoriStorage"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.4.1"),
        .package(url: "https://github.com/pointfreeco/swift-tagged", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-nonempty", from: "0.5.0"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MidoriStorage",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "DependenciesMacros", package: "swift-dependencies"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "NonEmpty", package: "swift-nonempty"),
            ]
        ),
        .testTarget(
            name: "StorageTests",
            dependencies: [
                "MidoriStorage",
                .product(name: "Numerics", package: "swift-numerics"),
            ]
        ),
    ]
)
