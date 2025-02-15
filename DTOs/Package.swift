// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "dtos",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MeetingServiceDTOs",
            targets: ["MeetingServiceDTOs"]),
        .library(
            name: "NotificationsServiceDTOs",
            targets: ["NotificationsServiceDTOs"]),
        .library(
            name: "AuthServiceDTOs",
            targets: ["AuthServiceDTOs"]),
        .library(
            name: "ConfigServiceDTOs",
            targets: ["ConfigServiceDTOs"]),   
        .library(
            name: "PosterServiceDTOs",
            targets: ["PosterServiceDTOs"]),
        .library(
            name: "RideServiceDTOs",
            targets: ["RideServiceDTOs"]),
        .library(
            name: "AIServiceDTOs",
            targets: ["AIServiceDTOs"]),
        .library(
            name: "PollServiceDTOs",
            targets: ["PollServiceDTOs"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MeetingServiceDTOs"),
        .target(
            name: "NotificationsServiceDTOs"),
        .target(
            name: "AuthServiceDTOs"),
        .target(
            name: "ConfigServiceDTOs"),
        .target(
            name: "PosterServiceDTOs"),
        .target(
            name: "RideServiceDTOs"),
        .target(
            name: "AIServiceDTOs"),
        .target(
            name: "PollServiceDTOs"),
    ]
)
