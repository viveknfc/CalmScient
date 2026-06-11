//
//  MainTabBarViewModel.swift
//  Calmscient
//
//  Drives the SwiftUI main tab bar while preserving legacy `tabTitles` + behavior.
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit

/// Localization keys for the main tab bar (see `main_tab_bar_*` in Localizable.strings).
private let mainTabBarTitleKeys = [
    "main_tab_bar_home",
    "main_tab_bar_discovery",
    "main_tab_bar_exercises",
    "main_tab_bar_rewards",
]

@available(iOS 16.0, *)
@MainActor
final class MainTabBarViewModel: ObservableObject {

    @Published var selectedTab: MainTab = .home
    /// Bumped whenever the legacy `prepareTabs()` flow rebuilt all tab stacks.
    @Published private(set) var contentGeneration: Int = 0
    @Published private(set) var localizedTitles: [String] = []

    /// Mirrors `AppMainTabViewController.isInitalView` (typo preserved for call sites).
    var isInitalView: Bool = false

    init() {
        refreshLocalizedTabTitles()
    }

    var useMedicationsForFirstTab: Bool { isInitalView }

    func title(for tab: MainTab) -> String {
        let idx = tab.rawValue
        guard idx >= 0, idx < localizedTitles.count else { return "" }
        return localizedTitles[idx]
    }

    /// Equivalent to legacy `updateTabBarItems` (titles only, no stack rebuild).
    func refreshLocalizedTabTitles() {
        tabTitles = mainTabBarTitleKeys.map { $0.localized }
        localizedTitles = tabTitles
    }

    /// Equivalent to legacy `updateTabBarItems` + `prepareTabs` refresh cycle.
    func prepareTabsCycle(reason: String) {
        print("prepare Tabs (SwiftUI) reason=\(reason)")
        print("the initial view value is ", isInitalView)
        refreshLocalizedTabTitles()
        guard localizedTitles.count >= 4 else {
            print("Error: tabTitles does not have enough elements.")
            return
        }
        contentGeneration &+= 1
    }

    /// Legacy `tabBarController(_:didSelect:)` side effects + full tab rebuild.
    func onUserSelectedTab(_ tab: MainTab) {
        print("Tab bar selecting from here")
        isInitalView = false
        // Legacy compared the tab root (always a `UINavigationController`) to `FavoritesVideosWebViewController`,
        // so the condition was effectively always true; keep posting on every selection.
        NotificationCenter.default.post(name: .favLanUpdated, object: nil)
        print("✅ Posted favLanUpdated when switching tabs")
        prepareTabsCycle(reason: "didSelect")
    }
}

@available(iOS 16.0, *)
enum MainTab: Int, CaseIterable, Hashable {
    case home = 0
    case discovery = 1
    case exercises = 2
    case rewards = 3
}
