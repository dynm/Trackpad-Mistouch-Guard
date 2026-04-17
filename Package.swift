// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "anti-mistouch",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(
            name: "anti-mistouch",
            targets: ["anti-mistouch"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "anti-mistouch",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("ApplicationServices"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("SwiftUI"),
            ]
        ),
        .testTarget(
            name: "anti-mistouchTests",
            dependencies: ["anti-mistouch"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
