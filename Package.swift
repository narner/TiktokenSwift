// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TiktokenSwift",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "TiktokenSwift",
            targets: ["TiktokenSwift"]),
    ],
    targets: [
        .target(
            name: "TiktokenSwift",
            dependencies: ["TiktokenFFI"],
            path: "Sources/TiktokenSwift"
        ),
        .binaryTarget(
            name: "TiktokenFFI",
            path: "Sources/TiktokenFFI/TiktokenFFI.xcframework"
        ),
        .testTarget(
            name: "TiktokenSwiftTests",
            dependencies: ["TiktokenSwift"],
            path: "Tests/TiktokenSwiftTests"
        ),
    ]
)