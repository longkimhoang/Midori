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
    .package(path: "Domain"),
    .package(path: "Persistence"),
    .package(
      url: "https://github.com/pointfreeco/swift-dependencies.git",
      .upToNextMajor(from: "1.2.1")
    ),
    .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.7.1")),
    .package(url: "https://github.com/apple/swift-algorithms.git", .upToNextMajor(from: "1.2.0")),
    .package(
      url: "https://github.com/pointfreeco/swift-identified-collections.git",
      .upToNextMajor(from: "1.0.0")
    ),
  ],
  targets: [
    .target(
      name: "HomeUI",
      dependencies: [
        .target(name: "HomeDomain"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "SnapKit", package: "SnapKit"),
      ]
    ),
    .target(
      name: "HomeDomain",
      dependencies: [
        .product(name: "APIClient", package: "APIClient"),
        .product(name: "ModelImporters", package: "Domain"),
        .product(name: "Persistence", package: "Persistence"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
      ]
    ),
  ]
)
