// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SharedUI",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "SharedUI", targets: ["SharedUI"]),
    ],
    dependencies: [
        .package(path: "../CoreModels"),
    ],
    targets: [
        .target(
            name: "SharedUI",
            dependencies: ["CoreModels"],
        ),
    ],
)
