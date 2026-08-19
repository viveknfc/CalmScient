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
//   • `MainTabBarView` keys this view on `contentGeneration`, so a language change
//     rebuilds it — the same effect the old representable got by rebuilding its
//     navigation controller.
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
