// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UI",
    defaultLocalization: "en",
    platforms: [.iOS(.v18)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to
        // other packages.
        .library(
            name: "MidoriUI",
            targets: ["MidoriUI"]
        ),
    ],
    dependencies: [
        .package(path: "Features"),
        .package(url: "https://github.com/kean/Nuke", from: "12.8.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MidoriUI",
            dependencies: [
                .product(name: "MidoriFeatures", package: "Features"),
                .product(name: "Nuke", package: "Nuke"),
            ]
        ),
        .testTarget(
            name: "UITests",
            dependencies: ["MidoriUI"]
        ),
    ]
)
