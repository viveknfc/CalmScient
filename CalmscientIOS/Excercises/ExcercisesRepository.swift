//
//  ExcercisesRepository.swift
//  CalmscientIOS
//
//  Created by Aishuu on 19/10/24.
//

import Foundation
import FirebaseCrashlytics

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
            Crashlytics.crashlytics().log("JSON serialization failed for addFavAPICall")
            Crashlytics.crashlytics().record(error: error)
            completion(.failure(error))
            return
        }
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 6 // or 60, based on your needs
        let session = URLSession(configuration: config)
        
        // Create the URLSession data task
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with request: \(error)")
                
                if (error as NSError).code == NSURLErrorTimedOut {
                    Crashlytics.crashlytics().log("Timeout error in addFavAPICall")
                } else {
                    Crashlytics.crashlytics().log("Other error in addFavAPICall")
                }
                
                Crashlytics.crashlytics().log("Error in addFavAPICall")
                Crashlytics.crashlytics().setCustomValue(url.absoluteString, forKey: "fav_api_url")
                Crashlytics.crashlytics().setCustomValue(payload.description, forKey: "fav_api_payload")
                Crashlytics.crashlytics().record(error: error)
                
                completion(.failure(error))
                return
            }
            guard let data = data else {
                print("No data received")
                Crashlytics.crashlytics().log("No data received in addFavAPICall")
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
                           Crashlytics.crashlytics().log("Invalid response for favorite status update")
                           Crashlytics.crashlytics().setCustomValue(String(data: data, encoding: .utf8) ?? "NIL", forKey: "fav_raw_response")
                           completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to update favorite"])))
                       }
                   } catch {
                       print("Error parsing response: \(error)")
                       Crashlytics.crashlytics().log("Failed to parse JSON in addFavAPICall")
                       Crashlytics.crashlytics().record(error: error)
                       completion(.failure(error))
                   }
               
            
            //END
        }

        task.resume()
    }
}
