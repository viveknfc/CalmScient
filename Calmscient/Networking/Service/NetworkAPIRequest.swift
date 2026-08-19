//
//  NetworkAPIRequest.swift
//  CalmscientIOS
//
//  Created by NFC on NA.
//

import Foundation
import UIKit
import FirebaseCrashlytics

public typealias NetworkRequestCompletionHandler<T:Codable> = ((_ responseType:T?, _ serverFailure:FailureResponse?, _ defaultError:Error?) -> Void)

public class NetworkAPIRequest {
    public class func sendRequest<T:Codable>(request:URLRequest, completionHandler:@escaping(NetworkRequestCompletionHandler<T>))  {
        NetworkLogger.log(request: request)
        
        Crashlytics.crashlytics().setCustomValue(request.url?.absoluteString ?? "nil", forKey: "api_url")
        Crashlytics.crashlytics().setCustomValue(request.httpMethod ?? "nil", forKey: "http_method")

        if let body = request.httpBody,
           let jsonString = String(data: body, encoding: .utf8) {
            Crashlytics.crashlytics().setCustomValue(jsonString, forKey: "request_body")
        }
        
        let task = URLSession.shared.dataTask(with: request) {  data, response, error in
            NetworkLogger.log(response: data)
            
            if let responseError = error {
                Crashlytics.crashlytics().record(error: responseError)
                Crashlytics.crashlytics().log("API error: \(responseError.localizedDescription)")
                completionHandler(nil, nil, responseError)
                return
            }

            
            guard let data = data else {
                Crashlytics.crashlytics().log("API returned nil data for URL: \(request.url?.absoluteString ?? "nil")")
                completionHandler(nil,nil,DefaultError())
                return
            }

            
            do {
                print("data is", data)

                // Attempt to decode as success response
                let responseDecoded = try JSONDecoder().decode(T.self, from: data)
                print("responseDecoded", responseDecoded)
                completionHandler(responseDecoded, nil, nil)

            } catch {
                // If decoding into T fails, try decoding into FailureResponse
                do {
                    let failureResponse = try JSONDecoder().decode(FailureResponse.self, from: data)
                    completionHandler(nil, failureResponse, nil)
                } catch let decodeError {
                    // If both decodes fail, log to Crashlytics
                    Crashlytics.crashlytics().log("Failed to decode both success and failure response")
                    Crashlytics.crashlytics().setCustomValue(request.url?.absoluteString ?? "nil", forKey: "api_url")
                    Crashlytics.crashlytics().setCustomValue(String(data: data, encoding: .utf8) ?? "nil", forKey: "raw_response")
                    Crashlytics.crashlytics().setCustomValue(decodeError.localizedDescription, forKey: "decoding_error")
                    Crashlytics.crashlytics().record(error: decodeError)

                    completionHandler(nil, nil, decodeError)
                }
            }

        }
        task.resume()
    }
}

public class DefaultError:Error {
    var localizedDescription: String {
        return "An Unkown Error Occured. Please try again!"
    }
}
