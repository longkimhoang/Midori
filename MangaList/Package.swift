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
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", from: "1.9.2"),
    .package(url: "https://github.com/kean/Nuke.git", from: "12.4.0"),
  ],
  targets: [
    .target(
      name: "MangaListCore",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Nuke", package: "Nuke"),
      ]
    ),
    .target(
      name: "MangaListUI",
      dependencies: [
        .target(name: "MangaListCore"),
        .product(name: "CommonUI", package: "CommonUI"),
      ]
    ),
  ]
)
