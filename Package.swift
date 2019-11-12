// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "PersistentIdentifier",
    platforms: [
        .watchOS(.v6), .iOS(.v13)
    ],
    products: [
        .library(name: "PersistentIdentifier", targets: ["PersistentIdentifier"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "PersistentIdentifier", dependencies: []),
        .testTarget(name: "PersistentIdentifierTests", dependencies: ["PersistentIdentifier"]),
    ]
)
