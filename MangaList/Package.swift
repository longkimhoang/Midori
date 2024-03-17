// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MangaList",
  defaultLocalization: "en",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .library(name: "MangaListUI", targets: ["MangaListUI"]),
  ],
  dependencies: [
    .package(path: "CommonUI"),
    .package(path: "Database"),
  ],
  targets: [
    .target(
      name: "MangaListUI",
      dependencies: [
        .product(name: "CommonUI", package: "CommonUI"),
        .product(name: "Database", package: "Database"),
      ]
    ),
  ]
)
