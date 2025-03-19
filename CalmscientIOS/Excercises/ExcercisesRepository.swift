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
    
    func addFavAPICall(isFav: Int, pageId: Int, title: String, completion: @escaping (Result<Data, Error>) -> Void){
        // Define the URL
        
        print("the title getting is ", title)
        
        guard let url = URL(string: "\(baseURLString)patients/api/v1/course/savePatientExercisesFavorites") else {
            print("Invalid URL")
            return
        }
        guard let tokenResponse = ApplicationSharedInfo.shared.tokenResponse else {
            fatalError("Unable to found Application Shared Info")
        }

        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(tokenResponse.accessToken)", forHTTPHeaderField: "Authorization")
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        // Define the JSON payload
        let payload: [String: Any] = [
            "isFav": isFav,
            "pageId": pageId,
            "patientId": userInfo.patientID,
            "title": title
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData

        } catch {
            print("Error converting payload to JSON: \(error)")
            completion(.failure(error))
            return
        }
        
        // Create the URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with request: \(error)")
                completion(.failure(error))
                return
            }
            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

//            completion(.success(data))
            
            //VIV start
            
            do {
                       if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                          let responseCode = jsonResponse["responseCode"] as? Int, responseCode == 200 {
                           
                           DispatchQueue.main.async {
                        FavoriteManager.shared.fetchFavoritesIfNeeded(plId: userInfo.patientLocationID,
                                                                             patientId: userInfo.patientID,
                                                                             clientId: userInfo.clientID,
                                                                             parentId: 0) {
                            print("✅ Favorites updated after adding/removing favorite")
                            NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
                               }
                                           }
                           completion(.success(data))
                       } else {
                           print("Failed to update favorite status")
                           completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to update favorite"])))
                       }
                   } catch {
                       print("Error parsing response: \(error)")
                       completion(.failure(error))
                   }
               
            
            //END
        }

        task.resume()
    }
}
