// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "APIClient",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .library(name: "APIClient", targets: ["APIClient"])
  ],
  dependencies: [
    .package(url: "https://github.com/SwiftyLab/MetaCodable.git", from: "1.2.1"),
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.8.1")),
  ],
  targets: [
    .target(
      name: "Common",
      dependencies: [
        .product(name: "MetaCodable", package: "MetaCodable"),
        .product(name: "HelperCoders", package: "MetaCodable"),
      ]
    ),
    .testTarget(name: "CommonTests", dependencies: [.target(name: "Common")]),
    .target(
      name: "MangaEndpoint",
      dependencies: [
        .target(name: "Common"),
        .product(name: "Alamofire", package: "Alamofire"),
      ]
    ),
    .target(
      name: "APIClient",
      dependencies: [.target(name: "MangaEndpoint")]
    ),
  ]
)
