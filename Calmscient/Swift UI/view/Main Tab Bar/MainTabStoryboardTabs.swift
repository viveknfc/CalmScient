//
//  MainTabStoryboardTabs.swift
//  Calmscient
//
//  UIKit storyboard tabs embedded in SwiftUI via UIViewControllerRepresentable.
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit

@available(iOS 16.0, *)
enum MainTabBarAppearance {
    static func apply() {
        let tabBarItemAppearance = UITabBarItemAppearance()
        tabBarItemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(named: "TabBarUnSelectedColor")!,
            .font: UIFont(name: Fonts().lexendRegular, size: 12)!,
        ]
        tabBarItemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(named: "TabBarSelectedColor")!,
            .font: UIFont(name: Fonts().lexendRegular, size: 12)!,
        ]
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(named: "TabBarBackgroundColor")
        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
}

private let mainTabSelectedImages = [
    "MainTab_Home_Selected", "MainTab_Discovery_Selected", "MainTab_Exercises_Selected", "MainTab_Rewards_Selected",
]
private let mainTabUnselectedImages = [
    "MainTab_Home_Unselected", "MainTab_Discovery_Unselected", "MainTab_Exercises_Unselected", "MainTab_Rewards_UnSelected",
]

/// The remaining UIKit-backed tab (Discovery).
///
/// Home, Exercises and Rewards are native SwiftUI (`HomeTabView`, `ExercisesTabView`,
/// `RewardsTabView`); their cases used to live here behind `assertionFailure`, which was
/// unreachable code that would have trapped in debug if it were ever hit.
@available(iOS 16.0, *)
struct MainTabStoryboardHost: UIViewControllerRepresentable {

    var generation: Int
    let tab: MainTab
    let navigationTitle: String
    let tabTitle: String
    let tabImageUnselectedName: String
    let tabImageSelectedName: String

    func makeUIViewController(context: Context) -> UINavigationController {
        let nav = UINavigationController(rootViewController: DiscoveryMainHostingController())

        if !navigationTitle.isEmpty {
            nav.title = navigationTitle
            nav.viewControllers.first?.title = navigationTitle
        }

        let icon = UITabBarItem(
            title: tabTitle,
            image: UIImage(named: tabImageUnselectedName),
            selectedImage: UIImage(named: tabImageSelectedName)
        )
        nav.tabBarItem = icon
        _ = generation
        print("Tab bar item title: \(nav.tabBarItem.title ?? "No title")")
        return nav
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        uiViewController.tabBarItem.title = tabTitle
    }
}

@available(iOS 16.0, *)
extension MainTab {
    var defaultUnselectedImageName: String { mainTabUnselectedImages[rawValue] }
    var defaultSelectedImageName: String { mainTabSelectedImages[rawValue] }

    /// `true` only for tabs still rendered by `MainTabStoryboardHost`. Those are the only
    /// pages `MainTabBarView` may key on `contentGeneration`; see `pageIdentity(for:)`.
    var usesStoryboardHost: Bool { self == .discovery }
}
