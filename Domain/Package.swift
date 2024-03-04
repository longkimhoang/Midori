// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Domain",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .library(name: "ModelImporters", targets: ["ModelImporters"]),
  ],
  dependencies: [
    .package(path: "APIClient"),
    .package(path: "Persistence"),
    .package(
      url: "https://github.com/pointfreeco/swift-dependencies.git",
      .upToNextMajor(from: "1.2.1")
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-identified-collections.git",
      .upToNextMajor(from: "1.0.0")
    ),
  ],
  targets: [
    .target(
      name: "ModelImporters",
      dependencies: [
        .product(name: "APIClient", package: "APIClient"),
        .product(name: "Persistence", package: "Persistence"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
      ]
    ),
  ]
)
