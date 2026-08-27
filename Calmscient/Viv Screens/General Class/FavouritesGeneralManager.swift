//
//  FavouritesGeneralManager.swift
//  CalmscientIOS
//
//  Created by NFC User on 18/03/25.
//

import UIKit

class FavoriteManager {
    static let shared = FavoriteManager()
    
    private init() {}
    
    let favoritesKey = "favoriteItems"
    let exercisesKey = "favoriteExcersises"
    
    var favorites: [[String: Any]] {
        get {
            guard let data = UserDefaults.standard.data(forKey: favoritesKey) else { return [] }
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []
            } catch {
                print("Error decoding favorites from UserDefaults: \(error)")
                return []
            }
        }
        set {
            do {
                let data = try JSONSerialization.data(withJSONObject: newValue, options: [])
                UserDefaults.standard.set(data, forKey: favoritesKey)
                UserDefaults.standard.synchronize()
                processFavoriteExercises()
            } catch {
                print("❌ Error encoding favorites to UserDefaults: \(error)")
            }
            NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
        }
    }
    
    var exercises: [[String: Any]] {
            return favorites.filter { ($0["isFromExercises"] as? Int) == 1 }
        }
    
    func processFavoriteExercises() {
        let filteredExercises = exercises
        
        var favExercises: [ExcercisesModel] = []
        
        filteredExercises.forEach {
            if let isFav = $0["isFavorite"] as? Int, let screenCode = $0["screenCode"] as? Int {
                favExercises.append(ExcercisesModel(isFav: isFav, screenCode: screenCode))
            }
        }

        do {
            let encodedData = try PropertyListEncoder().encode(favExercises)
            UserDefaults.standard.set(encodedData, forKey: exercisesKey)
        } catch {
            print("❌ Error encoding favorite exercises: \(error)")
        }
    }
    
    func saveFavoritesToUserDefaults() {
        do {
            let data = try JSONSerialization.data(withJSONObject: favorites, options: [])
            UserDefaults.standard.set(data, forKey: favoritesKey)
            UserDefaults.standard.synchronize()
        } catch {
            print("❌ Error encoding favorites to UserDefaults: \(error)")
        }
    }

    func fetchFavoritesIfNeeded(plId: Int, patientId: Int, clientId: Int, parentId: Int, completion: @escaping () -> Void) {
        let params: [String: Any] = [
            "plId": plId,
            "patientId": patientId,
            "parentId": parentId,
            "clientId": clientId,
        ]
        let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken ?? ""

        APIService.fetchMenusAPICalling(
            nil,
            params: params,
            method: "POST",
            accessToken: token,
            acces: true,
            parameterPlacement: "body"
        ) { result in
            if let dict = result as? [String: Any],
               let favoriteItems = dict["favorites"] as? [[String: Any]] {
                self.favorites = favoriteItems
                self.saveFavoritesToUserDefaults()
                NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
                completion()
            } else {
                print("fetchMenus favorites: unexpected response \(result)")
                completion()
            }
        }
    }
}

extension Notification.Name {
    static let favoritesUpdated = Notification.Name("favoritesUpdated")
    static let favLanUpdated = Notification.Name("favLanUpdated")
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}

// MARK: - `favLanUpdated` origin
//
// `favLanUpdated` is posted from three very different places, and only one of them is
// the user asking for fresh favourites:
//
//  • Leaving a lesson or a favourites video (`WebViewLessonViewModel`,
//    `FavoritesVideosWebViewModel`). The user may have toggled a favourite, so the
//    payload really is expected to change and the dashboard spinner is the right
//    feedback. These stay untagged.
//  • A Settings language change (`UserProfileViewModel`). Settings already shows a
//    spinner for the update and the dashboard it refreshes is *not* in front, so an
//    untagged post put a second spinner on top of the Settings one.
//  • Every tab switch (`MainTabBarViewModel`). This is a background top-up, not a
//    user-initiated reload: the dashboard already renders the cached favourites from
//    `FavoriteManager` immediately and re-renders when the response lands. The spinner
//    is worse than useless here — `showToastActivity()` anchors to the key window for
//    SwiftUI-hosted screens, so it appeared over whichever tab the user landed on and
//    disabled interaction app-wide until `fetchMenus` returned.
//
// Tagging the post lets every listener keep doing the exact same refresh work while
// skipping only the spinner that does not belong to it.

enum FavLanUpdate {
    static let reasonKey = "favLanUpdateReason"
    static let languageChangeReason = "languageChange"
    static let tabSwitchReason = "tabSwitch"

    /// `userInfo` for a `favLanUpdated` post triggered by a language change.
    static var languageChangeUserInfo: [String: Any] {
        [reasonKey: languageChangeReason]
    }

    /// `userInfo` for a `favLanUpdated` post triggered by a main tab-bar selection.
    static var tabSwitchUserInfo: [String: Any] {
        [reasonKey: tabSwitchReason]
    }
}

extension Notification {
    /// True only for a `favLanUpdated` post that a language change tagged.
    var isFavLanLanguageChange: Bool {
        favLanUpdateReason == FavLanUpdate.languageChangeReason
    }

    /// True only for a `favLanUpdated` post that a main tab-bar selection tagged.
    var isFavLanTabSwitch: Bool {
        favLanUpdateReason == FavLanUpdate.tabSwitchReason
    }

    /// Whether the favourites refresh this post triggers should own a blocking spinner.
    ///
    /// Only the untagged posts — the ones that follow a screen where the user could have
    /// changed a favourite — do. See the origin note above.
    var favLanUpdateShowsFavoritesSpinner: Bool {
        !isFavLanLanguageChange && !isFavLanTabSwitch
    }

    private var favLanUpdateReason: String? {
        userInfo?[FavLanUpdate.reasonKey] as? String
    }
}

