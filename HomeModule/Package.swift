// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "HomeModule",
  defaultLocalization: "en",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .library(name: "HomeUI", targets: ["HomeUI"]),
  ],
  dependencies: [
    .package(path: "APIClient"),
  ],
  targets: [
    .target(name: "HomeUI", dependencies: [.target(name: "HomeUseCases")]),
    .target(
      name: "HomeUseCases",
      dependencies: [.product(name: "APIClient", package: "APIClient")]
    ),
  ]
)
