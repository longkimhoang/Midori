// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Persistence",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .library(name: "Persistence", targets: ["Persistence"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-dependencies.git",
      .upToNextMajor(from: "1.2.1")
    ),
  ],
  targets: [
    .target(
      name: "Persistence",
      dependencies: [.product(name: "Dependencies", package: "swift-dependencies")]
    ),
  ]
)
