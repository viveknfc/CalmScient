//
//  MainTabBarView.swift
//  Calmscient
//
//  SwiftUI shell for the main application tab bar (legacy UIKit content per tab).
//
//  Vivek
//  14 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct MainTabBarView: View {

    @ObservedObject var viewModel: MainTabBarViewModel

    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            tabPage(.home)
            tabPage(.discovery)
            tabPage(.exercises)
            tabPage(.rewards)
        }
        .onChange(of: viewModel.selectedTab) { newValue in
            viewModel.userSelectedTab(newValue)
        }
    }

    @ViewBuilder
    private func tabPage(_ tab: MainTab) -> some View {
        let rewardsUnselected = "MainTab_Rewards_UnSelected"
        let rewardsSelected = "MainTab_Rewards_Selected"
        let unselectedName = tab == .rewards ? rewardsUnselected : tab.defaultUnselectedImageName
        let selectedName = tab == .rewards ? rewardsSelected : tab.defaultSelectedImageName

        Group {
            if tab == .rewards {
                // Migrated to a native SwiftUI `NavigationStack` — no UIKit
                // navigation controller for this tab.
                RewardsTabView(navigationTitle: viewModel.title(for: tab))
            } else if tab == .exercises {
                ExercisesTabView(
                    navigationTitle: viewModel.title(for: tab),
                    rootResetToken: viewModel.tabRootResetToken
                )
            } else if tab == .home {
                // The representable deliberately passed an empty navigation title for
                // home (`tab == .home ? "" : …`), and the dashboard controller set none.
                HomeTabView(
                    navigationTitle: "",
                    showMedicationsAsHome: viewModel.useMedicationsForFirstTab,
                    rootResetToken: viewModel.tabRootResetToken
                )
            } else {
                MainTabStoryboardHost(
                    generation: viewModel.contentGeneration,
                    tab: tab,
                    navigationTitle: viewModel.title(for: tab),
                    tabTitle: viewModel.title(for: tab),
                    tabImageUnselectedName: unselectedName,
                    tabImageSelectedName: selectedName
                )
                .modifier(DiscoveryTabFullWidthTopModifier(isDiscoveryTab: tab == .discovery))
            }
        }
        .id(pageIdentity(for: tab))
        .tabItem {
            if let img = UIImage(named: unselectedName) {
                Image(uiImage: img)
            }
            Text(viewModel.title(for: tab))
        }
        .tag(tab)
    }

    /// The UIKit-backed tab keeps the legacy "rebuild the whole stack" identity, because a
    /// `UINavigationController` inside a representable is what `prepareTabs()` used to
    /// replace. The native tabs must stay identity-stable: re-creating their
    /// `NavigationStack` during a `TabView` transition left two `UIKitNavigationBar`s
    /// fighting over one `UINavigationItem` and crashed UIKit's layout pass. They pop back
    /// to their root via `tabRootResetToken` instead (see `MainTabBarViewModel`).
    private func pageIdentity(for tab: MainTab) -> String {
        tab.usesStoryboardHost
            ? "\(tab.rawValue)-\(viewModel.contentGeneration)"
            : "\(tab.rawValue)"
    }
}

/// Discovery tab UIKit nav stack must extend under the status bar (SwiftUI `TabView` insets it by default).
@available(iOS 16.0, *)
private struct DiscoveryTabFullWidthTopModifier: ViewModifier {
    let isDiscoveryTab: Bool

    func body(content: Content) -> some View {
        if isDiscoveryTab {
            content.ignoresSafeArea(.container, edges: .top)
        } else {
            content
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Main tab bar") {
    MainTabBarView(viewModel: MainTabBarViewModel())
}
#endif
