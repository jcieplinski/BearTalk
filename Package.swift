// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BearTalk",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "BearTalk",
            targets: ["BearTalk"]),
    ],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.20.0"),
    ],
    targets: [
        .target(
            name: "BearTalk",
            dependencies: [
                .product(name: "GRPC", package: "grpc-swift"),
            ],
            plugins: [
                .plugin(name: "GRPCSwiftPlugin", package: "grpc-swift")
            ]
        ),
        .testTarget(
            name: "BearTalkTests",
            dependencies: ["BearTalk"]),
    ]
) 