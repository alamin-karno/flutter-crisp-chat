// swift-tools-version: 5.9
import Foundation
import PackageDescription

// Build-time opt-in for Crisp video/audio calls when using Swift Package Manager.
//
// CocoaPods: set `$CrispChatWebRTC = true` in your app's ios/Podfile.
// SPM: export before build:
//   CRISP_CHAT_WEBRTC=true flutter build ios
//
// Or add `CRISP_CHAT_WEBRTC` = `true` to your Xcode scheme environment variables.
private func environmentFlag(_ name: String) -> Bool {
    guard let value = ProcessInfo.processInfo.environment[name] else {
        return false
    }
    switch value.lowercased() {
    case "1", "true", "yes":
        return true
    default:
        return false
    }
}

let useWebRTC = environmentFlag("CRISP_CHAT_WEBRTC")
let crispSdkProduct = useWebRTC ? "CrispWebRTC" : "Crisp"

var crispChatSwiftSettings: [SwiftSetting] = []
if useWebRTC {
    crispChatSwiftSettings.append(.define("CRISP_WEBRTC"))
}

let package = Package(
    name: "crisp_chat",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "crisp-chat",
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
                .product(name: crispSdkProduct, package: "crisp-sdk-ios")
            ],
            path: "Sources/crisp_chat",
            swiftSettings: crispChatSwiftSettings,
            linkerSettings: [
                .linkedFramework("UIKit")
            ]
        )
    ]
)
