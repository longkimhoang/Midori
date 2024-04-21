// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Application",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "Application",
      targets: ["Application"]
    ),
    .library(
      name: "ApplicationUI",
      targets: ["ApplicationUI"]
    ),
  ],
  dependencies: [
    .package(path: "Common"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.9.3"),
  ],
  targets: [
    .target(
      name: "Application",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "ApplicationUI",
      dependencies: [
        "Application",
        "Common",
      ]
    ),
    .testTarget(
      name: "ApplicationTests",
      dependencies: ["Application"]
    ),
  ]
)
