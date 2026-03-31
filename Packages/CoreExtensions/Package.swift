// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "CoreExtensions",
    platforms: [.iOS(.v26), .macOS(.v15)],
    products: [
        .library(name: "CoreExtensions", targets: ["CoreExtensions"]),
    ],
    targets: [
        .target(name: "CoreExtensions"),
        .testTarget(name: "CoreExtensionsTests", dependencies: ["CoreExtensions"]),
    ],
)
