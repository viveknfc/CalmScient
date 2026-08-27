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
    ///
    /// Read by the UIKit-backed tab only (`MainTabStoryboardHost`, i.e. Discovery), whose
    /// `UINavigationController` still has to be rebuilt the way `prepareTabs()` did.
    ///
    /// It must NOT key the three native SwiftUI tabs. `MainTabBarView` used to include it
    /// in the `.id(...)` of *every* tab page, so a tab tap tore down and re-created each
    /// tab's `NavigationStack` in the middle of the `TabView` transition. Two
    /// `SwiftUI.UIKitNavigationBar`s then existed for the same tab, the new one adopted
    /// the outgoing bar's `UINavigationItem`, and the still-visible old bar crashed with
    /// "Layout requested for visible navigation bar … when the top item belongs to a
    /// different navigation bar (possibly from a client attempt to nest wrapped
    /// navigation controllers)".
    @Published private(set) var contentGeneration: Int = 0
    /// Bumped on every *user* tab selection so the native tabs pop back to their root.
    ///
    /// The blanket rebuild above used to do this as a side effect. The native tabs now
    /// keep their identity and clear their `NavigationStack` path instead, which is the
    /// same user-visible behaviour without recreating any navigation bar.
    @Published private(set) var tabRootResetToken: Int = 0
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
    ///
    /// Publishes only when the titles actually changed. This runs on every appearance,
    /// every tab switch and every `languageChanged` notification, so re-publishing the
    /// identical array both re-rendered the whole tab bar and — whenever the caller sat
    /// inside a SwiftUI view update — logged "Publishing changes from within view updates
    /// is not allowed".
    func refreshLocalizedTabTitles() {
        let titles = mainTabBarTitleKeys.map { $0.localized }
        tabTitles = titles
        guard localizedTitles != titles else { return }
        localizedTitles = titles
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

    /// Entry point for `MainTabBarView`'s `onChange(of:)`.
    ///
    /// SwiftUI delivers `onChange` inside the view update that changed the selection, and
    /// the work below publishes (`contentGeneration`, `localizedTitles`) and posts a
    /// notification observers answer by publishing too — all of which SwiftUI rejects
    /// mid-update. Scheduling a new main-actor turn runs the identical sequence right
    /// after the update finishes.
    func userSelectedTab(_ tab: MainTab) {
        Task { @MainActor [weak self] in
            self?.onUserSelectedTab(tab)
        }
    }

    /// Legacy `tabBarController(_:didSelect:)` side effects + full tab rebuild.
    func onUserSelectedTab(_ tab: MainTab) {
        print("Tab bar selecting from here")
        isInitalView = false
        // Legacy compared the tab root (always a `UINavigationController`) to `FavoritesVideosWebViewController`,
        // so the condition was effectively always true; keep posting on every selection.
        //
        // Tagged so the dashboard refreshes favourites *silently*. The refresh itself is
        // unchanged — only the blocking spinner is dropped, because a tab switch is a
        // background top-up rather than the user asking to reload. See the origin note in
        // `FavouritesGeneralManager`.
        NotificationCenter.default.post(
            name: .favLanUpdated,
            object: nil,
            userInfo: FavLanUpdate.tabSwitchUserInfo
        )
        print("✅ Posted favLanUpdated when switching tabs")
        prepareTabsCycle(reason: "didSelect")
        // Replaces the native-tab teardown that `contentGeneration` used to force: each
        // native tab reopens at its root, but its `NavigationStack` (and therefore its
        // navigation bar) is never destroyed. `selectedTab` only ever changes from the
        // `TabView`, so this really is a user selection.
        tabRootResetToken &+= 1
    }
}

@available(iOS 16.0, *)
enum MainTab: Int, CaseIterable, Hashable {
    case home = 0
    case discovery = 1
    case exercises = 2
    case rewards = 3
}
