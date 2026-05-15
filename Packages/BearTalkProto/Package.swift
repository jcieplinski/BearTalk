// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "BearTalkProto",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .watchOS(.v11)
    ],
    products: [
        .library(name: "BearTalkProto", targets: ["BearTalkProto"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.29.0"),
        .package(url: "https://github.com/grpc/grpc-swift-protobuf", from: "2.0.0"),
    ],
    targets: [
        .target(
            name: "BearTalkProto",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "GRPCProtobuf", package: "grpc-swift-protobuf"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        ),
    ]
)
