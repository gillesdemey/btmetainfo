// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BTMetainfo",
    products: [
        .library(
            name: "BTMetainfo",
            targets: ["BTMetainfo"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/BlueCryptor.git", .upToNextMajor(from: "1.0.31")),
        .package(url: "https://github.com/bluk/bencode.git", .upToNextMajor(from: "0.1.0")),
    ],
    targets: [
        .target(
            name: "BTMetainfo",
            dependencies: ["Bencode", "Cryptor"]
        ),
        .testTarget(
            name: "BTMetainfoTests",
            dependencies: ["BTMetainfo"]
        ),
    ]
)
