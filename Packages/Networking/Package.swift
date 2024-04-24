// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Networking",
  platforms: [.iOS(.v17)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to
    // other packages.
    .library(
      name: "Networking",
      targets: ["Networking"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire", from: "5.9.1"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.2.2"),
    .package(url: "https://github.com/pointfreeco/swift-nonempty", from: "0.5.0"),
    .package(url: "https://github.com/SwiftyLab/MetaCodable", from: "1.3.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Networking",
      dependencies: [
        "Alamofire",
        "MetaCodable",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "NonEmpty", package: "swift-nonempty"),
        .product(name: "HelperCoders", package: "MetaCodable"),
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
      ]
    ),
    .testTarget(
      name: "NetworkingTests",
      dependencies: ["Networking"]
    ),
  ]
)
