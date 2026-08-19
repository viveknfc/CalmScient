//
//  ExerciseFavoriteToggle.swift
//  Calmscient
//
//  Centralized exercise favorite API and UI toggle (load, save, toast, rollback).
//
//  Vivek
//  21 May 2026
//

import Foundation
import UIKit

// MARK: - API

/// Wraps `APIService.savePatientExercisesFavoritesAPICalling` for exercise favorite buttons.
enum ExerciseFavoriteAPI {

    static func savePatientExercisesFavorites(
        isFav: Int,
        pageId: Int,
        title: String,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        print("the title getting is ", title)

        guard let tokenResponse = ApplicationSharedInfo.shared.tokenResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }

        let params: [String: Any] = [
            "isFav": isFav,
            "pageId": pageId,
            "patientId": userInfo.patientID,
            "title": title,
        ]

        APIService.savePatientExercisesFavoritesAPICalling(
            nil,
            params: params,
            method: "POST",
            accessToken: tokenResponse.accessToken,
            acces: false,
            parameterPlacement: "body"
        ) { response in
            handleSaveResponse(response, userInfo: userInfo, completion: completion)
        }
    }

    private static func handleSaveResponse(
        _ response: AnyObject,
        userInfo: LoginDetails,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        if let errorMessage = response as? String, errorMessage.hasPrefix("Error:") {
            print(errorMessage)
            completion(.failure(ExerciseFavoriteAPIError.requestFailed(errorMessage)))
            return
        }

        guard let json = response as? [String: Any],
              let responseCode = json["responseCode"] as? Int,
              responseCode == 200
        else {
            print("Failed to update favorite status")
            completion(.failure(ExerciseFavoriteAPIError.updateFailed))
            return
        }

        DispatchQueue.main.async {
            FavoriteManager.shared.fetchFavoritesIfNeeded(
                plId: userInfo.patientLocationID,
                patientId: userInfo.patientID,
                clientId: userInfo.clientID,
                parentId: 0
            ) {
                print("✅ Favorites updated after adding/removing favorite")
                NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
            }
        }

        if let data = try? JSONSerialization.data(withJSONObject: json, options: []) {
            completion(.success(data))
        } else {
            completion(.success(Data()))
        }
    }
}

enum ExerciseFavoriteAPIError: LocalizedError {
    case requestFailed(String)
    case updateFailed

    var errorDescription: String? {
        switch self {
        case .requestFailed(let message):
            return message
        case .updateFailed:
            return "Failed to update favorite"
        }
    }
}

// MARK: - Toggle request

/// Payload for `savePatientExercisesFavorites` (server title + page id).
struct ExerciseFavoriteToggleRequest {
    let pageId: Int
    let title: String

    init(pageId: Int, title: String) {
        self.pageId = pageId
        self.title = title
    }

    init(pageId: Int, exercise: ExcercisesTypeEnum) {
        self.pageId = pageId
        self.title = exercise.addFavCode
    }
}

// MARK: - Toggle UI + API

@MainActor
enum ExerciseFavoriteToggle {

    private static var favoritesStorageKey: String {
        FavoriteManager.shared.exercisesKey
    }

    // MARK: - Load

    static func loadIsFav(screenCode: Int) -> Int {
        guard let data = UserDefaults.standard.value(forKey: favoritesStorageKey) as? Data,
              let favorites = try? PropertyListDecoder().decode([ExcercisesModel].self, from: data),
              let match = favorites.first(where: { $0.screenCode == screenCode })
        else {
            return 0
        }
        return match.isFav
    }

    static func loadIsFav(exercise: ExcercisesTypeEnum) -> Int {
        loadIsFav(screenCode: exercise.rawValue)
    }

    static func isFavorited(screenCode: Int) -> Bool {
        loadIsFav(screenCode: screenCode) == 1
    }

    static func isFavorited(exercise: ExcercisesTypeEnum) -> Bool {
        isFavorited(screenCode: exercise.rawValue)
    }

    // MARK: - Save (API only, no UI)

    static func saveFavorite(
        isFav: Int,
        request: ExerciseFavoriteToggleRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        ExerciseFavoriteAPI.savePatientExercisesFavorites(
            isFav: isFav,
            pageId: request.pageId,
            title: request.title,
            completion: completion
        )
    }

    // MARK: - Toggle (UI + API)

    /// Optimistically toggles favorite, calls the API, shows loading/toast, and rolls back on failure.
    /// - Parameter onIsFavChanged: Invoked on the main actor with the active `isFav` value (0 or 1).
    static func toggle(
        currentIsFav: Int,
        request: ExerciseFavoriteToggleRequest,
        anchorView: UIView?,
        onIsFavChanged: @escaping @MainActor (Int) -> Void
    ) {
        toggle(
            currentIsFav: currentIsFav,
            pageId: request.pageId,
            title: request.title,
            anchorView: anchorView,
            onIsFavChanged: onIsFavChanged
        )
    }

    static func toggle(
        currentIsFav: Int,
        pageId: Int,
        title: String,
        anchorView: UIView?,
        onIsFavChanged: @escaping @MainActor (Int) -> Void
    ) {
        let previousIsFav = currentIsFav
        let optimisticIsFav = previousIsFav == 0 ? 1 : 0

        // Falls back to the key window so screens without a `hostViewController`
        // (SwiftUI-navigated ones) still get the same toast feedback.
        let anchorView = Toast.resolvedAnchor(anchorView)

        onIsFavChanged(optimisticIsFav)
        anchorView?.showToastActivity()

        ExerciseFavoriteAPI.savePatientExercisesFavorites(
            isFav: optimisticIsFav,
            pageId: pageId,
            title: title
        ) { result in
            Task { @MainActor in
                anchorView?.hideToastActivity()

                switch result {
                case .success(let data):
                    onIsFavChanged(optimisticIsFav)
                    if let message = responseMessage(from: data) {
                        anchorView?.showToast(message: message)
                    }
                case .failure:
                    onIsFavChanged(previousIsFav)
                }
            }
        }
    }

    // MARK: - Private

    private static func responseMessage(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return nil
        }
        return json["responseMessage"] as? String
    }
}

// MARK: - UIKit

extension UIViewController {

    /// Toggles an exercise favorite using `ExerciseFavoriteToggle` (same behavior as legacy exercise screens).
    func toggleExerciseFavorite(
        currentIsFav: Int,
        pageId: Int,
        title: String,
        applyFavoriteState: @escaping @MainActor (Int) -> Void
    ) {
        ExerciseFavoriteToggle.toggle(
            currentIsFav: currentIsFav,
            pageId: pageId,
            title: title,
            anchorView: view,
            onIsFavChanged: applyFavoriteState
        )
    }

    func toggleExerciseFavorite(
        currentIsFav: Int,
        pageId: Int,
        exercise: ExcercisesTypeEnum,
        applyFavoriteState: @escaping @MainActor (Int) -> Void
    ) {
        toggleExerciseFavorite(
            currentIsFav: currentIsFav,
            pageId: pageId,
            title: exercise.addFavCode,
            applyFavoriteState: applyFavoriteState
        )
    }
}
