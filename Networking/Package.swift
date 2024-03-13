// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Networking",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .library(name: "APIClients", targets: ["APIClients"]),
    .library(name: "APIModels", targets: ["APIModels"]),
  ],
  dependencies: [
    .package(url: "https://github.com/SwiftyLab/MetaCodable.git", .upToNextMajor(from: "1.3.0")),
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.8.1")),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.2.1"),
  ],
  targets: [
    .target(
      name: "Common",
      dependencies: [
        .product(name: "MetaCodable", package: "MetaCodable"),
        .product(name: "HelperCoders", package: "MetaCodable"),
        .product(name: "Alamofire", package: "Alamofire"),
      ]
    ),
    .testTarget(
      name: "CommonTests",
      dependencies: [.target(name: "Common")]
    ),
    .target(
      name: "APIClients",
      dependencies: [
        .target(name: "APIModels"),
        .product(name: "Alamofire", package: "Alamofire"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "MetaCodable", package: "MetaCodable"),
      ]
    ),
    .target(
      name: "APIModels",
      dependencies: [
        .target(name: "Common"),
        .product(name: "MetaCodable", package: "MetaCodable"),
      ]
    ),
  ]
)
