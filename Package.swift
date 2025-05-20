// swift-tools-version: 6.0

import PackageDescription

let package = Package(
	name: "swift-navigation-test",
	platforms: [
		.iOS(.v13),
		.macOS(.v13),
		.tvOS(.v13),
		.watchOS(.v6),
	],
	dependencies: [
		.package(
			url: "https://github.com/maximkrouk/swift-navigation.git",
			branch: "expose-observe-function"
		)
	],
	targets: [
		.executableTarget(
			name: "swift-navigation-test",
			dependencies: [
				.product(
					name: "SwiftNavigation",
					package: "swift-navigation"
				),
			]
		),
	]
)
