// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "HomeModule",
  defaultLocalization: "en",
  products: [
    .library(name: "HomeUI", targets: ["HomeUI"]),
  ],
  targets: [
    .target(name: "HomeUI"),
    .target(name: "UseCases"),
  ]
)
