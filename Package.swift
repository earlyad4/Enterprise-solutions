// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NexusEnterprise",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        // The executable target for the main application
        .executable(
            name: "NexusApp",
            targets: ["NexusApp"]),
        // Shared libraries for modular components
        .library(
            name: "NexusCore",
            targets: ["NexusCore"]),
        .library(
            name: "NexusUI",
            targets: ["NexusUI"]),
    ],
    dependencies: [
        // Add dependencies here, e.g., for SQLite or Networking if needed externally
        // .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.14.1")
    ],
    targets: [
        // MARK: - Core Framework
        .target(
            name: "NexusCore",
            dependencies: [],
            path: "Sources/NexusCore"
        ),
        
        // MARK: - UI Design System
        .target(
            name: "NexusUI",
            dependencies: [],
            path: "Sources/NexusUI"
        ),
        
        // MARK: - Feature Modules
        .target(
            name: "FeatureCRM",
            dependencies: ["NexusCore", "NexusUI"],
            path: "Sources/FeatureCRM"
        ),
        .target(
            name: "FeatureFinance",
            dependencies: ["NexusCore", "NexusUI"],
            path: "Sources/FeatureFinance"
        ),
        .target(
            name: "FeatureCommunication",
            dependencies: ["NexusCore", "NexusUI"],
            path: "Sources/FeatureCommunication"
        ),
        .target(
            name: "FeatureAI",
            dependencies: ["NexusCore", "NexusUI"],
            path: "Sources/FeatureAI"
        ),
        .target(
            name: "FeatureMarketing",
            dependencies: ["NexusCore", "NexusUI"],
            path: "Sources/FeatureMarketing"
        ),
        .target(
            name: "FeatureRND",
            dependencies: ["NexusCore", "NexusUI"],
            path: "Sources/FeatureRND"
        ),
        .target(
            name: "FeatureManufacturing",
            dependencies: ["NexusCore", "NexusUI"],
            path: "Sources/FeatureManufacturing"
        ),
        .target(
            name: "FeatureJournal",
            dependencies: ["NexusCore", "NexusUI"],
            path: "Sources/FeatureJournal"
        ),
        
        // MARK: - Main App
        .executableTarget(
            name: "NexusApp",
            dependencies: [
                "NexusCore",
                "NexusUI",
                "FeatureCRM",
                "FeatureFinance",
                "FeatureCommunication",
                "FeatureAI",
                "FeatureMarketing",
                "FeatureRND",
                "FeatureManufacturing",
                "FeatureJournal"
            ],
            path: "Sources/NexusApp"
        ),
        
        // MARK: - Tests
        .testTarget(
            name: "NexusTests",
            dependencies: ["NexusCore", "FeatureCRM"],
            path: "Tests"
        ),
    ]
)
