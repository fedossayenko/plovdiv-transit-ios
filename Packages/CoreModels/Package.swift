// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "CoreModels",
    platforms: [.iOS(.v26), .macOS(.v15)],
    products: [
        .library(name: "CoreModels", targets: ["CoreModels"])
    ],
    targets: [
        .target(name: "CoreModels"),
        .testTarget(name: "CoreModelsTests", dependencies: ["CoreModels"])
    ]
)
