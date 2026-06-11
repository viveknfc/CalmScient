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

