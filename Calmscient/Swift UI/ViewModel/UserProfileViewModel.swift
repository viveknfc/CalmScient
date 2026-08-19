//
//  UserProfileViewModel.swift
//  Calmscient
//
//  Settings / profile screen state and networking (parity with legacy UserProfileViewController).
//
//  Vivek
//  14 May 2026
//
import Foundation
import SwiftUI
import UIKit
import UserNotifications

@MainActor
final class UserProfileViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    // MARK: - SwiftUI navigation
    //
    // Set by `HomeTabView` when this screen is shown inside the Home `NavigationStack`.
    // While nil, every call below falls through to the existing UIKit push/pop, which is
    // what the still-UIKit Discovery tab uses when it pushes into these screens.
    var onOpenRoute: ((HomeRoute) -> Void)?
    var onClose: (() -> Void)?
    var onCloseToRoot: (() -> Void)?

    private var profileHost: UserProfileHostingController? {
        hostViewController as? UserProfileHostingController
    }

    // MARK: - Sheet scrim / picker delegate
    //
    // The legacy flow leaned on `UserProfileHostingController` for the dimming overlay and
    // as the image-picker delegate. Inside the SwiftUI Home stack the host is a plain
    // container, so the view model owns both itself.

    private var fallbackDimmingView: UIView?
    private var removeDimmingObserver: NSObjectProtocol?
    private lazy var imagePickerProxy: ProfileImagePickerProxy = {
        let proxy = ProfileImagePickerProxy()
        proxy.viewModel = self
        return proxy
    }()

    private func addDimmingOverlay() {
        if let profileHost {
            profileHost.addDimmingView()
            return
        }
        guard fallbackDimmingView == nil,
              let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive })?
                .windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(overlay)
        fallbackDimmingView = overlay
    }

    private func removeDimmingOverlay() {
        profileHost?.removeDimmingViewIfNeeded()
        fallbackDimmingView?.removeFromSuperview()
        fallbackDimmingView = nil
    }

    /// The privacy / alarm sheets post this when they close.
    private func startObservingDimmingDismissalIfNeeded() {
        guard removeDimmingObserver == nil else { return }
        removeDimmingObserver = NotificationCenter.default.addObserver(
            forName: Notification.Name("RemoveDimmingView"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.removeDimmingOverlay() }
        }
    }

    /// When true, back pops this screen instead of navigating home.
    var shouldPopBack: Bool = false

    @Published private(set) var profileImage: UIImage?
    @Published private(set) var languagesData: [[String: Any]] = []
    @Published private(set) var cellTitles: [String] = []
    @Published private(set) var licenseKey: String = ""
    @Published private(set) var alarmMinutes: Int = 0

    /// Observes app-wide connectivity so Settings reloads once the connection returns.
    private var networkObserver: NSObjectProtocol?
    private var isObservingNetwork = false

    private let profileSvgIcons = [
        "profile_svg", "language_svg", "privacy_svg", "alarm_svg",
        "notification_svg", "license_svg", "helpNsupport_svg", "logout_svg",
    ]

    var versionLabelText: String {
        AppHelper.getLocalizeString(str: "Version 1.0.1")
    }

    deinit {
        if let networkObserver {
            NotificationCenter.default.removeObserver(networkObserver)
        }
    }

    func onAppear() {
        reloadLocalizedChrome()
        startObservingDimmingDismissalIfNeeded()
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            populateSwiftUIPreviewSampleDataIfNeeded()
            return
        }
        startObservingNetworkIfNeeded()
        loadInitialData()
    }

    /// Pull-to-refresh entry point. Reloads settings and completes when the
    /// profile-settings response returns, so the refresh spinner ends correctly.
    func refresh() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            loadInitialData(showsToast: false) {
                continuation.resume()
            }
        }
    }

    // MARK: - Network restore

    private func startObservingNetworkIfNeeded() {
        guard !isObservingNetwork else { return }
        isObservingNetwork = true

        networkObserver = NotificationCenter.default.addObserver(
            forName: .networkStatusChanged,
            object: nil,
            queue: .main
        ) { [weak self] note in
            let connected = (note.object as? Bool) ?? NetworkMonitor.shared.isConnected
            guard connected else { return }
            Task { @MainActor in
                self?.reloadIfDataMissing()
            }
        }
    }

    /// When the connection returns, reload only if the earlier (offline) attempt
    /// left the screen without content — avoids unnecessary refetches.
    private func reloadIfDataMissing() {
        if cellTitles.isEmpty {
            loadInitialData()
        }
    }

    /// Fills list + language chips for Xcode SwiftUI previews only (no API calls).
    private func populateSwiftUIPreviewSampleDataIfNeeded() {
        guard cellTitles.isEmpty else { return }
        cellTitles = [
            "Profile", "Language", "Privacy", "Alarm settings",
            "Notifications", "License Key", "Help & Support", "Logout",
        ]
        languagesData = [
            ["languageId": 1, "languageName": "English", "preferred": 1, "flagUrl": ""],
            ["languageId": 2, "languageName": "Spanish", "preferred": 0, "flagUrl": ""],
            ["languageId": 6, "languageName": "Japanese", "preferred": 0, "flagUrl": ""],
            ["languageId": 7, "languageName": "ASL", "preferred": 0, "flagUrl": ""],
        ]
        licenseKey = "PREVIEW-LICENSE-KEY"
        alarmMinutes = 15
    }

    func reloadLocalizedChrome() {
        // Titles come from API; alarm row uses localized fallback like legacy.
        _ = "Alarm settings".localized
    }

    func rowAssetName(at index: Int) -> String {
        guard index >= 0, index < profileSvgIcons.count else { return "profile_svg" }
        return profileSvgIcons[index]
    }

    func presentPhotoOptions() {
        guard let host = hostViewController else { return }
        let alert = UIAlertController(
            title: "Profile Picture",
            message: "Choose an option",
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: "Choose Photo", style: .default) { [weak self] _ in
            self?.hostViewController?.view.showToastActivity()
            self?.requestPhotoLibraryPicker(from: host)
        })
        alert.addAction(UIAlertAction(title: "Delete Photo", style: .destructive) { [weak self] _ in
            self?.deleteProfilePicture()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        host.present(alert, animated: true)
    }

    func handleRowTap(at index: Int) {
        // NOTE: no `guard let nav` up here — rows 2/3/5/7 present rather than push, and
        // on the SwiftUI path there is no navigation controller at all.
        switch index {
        case 0:
            if let onOpenRoute {
                onOpenRoute(.patientProfileEdit)
                return
            }
            if #available(iOS 16.0, *),
               let nav = hostViewController?.navigationController {
                let next = PatientProfileEditHostingController()
                nav.pushViewController(next, animated: true)
            }
        case 2:
            presentPrivacySheet()
        case 3:
            presentAlarmSheet()
        case 5:
            let alert = UIAlertController(
                title: "License Key".localized,
                message: licenseKey,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
            hostViewController?.present(alert, animated: true)
        case 7:
            presentLogoutConfirmation()
        default:
            break
        }
    }

    func selectLanguage(languageName: String) {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }

        guard let resolved = resolveLanguageRow(languageName: languageName) else {
            return
        }

        let previousLanguageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        let previousAppLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        let previousDisplayName = UserDefaults.standard.string(forKey: PatientLanguagePreference.displayNameUserDefaultsKey)

        // Update chip selection immediately so the UI does not wait on the network or refresh cycle.
        markLanguagePreferredLocally(resolved.canonicalName)

        addDimmingOverlay()
        // Same anchor `loadInitialData` uses, so the reload below reuses this one
        // spinner instead of adding a second one on a different view.
        anchorView?.showToastActivity()

        PatientLanguagePreference.persistProfileSelection(
            canonicalDisplayName: resolved.canonicalName,
            languageId: resolved.languageId
        )

        NotificationCenter.default.post(name: .languageChanged, object: nil)

        let params: [String: Any] = [
            "patientId": userInfo.patientID,
            "clientId": userInfo.clientID,
            "languageId": resolved.languageId,
            "flag": 1,
        ]
        APIService.updateUserLanguageAPICalling(
            hostViewController,
            params: params,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                guard let self else { return }
                if self.isUpdateUserLanguageSuccess(response) {
                    NotificationCenter.default.post(
                        name: .favLanUpdated,
                        object: nil,
                        userInfo: FavLanUpdate.languageChangeUserInfo
                    )
                    self.removeDimmingOverlay()
                    // Keep the spinner running into `loadInitialData` so there is no dead gap;
                    // `loadInitialData` hides it when profile settings return.
                    self.loadInitialData()
                } else {
                    self.removeDimmingOverlay()
                    UserDefaults.standard.set(previousLanguageId, forKey: "SelectedLanguageID")
                    UserDefaults.standard.set(previousAppLanguage, forKey: "appLanguage")
                    Bundle.setLanguage(previousAppLanguage)
                    if let previousDisplayName {
                        UserDefaults.standard.set(previousDisplayName, forKey: PatientLanguagePreference.displayNameUserDefaultsKey)
                    } else {
                        let revertId = previousLanguageId != 0 ? previousLanguageId : 1
                        UserDefaults.standard.set(
                            PatientLanguagePreference.displayName(forLanguageId: revertId),
                            forKey: PatientLanguagePreference.displayNameUserDefaultsKey
                        )
                    }
                    NotificationCenter.default.post(name: .languageChanged, object: nil)
                    let revertId = previousLanguageId != 0 ? previousLanguageId : 1
                    let revertName = previousDisplayName ?? PatientLanguagePreference.displayName(forLanguageId: revertId)
                    self.markLanguagePreferredLocally(revertName)
                    self.loadInitialData()
                }
            }
        }
    }

    func handlePickedProfileImage(_ image: UIImage) {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            hostViewController?.view.hideToastActivity()
            return
        }
        let resized = resizeImage(image: image, targetSize: CGSize(width: 500, height: 500)) ?? image
        guard let imageData = resized.jpegData(compressionQuality: 0.5) else {
            hostViewController?.view.hideToastActivity()
            return
        }
        hostViewController?.view.showToastActivity()
        APIService.uploadProfileImageAPICalling(
            hostViewController,
            patientId: userInfo.patientID,
            clientId: userInfo.clientID,
            fileData: imageData,
            fileName: "profile.jpeg",
            accessToken: token
        ) { [weak self] response in
            Task { @MainActor in
                self?.hostViewController?.view.hideToastActivity()
                guard let self else { return }
                if response is [String: Any] {
                    self.profileImage = UIImage(data: imageData)
                }
            }
        }
    }

    func didUpdateAlarmFromSettings(_ minutes: Int) {
        alarmMinutes = minutes
    }

    // MARK: - Private

    /// Falls back to the key window so this screen still shows toasts when it is
    /// presented without a `hostViewController` (SwiftUI-navigated Home tab).
    private var anchorView: UIView? { Toast.resolvedAnchor(hostViewController?.view) }

    /// Updates `preferred` flags locally so language chips reflect the new choice without waiting for API.
    private func markLanguagePreferredLocally(_ languageDisplayName: String) {
        let target = PatientLanguagePreference.normalizedDisplayName(languageDisplayName)
        languagesData = languagesData.map { row in
            var next = row
            if let name = next["languageName"] as? String {
                next["preferred"] = PatientLanguagePreference.normalizedDisplayName(name) == target ? 1 : 0
            }
            return next
        }
    }

    private func resolveLanguageRow(languageName: String) -> (languageId: Int, canonicalName: String)? {
        let target = PatientLanguagePreference.normalizedDisplayName(languageName)
        for row in languagesData {
            guard let name = row["languageName"] as? String,
                  let id = row["languageId"] as? Int else { continue }
            if PatientLanguagePreference.normalizedDisplayName(name) == target {
                return (id, name)
            }
        }
        return nil
    }

    private func loadInitialData(showsToast: Bool = true, completion: (() -> Void)? = nil) {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            completion?()
            return
        }
        if showsToast { anchorView?.showToastActivity() }

        APIService.getPatientLanguagesAPICalling(
            hostViewController,
            params: ["patientId": userInfo.patientID, "clientId": userInfo.clientID],
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                guard let dict = response as? [String: Any],
                      let list = dict["patientLanguages"] as? [[String: Any]] else {
                    return
                }
                self?.languagesData = list
            }
        }

        let payload: [String: Any] = [
            "plId": userInfo.patientLocationID,
            "patientId": userInfo.patientID,
            "clientId": userInfo.clientID,
        ]
        APIService.profilePicAPICalling(
            hostViewController,
            params: payload,
            method: "POST",
            accessToken: token,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.applyProfileSettingsResponse(response)
                self?.anchorView?.hideToastActivity()
                completion?()
            }
        }
    }

    private func applyProfileSettingsResponse(_ response: AnyObject) {
        guard NetworkMonitor.shared.isConnected else {
            NoInternetBanner.shared.show()
            return
        }
        if let responseDict = response as? [String: Any],
           let settings = responseDict["settings"] as? [String: Any] {
            var titles: [String] = []

            if let imageUrlString = settings["profileImage"] as? String,
               let url = URL(string: imageUrlString) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data, let image = UIImage(data: data) {
                        Task { @MainActor in
                            self.profileImage = image
                        }
                    }
                }.resume()
            }

            if let title = settings["profileTitle"] as? String { titles.append(title) }
            if let title = settings["languageTitle"] as? String { titles.append(title) }
            if let title = settings["privacyTitle"] as? String { titles.append(title) }
            if let alarmDuration = settings["alarmDuration"] as? Int {
                alarmMinutes = alarmDuration
                titles.append("Alarm settings".localized)
            }
            if let title = settings["notificationTitle"] as? String { titles.append(title) }
            if let licenseDetails = settings["licenseDetails"] as? [String: Any] {
                if let title = licenseDetails["licenseTitle"] as? String {
                    titles.append(title)
                }
                licenseKey = licenseDetails["licenseKey"] as? String ?? ""
            }
            if let title = settings["helpTitle"] as? String { titles.append(title) }
            if let title = settings["logoutTitle"] as? String { titles.append(title) }

            cellTitles = titles
        }
    }

    private func deleteProfilePicture() {
        guard let host = hostViewController,
              let userInfo = ApplicationSharedInfo.shared.loginResponse,
              let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            return
        }
        let params: [String: Int] = ["patientId": userInfo.patientID, "clientId": userInfo.clientID]
        host.view.showToastActivity()
        APIService.DeleteProfilePicAPICalling(
            host,
            params: params,
            method: "DELETE",
            accessToken: token,
            acces: false,
            parameterPlacement: "url"
        ) { [weak self] response in
            Task { @MainActor in
                self?.hostViewController?.view.hideToastActivity()
                if let responseDict = response as? [String: Any],
                   let status = responseDict["status"] as? [String: Any],
                   let responseCode = status["responseCode"] as? Int,
                   responseCode == 200 {
                    self?.profileImage = UIImage(named: "profileIcon")
                }
            }
        }
    }

    private func presentPrivacySheet() {
        guard let host = hostViewController else { return }
        let privacy = ProfilePrivacyHostingController()
        addDimmingOverlay()
        if let sheet = privacy.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
        }
        host.present(privacy, animated: true)
    }

    private func presentAlarmSheet() {
        guard let host = hostViewController else { return }
        // Legacy handed the hosting controller in as the delegate; without one the view
        // model receives the updated alarm itself.
        let alarmDelegate: SettingsAlarmDelegate = profileHost ?? self
        let settingsVC = AlarmSettingsHostingController(initialAlarmMinutes: alarmMinutes, delegate: alarmDelegate)
        addDimmingOverlay()
        if let sheet = settingsVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
        }
        host.present(settingsVC, animated: true)
    }

    private func presentLogoutConfirmation() {
        guard let host = hostViewController else { return }
        let alert = UIAlertController(
            title: "Confirmation".localized,
            message: "Are you sure you want to logout?".localized,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Yes".localized, style: .default) { _ in
            UserDefaults.standard.set(0, forKey: "rememberMe")
            UserDefaultsHelper.clearLoginDetailsFromUserDefaults()
            ApplicationSharedInfo.shared.loginResponse = nil
            ApplicationSharedInfo.shared.tokenResponse = nil
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            UserDefaults.standard.removeObject(forKey: "favoriteExcersises")
            UserDefaults.standard.removeObject(forKey: "favoriteItems")
            UserDefaults.standard.set(false, forKey: "hasFetchedFavorites")
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
            if #available(iOS 16.0, *) {
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    let navController = LoginHostingController.loginNavigationRoot()
                    sceneDelegate.changeRootViewController(to: navController)
                }
            }
        })
        alert.addAction(UIAlertAction(title: "No".localized, style: .cancel))
        host.present(alert, animated: true)
    }

    private func requestPhotoLibraryPicker(from host: UIViewController) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            host.view.hideToastActivity()
            return
        }
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        // Legacy used the hosting controller as the delegate; inside the SwiftUI Home
        // stack there is none, so fall back to the view model's own proxy.
        if let profileHost {
            picker.delegate = profileHost
        } else {
            picker.delegate = imagePickerProxy
        }
        host.present(picker, animated: true)
    }

    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio
            ? CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
            : CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    /// Matches legacy check: successful JSON object dictionary from update-language POST.
    private func isUpdateUserLanguageSuccess(_ response: AnyObject) -> Bool {
        response is [String: Any]
    }
}

// MARK: - Alarm sheet delegate

extension UserProfileViewModel: SettingsAlarmDelegate {
    func didUpdateAlarmValue(_ newValue: Int) {
        didUpdateAlarmFromSettings(newValue)
    }
}

// MARK: - Image picker delegate

/// Stand-in for `UserProfileHostingController` when the settings screen is shown from the
/// SwiftUI Home stack. Mirrors that controller's delegate methods exactly.
@MainActor
final class ProfileImagePickerProxy: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    weak var viewModel: UserProfileViewModel?

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)
        viewModel?.hostViewController?.view.hideToastActivity()
        guard let image = info[.originalImage] as? UIImage else { return }
        viewModel?.handlePickedProfileImage(image)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        viewModel?.hostViewController?.view.hideToastActivity()
        picker.dismiss(animated: true)
    }
}
