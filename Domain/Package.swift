// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Domain",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .library(name: "Domain", targets: ["Domain"]),
  ],
  dependencies: [
    .package(path: "APIClient"),
    .package(path: "Database"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.2.1"),
    .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.0"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "Domain",
      dependencies: [
        .product(name: "Database", package: "Database"),
        .product(name: "APIClient", package: "APIClient"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
      ]
    ),
  ]
)
