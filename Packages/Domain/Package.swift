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
  ],
  targets: [
    .target(
      name: "Domain",
      dependencies: [
        "Networking",
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .target(
      name: "Models",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
      ]
    ),
    .testTarget(
      name: "DomainTests",
      dependencies: ["Domain"]
    ),
  ]
)
