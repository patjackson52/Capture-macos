// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Capture",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "CaptureApp", targets: ["CaptureApp"])
    ],
    targets: [
        .executableTarget(
            name: "CaptureApp",
            path: "Sources/CaptureApp"
        ),
        .testTarget(
            name: "CaptureAppTests",
            dependencies: ["CaptureApp"],
            path: "Tests/CaptureAppTests"
        )
    ]
)
