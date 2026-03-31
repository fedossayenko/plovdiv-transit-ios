// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "TransitNetwork",
    platforms: [.iOS(.v26), .macOS(.v15)],
    products: [
        .library(name: "TransitNetwork", targets: ["TransitNetwork"]),
    ],
    dependencies: [
        .package(path: "../CoreModels"),
        .package(path: "../CoreExtensions"),
    ],
    targets: [
        .target(
            name: "TransitNetwork",
            dependencies: ["CoreModels", "CoreExtensions"],
        ),
        .testTarget(
            name: "TransitNetworkTests",
            dependencies: ["TransitNetwork"],
        ),
    ],
)
