// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "crisp_chat",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "crisp_chat",
            targets: ["crisp_chat"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/crisp-im/crisp-sdk-ios.git",
            from: "2.13.0"
        )
    ],
    targets: [
        .target(
            name: "crisp_chat",
            dependencies: [
                .product(name: "Crisp", package: "crisp-sdk-ios")
            ],
            path: "../Classes"
        )
    ]
)