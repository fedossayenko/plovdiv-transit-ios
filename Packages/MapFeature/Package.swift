// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MapFeature",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "MapFeature", targets: ["MapFeature"]),
    ],
    dependencies: [
        .package(path: "../CoreModels"),
        .package(path: "../TransitNetwork"),
        .package(path: "../SharedUI"),
        .package(path: "../CoreExtensions"),
        .package(path: "../StopFeature"),
    ],
    targets: [
        .target(
            name: "MapFeature",
            dependencies: ["CoreModels", "TransitNetwork", "SharedUI", "CoreExtensions", "StopFeature"],
        ),
    ],
)
