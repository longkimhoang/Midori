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
  ],
  dependencies: [
    .package(path: "Networking"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.2.2"),
    .package(url: "https://github.com/pointfreeco/swift-nonempty", from: "0.5.0"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "Domain",
      dependencies: [
        "Networking",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
        .product(name: "NonEmpty", package: "swift-nonempty"),
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
      ]
    ),
    .testTarget(
      name: "DomainTests",
      dependencies: ["Domain"]
    ),
  ]
)
