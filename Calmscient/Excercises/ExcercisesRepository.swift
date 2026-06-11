//
//  ExcercisesRepository.swift
//  CalmscientIOS
//
//  Created by Aishuu on 19/10/24.
//

import Foundation

class ExcercisesRepository {
    static let shared = ExcercisesRepository()

    private init() {}

    /// Forwards to `ExerciseFavoriteAPI.savePatientExercisesFavorites` (centralized favorites endpoint).
    func addFavAPICall(
        isFav: Int,
        pageId: Int,
        title: String,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        ExerciseFavoriteAPI.savePatientExercisesFavorites(
            isFav: isFav,
            pageId: pageId,
            title: title,
            completion: completion
        )
    }
}
