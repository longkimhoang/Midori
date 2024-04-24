// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Domain",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "Domain",
      targets: ["Domain"]
    ),
    .library(
      name: "Models",
      targets: ["Models"]
    ),
  ],
  dependencies: [
    .package(path: "Networking"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.2.2"),
    .package(url: "https://github.com/pointfreeco/swift-nonempty", from: "0.5.0"),
  ],
  targets: [
    .target(
      name: "Domain",
      dependencies: [
        "Networking",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
      ]
    ),
    .testTarget(
      name: "DomainTests",
      dependencies: ["Domain"]
    ),
    .target(
      name: "Models",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "NonEmpty", package: "swift-nonempty"),
      ]
    ),
  ]
)
