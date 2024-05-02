// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Midori",
  defaultLocalization: "en",
  platforms: [.iOS(.v17), .macCatalyst(.v17), .macOS(.v14)],
  products: [
    .library(name: "Networking", targets: ["Networking"]),
    .library(name: "Domain", targets: ["Domain"]),
    .library(name: "Common", targets: ["Common"]),
    .library(name: "ApplicationCore", targets: ["ApplicationCore"]),
    .library(name: "ApplicationUI", targets: ["ApplicationUI"]),
    .library(name: "HomeCore", targets: ["HomeCore"]),
    .library(name: "HomeUI", targets: ["HomeUI"]),
    .library(name: "MangaListCore", targets: ["MangaListCore"]),
    .library(name: "MangaListUI", targets: ["MangaListUI"]),
    .library(name: "MangaDetailCore", targets: ["MangaDetailCore"]),
    .library(name: "MangaDetailUI", targets: ["MangaDetailUI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.2.2"),
    .package(url: "https://github.com/Alamofire/Alamofire", from: "5.9.1"),
    .package(url: "https://github.com/pointfreeco/swift-nonempty", from: "0.5.0"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.1"),
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.10.1"),
    .package(url: "https://github.com/kean/Nuke", from: "12.6.0"),
    .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
  ],
  targets: [
    .target(
      name: "Networking",
      dependencies: [
        "Alamofire",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "NonEmpty", package: "swift-nonempty"),
      ]
    ),
    .target(
      name: "Domain",
      dependencies: [
        "Networking",
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
      ]
    ),
    .target(
      name: "Common",
      dependencies: ["Nuke"]
    ),
    .target(
      name: "ApplicationCore",
      dependencies: [
        "HomeCore",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(name: "ApplicationCoreTests", dependencies: ["ApplicationCore"]),
    .target(
      name: "ApplicationUI",
      dependencies: [
        "ApplicationCore",
        "HomeUI",
      ]
    ),
    .target(
      name: "HomeCore",
      dependencies: [
        "Domain",
        "Networking",
        "MangaListCore",
        "MangaDetailCore",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(name: "HomeCoreTests", dependencies: ["HomeCore"]),
    .target(
      name: "HomeUI",
      dependencies: [
        "HomeCore",
        "Common",
        "MangaListUI",
        .product(name: "Algorithms", package: "swift-algorithms"),
      ]
    ),
    .target(
      name: "MangaListCore",
      dependencies: [
        "Domain",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "MangaListUI",
      dependencies: [
        "MangaListCore",
        "Common",
        .product(name: "Algorithms", package: "swift-algorithms"),
      ]
    ),
    .target(
      name: "MangaDetailCore",
      dependencies: [
        "Domain",
        "Networking",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .target(
      name: "MangaDetailUI",
      dependencies: [
        "MangaDetailCore",
        "Common",
        .product(name: "NukeUI", package: "Nuke"),
        .product(name: "Algorithms", package: "swift-algorithms"),
      ]
    ),
  ]
)

for target in package.targets where target.type != .system {
  target.swiftSettings = target.swiftSettings ?? []
  target.swiftSettings?.append(contentsOf: [
    .enableExperimentalFeature("StrictConcurrency"),
  ])
}
