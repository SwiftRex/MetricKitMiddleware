// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MetricKitMiddleware",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "MetricKitCombineMiddleware", targets: ["MetricKitCombineMiddleware"]),
        .library(name: "MetricKitRxSwiftMiddleware", targets: ["MetricKitRxSwiftMiddleware"]),
        .library(name: "MetricKitReactiveSwiftMiddleware", targets: ["MetricKitReactiveSwiftMiddleware"])
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftRex/SwiftRex.git", from: "0.8.8")
    ],
    targets: [
        .target(name: "MetricKitCombineMiddleware", dependencies: [.product(name: "CombineRex", package: "SwiftRex")]),
        .target(name: "MetricKitRxSwiftMiddleware", dependencies: [.product(name: "RxSwiftRex", package: "SwiftRex")]),
        .target(name: "MetricKitReactiveSwiftMiddleware", dependencies: [.product(name: "ReactiveSwiftRex", package: "SwiftRex")])
    ]
)
