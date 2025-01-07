// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ViewModels",
    defaultLocalization: "en",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MidoriViewModels",
            targets: ["MidoriViewModels"]
        )
    ],
    dependencies: [
        .package(path: "Storage"),
        .package(path: "Services"),
        .package(path: "Models"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.4"),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.1.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MidoriViewModels",
            dependencies: [
                .product(name: "MidoriStorage", package: "Storage"),
                .product(name: "MidoriServices", package: "Services"),
                .product(name: "MidoriModels", package: "Models"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
            ]
        ),
        .testTarget(
            name: "MidoriViewModelsTests",
            dependencies: ["MidoriViewModels"]
        ),
    ]
)
