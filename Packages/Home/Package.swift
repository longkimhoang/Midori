// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Home",
  platforms: [.iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to
    // other packages.
    .library(
      name: "Home",
      targets: ["Home"]
    ),
  ],
  dependencies: [
    .package(path: "Domain"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.9.3"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Home",
      dependencies: [
        .product(name: "Models", package: "Domain"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "HomeTests",
      dependencies: ["Home"]
    ),
  ]
)
