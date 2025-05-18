// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "SwiftyJIRA",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "SwiftyJIRA",
            targets: ["SwiftyJIRA"])
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "SwiftyJIRA",
            dependencies: ["SwiftyJSON"]),
        .testTarget(
            name: "SwiftyJIRATests",
            dependencies: ["SwiftyJIRA"])
    ]
)
