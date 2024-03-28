// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MangaList",
  defaultLocalization: "en",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .library(name: "MangaListCore", targets: ["MangaListCore"]),
    .library(name: "MangaListUI", targets: ["MangaListUI"]),
  ],
  dependencies: [
    .package(path: "CommonUI"),
    .package(path: "Database"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.9.2"),
  ],
  targets: [
    .target(
      name: "MangaListCore",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "MangaListUI",
      dependencies: [
        .target(name: "MangaListCore"),
        .product(name: "CommonUI", package: "CommonUI"),
        .product(name: "Database", package: "Database"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
  ]
)
