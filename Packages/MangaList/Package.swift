// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MangaList",
  defaultLocalization: "en",
  platforms: [.iOS(.v17)],
  products: [
    .library(
      name: "MangaList",
      targets: ["MangaList"]
    ),
    .library(
      name: "MangaListUI",
      targets: ["MangaListUI"]
    ),
  ],
  dependencies: [
    .package(path: "Domain"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.9.3"),
  ],
  targets: [
    .target(
      name: "MangaList",
      dependencies: [
        "Domain",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
      ]
    ),
    .testTarget(
      name: "MangaListTests",
      dependencies: ["MangaList"]
    ),
    .target(
      name: "MangaListUI",
      dependencies: [
        "MangaList",
      ]
    ),
  ]
)
