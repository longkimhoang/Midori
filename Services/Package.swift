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
        .package(path: "MangaDexAuth"),
        .package(path: "Storage"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.4.1"),
        .package(url: "https://github.com/WeTransfer/Mocker", from: "3.0.2"),
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "1.0.2"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MidoriServices",
            dependencies: [
                .product(name: "MidoriStorage", package: "Storage"),
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
            path: "Sources/Services"
        ),
        .target(
            name: "MidoriServicesLive",
            dependencies: [
                "MidoriServices",
                "MangaDexAPIClient",
                "MangaDexAuth",
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
                "KeychainAccess",
            ],
            path: "Sources/ServicesLive"
        ),
        .testTarget(
            name: "ServicesTests",
            dependencies: ["MidoriServices"]
        ),
        .testTarget(
            name: "ServicesLiveTests",
            dependencies: [
                "MidoriServicesLive",
                "Mocker",
                .product(name: "MangaDexAPIStubs", package: "MangaDexAPIClient"),
            ]
        ),
    ]
)
