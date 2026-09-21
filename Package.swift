// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "TrisLocationKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "TrisLocationKit",
            targets: [
                "TrisLocationKit"
            ]
        )
    ],
    targets: [
        .target(
            name: "TrisLocationKit"
        ),
        .testTarget(
            name: "TrisLocationKitTests",
            dependencies: [
                "TrisLocationKit"
            ]
        )
    ]
)
