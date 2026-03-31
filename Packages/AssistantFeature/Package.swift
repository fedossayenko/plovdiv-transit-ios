// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "AssistantFeature",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "AssistantFeature", targets: ["AssistantFeature"]),
    ],
    dependencies: [
        .package(path: "../CoreModels"),
        .package(path: "../TransitNetwork"),
        .package(path: "../SharedUI"),
        .package(path: "../CoreExtensions"),
    ],
    targets: [
        .target(
            name: "AssistantFeature",
            dependencies: ["CoreModels", "TransitNetwork", "SharedUI", "CoreExtensions"],
        ),
    ],
)
