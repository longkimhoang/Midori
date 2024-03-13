// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "HomeModule",
  defaultLocalization: "en",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .library(name: "HomeUI", targets: ["HomeUI"]),
    .library(name: "HomeCore", targets: ["HomeCore"]),
  ],
  dependencies: [
    .package(path: "CommonUI"),
    .package(path: "Domain"),
    .package(path: "Networking"),
    .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.2.1"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.9.2"),
    .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
    .package(url: "https://github.com/kean/Nuke.git", from: "12.4.0"),
    .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
    .package(url: "https://github.com/flocked/AdvancedCollectionTableView.git", branch: "main"),
  ],
  targets: [
    .target(
      name: "HomeCore",
      dependencies: [
        .product(name: "Domain", package: "Domain"),
        .product(name: "APIClients", package: "Networking"),
        .product(name: "APIModels", package: "Networking"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "HomeUI",
      dependencies: [
        .target(name: "HomeCore"),
        .product(name: "CommonUI", package: "CommonUI"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "SnapKit", package: "SnapKit"),
        .product(name: "Nuke", package: "Nuke"),
        .product(name: "Collections", package: "swift-collections"),
        .product(
          name: "AdvancedCollectionTableView",
          package: "AdvancedCollectionTableView",
          condition: .when(platforms: [.macOS])
        ),
      ]
    ),
  ]
)
