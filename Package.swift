// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "OOTD-swift",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "OOTD-swift",
            targets: ["OOTD-swift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", from: "2.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "10.0.0")
    ],
    targets: [
        .target(
            name: "OOTD-swift",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk")
            ],
            path: "OOTD-swift"
        )
    ]
)
