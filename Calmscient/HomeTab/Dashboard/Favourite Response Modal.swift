//
//  Favourite Response Modal.swift
//  Calmscient
//
//  Created by NFC Solutions on 30/09/25.
//

struct FavoritesResponse: Decodable {
    let statusResponse: StatusResponse
    let favorites: [Favorite]
}

struct Favorite: Decodable {
    let patientId: Int
    let favoritesId: Int?
    let lessonId: Int?
    let chapterId: Int?
    let pageNo: Int
    let url: String?
    let isFavorite: Int
    let navigateURL: String?
    let language: Int
    let isFromExercises: Int
    let title: String
    let isFromTakingControl: Int
    let thumbnail: String
    let darkTheme: Int
}
