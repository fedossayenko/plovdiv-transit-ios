// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "StopFeature",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "StopFeature", targets: ["StopFeature"]),
    ],
    dependencies: [
        .package(path: "../CoreModels"),
        .package(path: "../TransitNetwork"),
        .package(path: "../SharedUI"),
        .package(path: "../CoreExtensions"),
    ],
    targets: [
        .target(
            name: "StopFeature",
            dependencies: ["CoreModels", "TransitNetwork", "SharedUI", "CoreExtensions"],
        ),
    ],
)
