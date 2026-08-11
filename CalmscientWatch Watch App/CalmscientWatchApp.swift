//
//  CalmscientWatchApp.swift
//  CalmscientWatch Watch App
//
//  Entry point for the CalmScient Apple Watch companion app.
//
//  11 August 2026
//

import SwiftUI

@main
struct CalmscientWatch_Watch_AppApp: App {

    @StateObject private var connectivity = WatchConnectivityManager.shared

    init() {
        // Activate the phone bridge. HealthKit access is requested on demand
        // (when a breathing session is logged), so the app opens straight to
        // the menu instead of a permission prompt.
        WatchConnectivityManager.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            WatchRootView()
                .environmentObject(connectivity)
        }
    }
}
