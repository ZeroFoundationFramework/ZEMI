// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "ZEMI",
    platforms: [ .macOS(.v12) ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ZEMI",
            targets: ["ZEMI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.6.1"),
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.1.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ZEMI",
            dependencies: [
                "ZeroDB",
                "ZeroMacrosClient"
            ]
        ),
        
        .target(
            name: "ZeroDB"
        ),
        
        .executableTarget(
            name: "ZEMI_CLI" ,
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        
        .macro(
            name: "ZeroMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        
        .target(
            name: "ZeroMacrosClient",
            dependencies: [
                "ZeroMacros"
            ]
        ),
        
        .testTarget(
            name: "ZeroDBTests",
            dependencies: ["ZeroDB"]
        ),
        
        .testTarget(
            name: "ZeroMacrosTests",
            dependencies: [
                "ZeroMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        ),
    
        .testTarget(
            name: "ZEMITests",
            dependencies: ["ZEMI"]
        ),
    ]
)

