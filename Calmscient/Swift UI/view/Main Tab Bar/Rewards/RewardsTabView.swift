//
//  RewardsTabView.swift
//  Calmscient
//
//  Native SwiftUI Rewards tab — the first tab migrated off `MainTabStoryboardHost`.
//
//  Replaces this chain:
//      MainTabStoryboardHost (UIViewControllerRepresentable)
//        └─ UINavigationController
//             └─ TestViewController4 (UIViewController)
//                  └─ UIHostingController<TestViewController4View>
//  with a plain `NavigationStack` around the same SwiftUI content.
//
//  Parity notes:
//   • `nav.title` / `viewControllers.first?.title` → `.navigationTitle(...)`. The title
//     font matches because `AppDelegate` sets `UINavigationBar.appearance()`
//     titleTextAttributes globally, which `NavigationStack` also picks up.
//   • `.inline` display mode matches `UINavigationController`'s default
//     (`prefersLargeTitles` was never enabled).
//   • The tab bar item itself is unchanged — it has always come from SwiftUI's
//     `.tabItem` in `MainTabBarView`, not from `nav.tabBarItem`.
//   • `MainTabBarView` gives this view a *stable* identity. It briefly keyed every tab
//     page on `contentGeneration`, which is bumped on every tab tap — that destroyed and
//     re-created this `NavigationStack` mid-transition, so two `UIKitNavigationBar`s
//     ended up sharing one `UINavigationItem` and UIKit trapped with "Layout requested
//     for visible navigation bar … when the top item belongs to a different navigation
//     bar". The navigation title is a plain parameter, so a language change relocalizes
//     it through an ordinary view update instead of a rebuild.
//

import SwiftUI

@available(iOS 16.0, *)
struct RewardsTabView: View {

    let navigationTitle: String

    @StateObject private var viewModel = TestViewController4ViewModel()

    var body: some View {
        NavigationStack {
            TestViewController4View(viewModel: viewModel)
                .navigationTitle(navigationTitle)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Rewards tab") {
    RewardsTabView(navigationTitle: "Rewards")
}
#endif
