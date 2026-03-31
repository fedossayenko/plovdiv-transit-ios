// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "ScheduleFeature",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "ScheduleFeature", targets: ["ScheduleFeature"]),
    ],
    dependencies: [
        .package(path: "../CoreModels"),
        .package(path: "../TransitNetwork"),
        .package(path: "../SharedUI"),
    ],
    targets: [
        .target(
            name: "ScheduleFeature",
            dependencies: ["CoreModels", "TransitNetwork", "SharedUI"],
        ),
    ],
)
