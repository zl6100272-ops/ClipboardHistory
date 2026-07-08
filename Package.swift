// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ClipboardHistory",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "ClipboardHistory", targets: ["ClipboardHistory"])
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.29.3")
    ],
    targets: [
        .executableTarget(
            name: "ClipboardHistory",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift")
            ],
            path: "ClipboardHistory",
            resources: [
                .process("Assets.xcassets")
            ]
        )
    ]
)
