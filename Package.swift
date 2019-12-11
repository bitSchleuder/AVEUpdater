// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AVEUpdater",
    products: [
        .executable(name: "AVEUpdater-audi-ave-dev-mock-1.3.4.exe", targets: ["AVEUpdater"]),
        .executable(name: "AVEUpdater-audi-ave-dev-mock-1.3.3.exe", targets: ["AVEUpdater"]),
        .executable(name: "AVEUpdater-audi-ave-dev-mock-1.3.2.exe", targets: ["AVEUpdater"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    // .package(url: "https://github.com/jakeheis/SwiftCLI.git", from: "5.3.3"),
    .package(url: "https://github.com/swift-aws/aws-sdk-swift.git", from: "4.0.0")
	],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "AVEUpdater",
            dependencies: ["S3"]),
        .testTarget(
            name: "AVEUpdaterTests",
            dependencies: ["AVEUpdater"]),
    ]
)
