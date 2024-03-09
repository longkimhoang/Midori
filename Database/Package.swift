// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Database",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .library(name: "Database", targets: ["Database"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-dependencies.git",
      .upToNextMajor(from: "1.2.1")
    ),
  ],
  targets: [
    .target(
      name: "Database",
      dependencies: [.product(name: "Dependencies", package: "swift-dependencies")]
    ),
  ]
)
