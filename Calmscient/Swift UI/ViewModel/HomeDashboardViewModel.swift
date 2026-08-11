//
//  HomeDashboardViewModel.swift
//  Calmscient
//
//  State and navigation for the SwiftUI home dashboard (replaces storyboard-driven logic).
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class HomeDashboardViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var favorites: [[String: Any]] = []
    @Published private(set) var myFavoritesSectionTitle: String = ""
    @Published private(set) var emptyFavoritesMessage: String = ""
    @Published private(set) var needToTalkButtonTitle: String = ""
    @Published private(set) var menuRows: [(title: String, imageName: String)] = []

    var firstName: String {
        ApplicationSharedInfo.shared.loginResponse?.firstName ?? ""
    }

    init() {
        reloadLocalizedChrome()
    }

    func reloadLocalizedChrome() {
        myFavoritesSectionTitle = AppHelper.getLocalizeString(str: "My Favorites")
        emptyFavoritesMessage = AppHelper.getLocalizeString(str: "No favorites found for this patient")
        needToTalkButtonTitle = AppHelper.getLocalizeString(str: "Need to talk with someone?")
        menuRows = [
            ("My medical records".localized, "MyMedicalRecordsIcon"),
            ("Weekly summary".localized, "weeklySummay1"),
            ("Mental wellbeing tracker".localized, "mentalWellbeing"),
        ]
    }

    func syncFavoritesFromManager() {
        favorites = FavoriteManager.shared.favorites
    }

    func initialLoad() {
        syncFavoritesFromManager()
        checkTokenAndFetchFavoritesIfNeeded()
    }

    func onHostWillAppear() {
        reloadLocalizedChrome()
        syncFavoritesFromManager()
        NotificationCenter.default.post(name: .languageChanged, object: nil)
    }

    private func checkTokenAndFetchFavoritesIfNeeded() {
        let hasFetchedFavorites = UserDefaults.standard.bool(forKey: "hasFetchedFavorites")

        if TokenManager.shared.isTokenExpired() {
            TokenManager.shared.refreshAccessToken(from: hostViewController) { [weak self] success in
                DispatchQueue.main.async {
                    guard let self else { return }
                    if success {
                        if !hasFetchedFavorites { self.fetchFavoritesFromNetwork() }
                    } else {
                        self.handleTokenFailure()
                    }
                }
            }
        } else {
            if !hasFetchedFavorites { fetchFavoritesFromNetwork() }
        }
    }

    private func handleTokenFailure() {
        UserDefaults.standard.set(0, forKey: "rememberMe")
        UserDefaultsHelper.clearLoginDetailsFromUserDefaults()
        ApplicationSharedInfo.shared.loginResponse = nil
        ApplicationSharedInfo.shared.tokenResponse = nil

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            let navController = LoginHostingController.loginNavigationRoot()
            sceneDelegate.changeRootViewController(to: navController)
        }
    }

    func fetchFavoritesFromNetwork(showsToast: Bool = true, completion: (() -> Void)? = nil) {
        if showsToast { hostViewController?.view.showToastActivity() }
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            hostViewController?.view.hideToastActivity()
            completion?()
            return
        }

        FavoriteManager.shared.fetchFavoritesIfNeeded(
            plId: userInfo.patientLocationID,
            patientId: userInfo.patientID,
            clientId: userInfo.clientID,
            parentId: 0
        ) { [weak self] in
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: "hasFetchedFavorites")
                self?.syncFavoritesFromManager()
                self?.hostViewController?.view.hideToastActivity()
                completion?()
            }
        }
    }

    /// Pull-to-refresh entry point. Force-fetches favorites and completes when
    /// the response returns so the refresh spinner ends correctly.
    func refresh() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            Task { @MainActor in
                fetchFavoritesFromNetwork(showsToast: false) {
                    continuation.resume()
                }
            }
        }
    }

    func openProfile() {
        guard let nav = hostViewController?.navigationController else { return }
        let profile = UserProfileHostingController()
        UserDefaults.standard.removeObject(forKey: "shouldPopToDis")
        nav.pushViewController(profile, animated: true)
    }

    func openNeedToTalk() {
        guard let nav = hostViewController?.navigationController else { return }
        let next = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController
        vc?.title = "Emergency resource"
        if let vc { nav.pushViewController(vc, animated: true) }
    }

    func openMenuRow(at index: Int) {
        guard let nav = hostViewController?.navigationController else { return }
        switch index {
        case 0:
            let vc = UserMedicalRecordsHostingController()
            nav.pushViewController(vc, animated: true)
        case 1:
            nav.pushViewController(WeeklySummaryDashboardHostingController(), animated: true)
        case 2:
            let vc = DayFeedbackHostingController(
                hideSkipButton: true,
                dashboardNavigationTitle: "Mental wellbeing tracker".localized
            )
            nav.pushViewController(vc, animated: true)
        default:
            break
        }
    }

    func openHealthMetrics() {
        guard let nav = hostViewController?.navigationController else { return }
        nav.pushViewController(HealthMetricsHostingController(), animated: true)
    }

    func openFavorite(_ item: [String: Any]) {
        guard let nav = hostViewController?.navigationController else { return }

        if let favoritesId = item["favoritesId"] as? Int,
           let patientFavoriteId = item["favoritesId"] as? Int,
           favoritesId == patientFavoriteId,
           let navigateURL = item["navigateURL"] as? String {
            let next = UIStoryboard(name: "FavoritesVideosWebViewController", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "FavoritesVideosWebViewController") as? FavoritesVideosWebViewController
            vc?.favURL = navigateURL
            vc?.title = localizedFavoriteTitle(for: item)
            if let vc { nav.pushViewController(vc, animated: true) }
        }

        let isExercise = (item["isFromExercises"] as? Int) == 1 || (item["isFromExcercise"] as? Int) == 1
        if isExercise, let screenCode = item["screenCode"] as? Int,
           let exerciseType = ExcercisesTypeEnum(rawValue: screenCode) {
            nav.pushViewController(exerciseType.destVC, animated: true)
        }
    }

    func thumbnailURL(for item: [String: Any]) -> URL? {
        let s = (item["thumbnailUrl"] as? String) ?? (item["thumbnail"] as? String)
        guard let s, let url = URL(string: s) else { return nil }
        return url
    }

    func localizedFavoriteTitle(for item: [String: Any]) -> String {
        guard let rawTitle = item["title"] as? String, !rawTitle.isEmpty else { return "" }
        return AppHelper.getLocalizeString(str: rawTitle)
    }
}
