// swift-tools-version: 6.3
import PackageDescription
let package = Package(name: "ChallengeKit", platforms: [.iOS(.v18), .macOS(.v15)], products: [.library(name: "ChallengeKit", targets: ["ChallengeKit"])], targets: [.target(name: "ChallengeKit"), .testTarget(name: "ChallengeKitTests", dependencies: ["ChallengeKit"])], swiftLanguageModes: [.v6])
