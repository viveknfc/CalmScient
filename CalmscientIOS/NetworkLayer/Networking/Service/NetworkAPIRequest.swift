//
//  NetworkAPIRequest.swift
//  CalmscientIOS
//
//  Created by NFC on NA.
//

import Foundation
import UIKit

public typealias NetworkRequestCompletionHandler<T:Codable> = ((_ responseType:T?, _ serverFailure:FailureResponse?, _ defaultError:Error?) -> Void)

public class NetworkAPIRequest {
    public class func sendRequest<T:Codable>(request:URLRequest, completionHandler:@escaping(NetworkRequestCompletionHandler<T>))  {
        NetworkLogger.log(request: request)
        let task = URLSession.shared.dataTask(with: request) {  data, response, error in
            NetworkLogger.log(response: data)
            if let responseError = error {
                completionHandler(nil, nil, responseError)
                return
            }
            
            guard let data = data else {
                completionHandler(nil,nil,DefaultError())
                return
            }
            
            do {
                print("data is", data)
                if let responseDecoded = try? JSONDecoder().decode(T.self, from: data) {
                    print("responseDecoded", responseDecoded)
                    completionHandler(responseDecoded,nil,nil)
                    return
                } else {
                    if let failureResponse = try? JSONDecoder().decode(FailureResponse.self, from: data) {
                        completionHandler(nil,failureResponse,nil)
                        return
                    } else {
                        completionHandler(nil,nil,DefaultError())
                        return
                    }
                    
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
