// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Eyebreak",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "Eyebreak", targets: ["Eyebreak"])
    ],
    targets: [
        .executableTarget(
            name: "Eyebreak",
            resources: [
                .process("Resources/quotes.json"),
                .process("Resources/config.json")
            ],
            swiftSettings: [
                .unsafeFlags(["-parse-as-library"])
            ]
        )
    ]
)
