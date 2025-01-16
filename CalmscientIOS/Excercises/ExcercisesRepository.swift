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
        debugPrint("Payload -> \(payload)")
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            debugPrint("Payload -> \(jsonData)")
            request.httpBody = jsonData
            print(jsonData)
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
            // If needed, handle the response here
            completion(.success(data))
        }
        /*
        {
            "responseMessage": "Saved Patient Favorites",
            "responseCode": 200
        }
         */
        
        // Start the data task
        task.resume()
    }
}
