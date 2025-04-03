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
    static var JournalData = "patients/api/v1/patientDetails/getPatientJournalByPatientIdForMobile"

    static var ProfilePicDelet = "identity/api/v1/settings/deleteProfileImage"

    static var GetTakingControlIndex = "patients/api/v1/takingControl/getTakingControlIndex"
    static var CreateDrinkTracking = "patients/api/v1/alcohol/createDrinkTracking"
    
    static var DeleteeAppointment = "patients/api/v1/appointments/deactivate"
    static var EditAppointment = "patients/api/v1/appointments/update"
    static var SaveAppointment = "patients/api/v1/appointments/create"
    static var LocationDetails = "identity/api/v1/location/getLocationList"
    static var ProviderDetails = "identity/api/v1/location/getAllProviders"
    
    static var UserStartUpScreen = "patients/api/v1/patientDetails/hasSavedStartupScreen"
    static var updatePassword = "identity/api/v1/settings/changePasswordForMob"
    
    static var DBasicKnowledgeQuestions = "patients/api/v1/takingControl/getBasicKnowledgeIndex"
    static var DUpdateBasicKnowledge = "patients/api/v1/takingControl/updateBasicKnowledgeIndex"
    
    static var SGetTakingControlIndex = "patients/api/v1/smokingcontrol/getTakingControlIndex"
    static var SBasicKnowledgeQuestions = "patients/api/v1/smokingcontrol/getBasicKnowledgeIndex"
    

    //MARK: - user StartUp API Calling
    
    static func userStartUpAPICalling(_ view:UIViewController?,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.UserStartUpScreen
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Update Password API Calling
    
    static func updatePasswordAPICalling(_ view:UIViewController?,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.updatePassword
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }

    //MARK: - Refresh API Calling
    
    static func refreshAPICalling(_ view:UIViewController?,params:[String:String],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.RefreshToken
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Delete Medication
    
    static func deletMedicationAPICalling(_ view:UIViewController,params:[String:Int],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.DeleteMedication
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Delete Appointment
    
    static func deleteAppointmentAPICalling(_ view:UIViewController,params:[String:Int],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.DeleteeAppointment
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Edit Appointment
    
    static func editSaveAppointmentAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.EditAppointment
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Save Appointment
    
    static func SaveAppointmentAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.SaveAppointment
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Smoking Get Taking COntrol
    
    static func SGetTakingControlAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.SGetTakingControlIndex
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Smoking Basic Know Question
    
    static func SBasicKQAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.SBasicKnowledgeQuestions
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Drinking Basic Know Question
    
    static func DBasicKQAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.DBasicKnowledgeQuestions
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Drinking Update Basic Know
    
    static func DUpdateBasicKAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.DUpdateBasicKnowledge
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Get Location Details in Appointment
    
    static func LocationDetailsAPICalling(_ view:UIViewController,params:[String:Int],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.LocationDetails
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Get Provider Details in Appointment
    
    static func ProviderDetailsAPICalling(_ view:UIViewController,params:[String:Int],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.ProviderDetails
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Mark Medication
    
    static func MarkMedicationAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
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
    
    //MARK: - Journal Data
    
    static func JournalDataAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.JournalData
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    

    //MARK: - Delete Profile Pic
    
    static func DeleteProfilePicAPICalling(_ view:UIViewController,params:[String:Int],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.ProfilePicDelet
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    

    //MARK: - Drinking GetTakingControlIndex
    
    static func getTakingControlIndexAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.GetTakingControlIndex
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Drinking GetTakingControlIndex
    
    static func createDrinkingCountAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.CreateDrinkTracking
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 45, parameterPlacement: parameterPlacement, callback: callBack)
    }

    
    
    //MARK: - API Calling Function
    
    static func getRequestWithToken(
        viewController: UIViewController?,
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
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization") //new
        
        case "body":
            request = URLRequest(url: url)
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            } catch let error {
                print("Error serializing body parameters: \(error.localizedDescription)")
                callback("Error serializing body parameters: \(error.localizedDescription)" as AnyObject)
                return
            }
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")//new
        
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
//        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization") // because of this api with header is not working - viv
        
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
