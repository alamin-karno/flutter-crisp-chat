// swift-tools-version: 5.9
import PackageDescription

// Crisp iOS SDK 3.x ships audio/video calls in the single `Crisp` product —
// the 2.x `CrispWebRTC` product (and the `CRISP_CHAT_WEBRTC` opt-in) is gone.
// Resolving it requires Xcode 16.3+ (the SDK uses swift-tools-version 6.1).
let package = Package(
    name: "crisp_chat",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "crisp-chat",
            targets: ["crisp_chat"]
        )
    ],
    dependencies: [
        // Required by Flutter's SPM plugin support (3.44+) for plugins that
        // import Flutter directly, resolved by Flutter's tooling at build time.
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(
            url: "https://github.com/crisp-im/crisp-sdk-ios.git",
            from: "3.0.1"
        )
    ],
    targets: [
        .target(
            name: "crisp_chat",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                .product(name: "Crisp", package: "crisp-sdk-ios")
            ],
            path: "Sources/crisp_chat",
            linkerSettings: [
                .linkedFramework("UIKit")
            ]
        )
    ]
)
