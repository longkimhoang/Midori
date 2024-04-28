// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Home",
  defaultLocalization: "en",
  platforms: [.iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to
    // other packages.
    .library(
      name: "Home",
      targets: ["Home"]
    ),
    .library(
      name: "HomeUI",
      targets: ["HomeUI"]
    ),
  ],
  dependencies: [
    .package(path: "Common"),
    .package(path: "Domain"),
    .package(path: "MangaList"),
    .package(path: "Networking"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.9.3"),
    .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Home",
      dependencies: [
        "Domain",
        "MangaList",
        "Networking",
        .product(name: "Models", package: "Domain"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
      ]
    ),
    .target(
      name: "HomeUI",
      dependencies: [
        "Common",
        "Home",
        .product(name: "Models", package: "Domain"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Algorithms", package: "swift-algorithms"),
      ]
    ),
    .testTarget(
      name: "HomeTests",
      dependencies: ["Home"]
    ),
  ]
)
