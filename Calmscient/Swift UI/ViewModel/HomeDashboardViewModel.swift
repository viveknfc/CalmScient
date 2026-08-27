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

    // MARK: - SwiftUI navigation
    //
    // Set by `HomeTabView` when this screen is shown inside the Home `NavigationStack`.
    // While nil, every call below falls through to the existing UIKit push/pop, which is
    // what the still-UIKit Discovery tab uses when it pushes into these screens.
    var onOpenRoute: ((HomeRoute) -> Void)?
    var onClose: (() -> Void)?
    var onCloseToRoot: (() -> Void)?

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

    // MARK: - Publishing
    //
    // `reloadLocalizedChrome()` and `syncFavoritesFromManager()` are refresh calls: they
    // run on every appearance and on every favorites/language notification, and almost
    // always recompute values identical to the ones already published. Assigning anyway
    // fired `objectWillChange` for no reason — and when the caller happened to be inside a
    // SwiftUI view update (UIKit appearance callbacks bridged into the `NavigationStack`
    // are), that redundant publish is what logged "Publishing changes from within view
    // updates is not allowed". Only publishing real changes removes those and spares the
    // dashboard a full re-render on every appearance.

    func reloadLocalizedChrome() {
        // Compared and assigned property by property: passing a `@Published` property
        // `inout` would write it back on return even when the helper changed nothing,
        // which publishes anyway.
        let favoritesTitle = AppHelper.getLocalizeString(str: "My Favorites")
        if myFavoritesSectionTitle != favoritesTitle { myFavoritesSectionTitle = favoritesTitle }

        let emptyMessage = AppHelper.getLocalizeString(str: "No favorites found for this patient")
        if emptyFavoritesMessage != emptyMessage { emptyFavoritesMessage = emptyMessage }

        let needToTalkTitle = AppHelper.getLocalizeString(str: "Need to talk with someone?")
        if needToTalkButtonTitle != needToTalkTitle { needToTalkButtonTitle = needToTalkTitle }

        let rows = [
            ("My medical records".localized, "MyMedicalRecordsIcon"),
            ("Weekly summary".localized, "weeklySummay1"),
            ("Mental wellbeing tracker".localized, "mentalWellbeing")
//            ("Health Metrics".localized, "NotePad")
        ]
        if !Self.menuRowsMatch(menuRows, rows) {
            menuRows = rows
        }
    }

    func syncFavoritesFromManager() {
        let latest = FavoriteManager.shared.favorites
        guard !Self.favoritesMatch(favorites, latest) else { return }
        favorites = latest
    }

    private static func menuRowsMatch(
        _ lhs: [(title: String, imageName: String)],
        _ rhs: [(title: String, imageName: String)]
    ) -> Bool {
        guard lhs.count == rhs.count else { return false }
        return !zip(lhs, rhs).contains { $0.title != $1.title || $0.imageName != $1.imageName }
    }

    /// `[[String: Any]]` is not `Equatable`; the payload is decoded JSON, so bridging to
    /// `NSArray` compares it correctly. A false negative only costs the publish that
    /// happened unconditionally before, so this can never drop a real update.
    private static func favoritesMatch(_ lhs: [[String: Any]], _ rhs: [[String: Any]]) -> Bool {
        guard lhs.count == rhs.count else { return false }
        return (lhs as NSArray).isEqual(to: rhs)
    }

    func initialLoad() {
        syncFavoritesFromManager()
        checkTokenAndFetchFavoritesIfNeeded()
    }

    func onHostWillAppear() {
        reloadLocalizedChrome()
        syncFavoritesFromManager()
        NotificationCenter.default.post(name: .languageChanged, object: nil)

        // Patients who never open Health Metrics are precisely the ones background sync exists
        // for, and until now nothing ever asked them for HealthKit access. The prompt gates itself
        // on whether asking would achieve anything, so for everyone else this call does nothing.
//        HealthAccessPrompt.presentIfNeeded(from: hostViewController) // viv commented to remove the health kit aleert
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

    /// True only while this screen has a spinner of its own on screen.
    ///
    /// A silent refresh (pull-to-refresh, or the dashboard reload that follows a Settings
    /// language change) must not take down a spinner another screen owns — hiding is
    /// tracked app-wide, so an unconditional hide here used to kill it.
    private var ownsFavoritesActivity = false

    /// Hides the favorites spinner only when this screen is the one that showed it.
    func hideFavoritesActivityIfOwned() {
        guard ownsFavoritesActivity else { return }
        ownsFavoritesActivity = false
        hostViewController?.view.hideToastActivity()
    }

    func fetchFavoritesFromNetwork(showsToast: Bool = true, completion: (() -> Void)? = nil) {
        if showsToast {
            ownsFavoritesActivity = true
            hostViewController?.view.showToastActivity()
        }
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            hideFavoritesActivityIfOwned()
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
                self?.hideFavoritesActivityIfOwned()
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
        if let onOpenRoute {
            UserDefaults.standard.removeObject(forKey: "shouldPopToDis")
            onOpenRoute(.userProfile)
            return
        }
        guard let nav = hostViewController?.navigationController else { return }
        let profile = UserProfileHostingController()
        UserDefaults.standard.removeObject(forKey: "shouldPopToDis")
        nav.pushViewController(profile, animated: true)
    }

    func openNeedToTalk() {
        if let onOpenRoute {
            onOpenRoute(.needToTalk)
            return
        }
        guard let host = hostViewController else { return }
        NeedToTalkNavigation.push(from: host)
    }

    func openMenuRow(at index: Int) {
        if let onOpenRoute {
            switch index {
            case 0: onOpenRoute(.userMedicalRecords)
            case 1: onOpenRoute(.weeklySummaryDashboard)
            case 2: onOpenRoute(.dayFeedback(
                hideSkipButton: true,
                dashboardNavigationTitle: "Mental wellbeing tracker".localized))
            case 3: onOpenRoute(.healthMetrics)
            default: break
            }
            return
        }
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
        case 3:
            nav.pushViewController(HealthMetricsHostingController(), animated: true)
        default:
            break
        }
    }

    func openFavorite(_ item: [String: Any]) {
        let isExerciseFavorite = (item["isFromExercises"] as? Int) == 1
            || (item["isFromExcercise"] as? Int) == 1

        if let onOpenRoute {
            if let favoritesId = item["favoritesId"] as? Int,
               let patientFavoriteId = item["favoritesId"] as? Int,
               favoritesId == patientFavoriteId,
               let navigateURL = item["navigateURL"] as? String {
                onOpenRoute(.favoritesWeb(
                    urlString: navigateURL,
                    title: localizedFavoriteTitle(for: item)
                ))
            }
            if isExerciseFavorite,
               let screenCode = item["screenCode"] as? Int,
               let exerciseType = ExcercisesTypeEnum(rawValue: screenCode) {
                onOpenRoute(.exercise(ExercisesRoute(exercise: exerciseType)))
            }
            return
        }

        guard let host = hostViewController, let nav = host.navigationController else { return }

        if let favoritesId = item["favoritesId"] as? Int,
           let patientFavoriteId = item["favoritesId"] as? Int,
           favoritesId == patientFavoriteId,
           let navigateURL = item["navigateURL"] as? String {
            FavoritesVideosWebNavigation.push(
                urlString: navigateURL,
                title: localizedFavoriteTitle(for: item),
                from: host
            )
        }

        let isExercise = (item["isFromExercises"] as? Int) == 1 || (item["isFromExcercise"] as? Int) == 1
        if isExercise, let screenCode = item["screenCode"] as? Int,
           let exerciseType = ExcercisesTypeEnum(rawValue: screenCode) {
            nav.pushViewController(exerciseType.destVC, animated: true)
        }
    }

    /// The favourite's thumbnail, or `nil` when it has none the tile could ever load.
    ///
    /// `URL(string:)` alone is far too permissive: it happily returns a *relative* URL for
    /// a blank-ish value, a bare filename or a stray `"null"`, all of which the server does
    /// send for favourites that have no real thumbnail (exercise favourites in particular).
    /// The tile then started a request that could only fail, and `AsyncImage` sat in
    /// `.failure` — which used to render a spinner, so those tiles turned forever.
    ///
    /// Only absolute `http`/`https` URLs with a host survive, so an unusable value now
    /// takes the same "no thumbnail" path as a missing key and the tile renders as the
    /// plain placeholder. Any value that previously produced a working URL is unchanged.
    func thumbnailURL(for item: [String: Any]) -> URL? {
        let raw = (item["thumbnailUrl"] as? String) ?? (item["thumbnail"] as? String)
        guard let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty,
              let url = URL(string: trimmed),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              let host = url.host,
              !host.isEmpty
        else { return nil }
        return url
    }

    /// Bundled artwork for a favorite the server sent no usable `thumbnailUrl` for.
    ///
    /// Only exercise favorites can be resolved: `ExerciseFavoriteToggle` never sends a
    /// thumbnail, so the backend has to derive one, and for the rows it cannot resolve the
    /// tile had nothing at all to draw. `screenCode` is the same key `openFavorite` routes
    /// on; when it is missing the stored title is matched instead, exactly as
    /// `localizedFavoriteTitle(for:)` does. Video and article favorites return `nil` and
    /// keep the plain placeholder they have always shown.
    func fallbackThumbnailAssetName(for item: [String: Any]) -> String? {
        guard Self.isExerciseFavorite(item) else { return nil }

        if let screenCode = item["screenCode"] as? Int,
           let exercise = ExcercisesTypeEnum(rawValue: screenCode) {
            return exercise.favoriteThumbnailAssetName
        }
        if let rawTitle = item["title"] as? String,
           let exercise = ExcercisesTypeEnum.matching(serverTitle: rawTitle) {
            return exercise.favoriteThumbnailAssetName
        }
        return nil
    }

    /// The server has spelled this flag both ways; `openFavorite` and the title lookup
    /// already accept either, so the artwork lookup has to agree with them.
    private static func isExerciseFavorite(_ item: [String: Any]) -> Bool {
        (item["isFromExercises"] as? Int) == 1 || (item["isFromExcercise"] as? Int) == 1
    }

    func localizedFavoriteTitle(for item: [String: Any]) -> String {
        guard let rawTitle = item["title"] as? String, !rawTitle.isEmpty else { return "" }
        return AppHelper.getLocalizeString(str: Self.localizationKey(forFavorite: item, rawTitle: rawTitle))
    }

    /// Maps a favorite onto the `Localizable.strings` key that actually translates it.
    ///
    /// Favorites carry the title the *server* stored, which for exercises is
    /// `ExcercisesTypeEnum.addFavCode` — an API contract string that differs from the
    /// localization key by case or punctuation ("Movement: Dance" vs "Movement: dance",
    /// "BreathingTechnique" vs "Breathing technique"). `NSLocalizedString` matches keys
    /// exactly, so those titles missed the table and `AppHelper` fell back to returning
    /// the key itself — the tile stayed English after a language switch even though the
    /// exercise page it opens, which localizes its own key, translated correctly.
    ///
    /// Exercise favorites carry the `screenCode` identifying the exercise, so the
    /// canonical key comes from there; the stored title is only matched when no usable
    /// code came back. Every other favorite (videos, articles) localizes exactly as
    /// before.
    private static func localizationKey(forFavorite item: [String: Any], rawTitle: String) -> String {
        let isExerciseFavorite = (item["isFromExercises"] as? Int) == 1
            || (item["isFromExcercise"] as? Int) == 1

        if isExerciseFavorite,
           let screenCode = item["screenCode"] as? Int,
           let exercise = ExcercisesTypeEnum(rawValue: screenCode) {
            return exercise.localizedTitleKey
        }

        // No usable `screenCode`: fall back to recognising the stored title itself.
        // The comparison is against the exercise API titles only, so a video or article
        // that happens to reach here keeps its own title untouched.
        return ExcercisesTypeEnum.localizedTitleKey(forServerTitle: rawTitle) ?? rawTitle
    }
}
