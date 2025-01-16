//
//  APIService.swift
//  CalmscientIOS
//
//  Created by NFC User on 08/01/25.
//

import UIKit

class APIService: UIViewController {
    
    static var ProducitonURL = "https://calmscient.centralindia.cloudapp.azure.com:8090/"
    
    static var BaseUrl = ProducitonURL
    
    static var RefreshToken = "identity/api/v1/user/refreshToken"
    static var DeleteMedication = "patients/api/v1/medications/deleteMedication"
    static var MarkMedication = "patients/api/v1/medications/markMedication"
    static var AddJournal = "patients/api/v1/patientDetails/addPatientJournalEntry"
    static var GetJournalData = "patients/api/v1/patientDetails/getPatientJournalByPatientIdForMobile"
    static var FetchMoodScreenData = "patients/api/v1/patientDetails/getPatientStartupScreen"


    //MARK: - Refresh API Calling
    
    static func refreshAPICalling(_ view:UIViewController,params:[String:String],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.RefreshToken
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Delete Medication
    
    static func deletMedicationAPICalling(_ view:UIViewController,params:[String:Int],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.DeleteMedication
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Mark Medication
    
    static func MarkMedicationAPICalling(_ view:UIViewController,params:[String:Int],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.MarkMedication
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Add Journal
    
    static func AddJournalAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.AddJournal
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Add Journal
    
    static func GetJournalDataAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.GetJournalData
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Fetch Mood Screen Data
    
    static func FetchMoodScreenDataAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.FetchMoodScreenData
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    
    
    //MARK: - API Calling Function
    
    static func getRequestWithToken(
        viewController: UIViewController,
        urlString: String,
        params: [String: Any],
        method: String,
        accessToken: String,
        acces: Bool,
        timeOut: NSInteger,
        parameterPlacement: String, // "header", "body", "url"
        callback: @escaping (AnyObject) -> ()
    ) {
        var request: URLRequest
        
        guard let url = URL(string: urlString) else {
            callback("Error: Invalid URL" as AnyObject)
            return
        }
        
        switch parameterPlacement {
        case "url":
            var urlComponents = URLComponents(string: urlString)!
            var queryItems = [URLQueryItem]()
            for (key, value) in params {
                queryItems.append(URLQueryItem(name: key, value: "\(value)"))
            }
            urlComponents.queryItems = queryItems
            guard let finalURL = urlComponents.url else {
                callback("Error: Unable to create URL with query parameters" as AnyObject)
                return
            }
            request = URLRequest(url: finalURL)
        
        case "body":
            request = URLRequest(url: url)
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            } catch let error {
                print("Error serializing body parameters: \(error.localizedDescription)")
                callback("Error serializing body parameters: \(error.localizedDescription)" as AnyObject)
                return
            }
        
        case "header":
            request = URLRequest(url: url)
            for (key, value) in params {
                request.setValue("\(value)", forHTTPHeaderField: key)
            }
        
        default:
            callback("Error: Invalid parameter placement" as AnyObject)
            return
        }
        
        // Set the HTTP method
        request.httpMethod = method
        
        // Add Authorization header
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // Add Content-Type header
        if parameterPlacement != "header" { // Avoid overwriting if params are headers
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        print("Final request: \(request)")
        
        let sessionConfig = URLSessionConfiguration.default
//        sessionConfig.timeoutIntervalForRequest = TimeInterval(timeOut)
//        sessionConfig.timeoutIntervalForResource = TimeInterval(timeOut)
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                OperationQueue.main.addOperation {
                    callback("Error: \(error.localizedDescription)" as AnyObject)
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Error: Invalid response")
                OperationQueue.main.addOperation {
                    callback("Error: Invalid response" as AnyObject)
                }
                return
            }
            
            print("Status code: \(httpResponse.statusCode)")
            
            guard let data = data else {
                print("Error: No data received")
                OperationQueue.main.addOperation {
                    callback("Error: No data received" as AnyObject)
                }
                return
            }
            
            if httpResponse.statusCode != 200 {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let errorMessage = (json as? [String: Any])?["message"] as? String ?? "Unknown error"
                    print("API response for status code \(httpResponse.statusCode): \(errorMessage)")
                    OperationQueue.main.addOperation {
                        callback("Error: \(errorMessage)" as AnyObject)
                    }
                } catch let error {
                    print("Error parsing error response JSON: \(error.localizedDescription)")
                    OperationQueue.main.addOperation {
                        callback("Error parsing error response JSON: \(error.localizedDescription)" as AnyObject)
                    }
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                OperationQueue.main.addOperation {
                    callback(json as AnyObject)
                }
            } catch let error {
                print("Error parsing JSON: \(error.localizedDescription)")
                OperationQueue.main.addOperation {
                    callback("Error parsing JSON: \(error.localizedDescription)" as AnyObject)
                }
            }
        }
        
        task.resume()
    }

    


}
