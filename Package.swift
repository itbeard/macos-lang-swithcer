// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "VoiceLangSwitch",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "VoiceLangSwitch",
            path: "Sources"
        )
    ]
)
