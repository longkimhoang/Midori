// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "CommonUI",
  platforms: [.macOS(.v14), .iOS(.v17)],
  products: [
    .library(name: "CommonUI", targets: ["CommonUI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/kean/Nuke.git", from: "12.4.0"),
  ],
  targets: [
    .target(
      name: "CommonUI",
      dependencies: [
        .product(name: "Nuke", package: "Nuke"),
      ]
    ),
  ]
)
