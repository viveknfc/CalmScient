//
//  APIService.swift
//  CalmscientIOS
//
//  Created by NFC User on 08/01/25.
//

import UIKit
import FirebaseCrashlytics

class APIService: UIViewController {
    
    static var ProducitonURL = "https://calmscient.in/api/"
    static var DevURL = "http://147.93.41.160/api/"
    
    static var Url4Courses = "https://calmscient.in/courses/" //"http://147.93.41.160/courses/"
    static var BaseUrl = ProducitonURL
    
    static var RefreshToken = "identity/api/v1/user/refreshToken"
    static var DeleteMedication = "patients/api/v1/medications/deleteMedication"
    static var MarkMedication = "patients/api/v1/medications/markMedication"
    static var AddJournal = "patients/api/v1/patientDetails/addPatientJournalEntry"
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
    static var SUpdateBasicKnowledge = "patients/api/v1/smokingcontrol/updateBasicKnowledgeIndex"
    
    static var getTakingControlIntroData = "patients/api/v1/takingControl/getTakingControlIntroduction"
    static var saveTakingControlIntroData = "patients/api/v1/takingControl/saveTakingControlIntroduction"
    
    static var validateLicenseKey = "identity/api/v1/license/validateLicenseKey"
    static var alarmSettings = "identity/api/v1/settings/saveAlarmDurationTime"
    
    static var profilePic = "identity/api/v1/settings/getUserProfile"
    
    static var ScreeningList4AssessmentId = "patients/api/v1/screening/getScreeningListForMobile"
    static var TakingControlIntroFirstScreen = "patients/api/v1/screening/getScreeningQuestionnaireForMobile"
    static var TakingControlIntroFirstAns = "patients/api/v1/screening/savePatientAnswersForMobile"
    
    static var generateOTP = "identity/api/v1/settings/generateOTP"
    

    //MARK: - Validate License Key API Calling
    
    static func validateLicenseKeyAPICalling(_ view:UIViewController?,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.validateLicenseKey
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Generate OTP API Calling
    
    static func generateOTPAPICalling(_ view:UIViewController?,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.generateOTP
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Alarm Settings API Calling
    
    static func alarmSettingsAPICalling(_ view:UIViewController?,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.alarmSettings
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Profile Pic API Calling
    
    static func profilePicAPICalling(_ view:UIViewController?,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.profilePic
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - user StartUp API Calling
    
    static func userStartUpAPICalling(_ view:UIViewController?,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.UserStartUpScreen
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Update Password API Calling
    
    static func updatePasswordAPICalling(_ view:UIViewController?,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.updatePassword
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }

    //MARK: - Refresh API Calling
    
    static func refreshAPICalling(_ view:UIViewController?,params:[String:String],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.RefreshToken
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Delete Medication
    
    static func deletMedicationAPICalling(_ view:UIViewController,params:[String:Int],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.DeleteMedication
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Delete Appointment
    
    static func deleteAppointmentAPICalling(_ view:UIViewController,params:[String:Int],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.DeleteeAppointment
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Edit Appointment
    
    static func editSaveAppointmentAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.EditAppointment
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Save Appointment
    
    static func SaveAppointmentAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.SaveAppointment
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Smoking Get Taking COntrol
    
    static func SGetTakingControlAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.SGetTakingControlIndex
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Smoking Basic Know Question
    
    static func SBasicKQAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.SBasicKnowledgeQuestions
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Screening List Assesment ID API Calling
    
    static func screeningListAssessmentrIdAPICalling(_ view:UIViewController?,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.ScreeningList4AssessmentId
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Taking control Intro First Screen API Calling
    
    static func takingccontrolIntrofirstscreenDataAPICalling(_ view:UIViewController?,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.TakingControlIntroFirstScreen
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Taking control Intro First Screen Answer API Calling
    
    static func takingccontrolIntrofirstscreenAnswerAPICalling(_ view:UIViewController?,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.TakingControlIntroFirstAns
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Drinking Basic Know Question
    
    static func DBasicKQAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.DBasicKnowledgeQuestions
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Drinking Update Basic Know
    
    static func DUpdateBasicKAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.DUpdateBasicKnowledge
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Smoking Update Basic Know
    
    static func SUpdateBasicKAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.SUpdateBasicKnowledge
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Get Location Details in Appointment
    
    static func LocationDetailsAPICalling(_ view:UIViewController,params:[String:Int],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.LocationDetails
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Get Provider Details in Appointment
    
    static func ProviderDetailsAPICalling(_ view:UIViewController,params:[String:Int],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.ProviderDetails
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Mark Medication
    
    static func MarkMedicationAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.MarkMedication
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Add Journal
    
    static func AddJournalAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.AddJournal
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Fetch Mood Screen Data
    
    static func FetchMoodScreenDataAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.FetchMoodScreenData
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Journal Data
    
    static func JournalDataAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.JournalData
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    

    //MARK: - Delete Profile Pic
    
    static func DeleteProfilePicAPICalling(_ view:UIViewController,params:[String:Int],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.ProfilePicDelet
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - GetTakingControlIntro
    
    static func getTakingControlIntroAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.getTakingControlIntroData
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - SaveTakingControlIntro
    
    static func saveTakingControlIntroAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.saveTakingControlIntroData
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    

    //MARK: - Drinking GetTakingControlIndex
    
    static func getTakingControlIndexAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.GetTakingControlIndex
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Drinking GetTakingControlIndex
    
    static func createDrinkingCountAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.CreateDrinkTracking
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
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
            Crashlytics.crashlytics().log("Invalid URL: \(urlString)")
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
            request.timeoutInterval = TimeInterval(timeOut)
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization") //new
            
        case "body":
            request = URLRequest(url: url)
            request.timeoutInterval = TimeInterval(timeOut)
            
            if JSONSerialization.isValidJSONObject(params) {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                } catch let error {
                    let message = "Error serializing body parameters: \(error.localizedDescription)"
                    Crashlytics.crashlytics().log(message)
                    callback(message as AnyObject)
                    return
                }
            } else {
                let message = "Invalid JSON object in params: \(params)"
                Crashlytics.crashlytics().log(message)
                callback(message as AnyObject)
                return
            }

            if !accessToken.isEmpty {
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
        
        case "header":
            request = URLRequest(url: url)
            request.timeoutInterval = TimeInterval(timeOut)
            for (key, value) in params {
                request.setValue("\(value)", forHTTPHeaderField: key)

            }
        
        default:
            callback("Error: Invalid parameter placement" as AnyObject)
            return
        }
        
        // Set the HTTP method
        request.httpMethod = method
        
        // Add Content-Type header
        if parameterPlacement != "header" { // Avoid overwriting if params are headers
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        Crashlytics.crashlytics().setCustomValue(urlString, forKey: "api_url")
        Crashlytics.crashlytics().setCustomValue(method, forKey: "http_method")
        Crashlytics.crashlytics().setCustomValue(params.description, forKey: "parameters")
        
        print("Final request: \(request)")
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let startTime = Date()
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            let endTime = Date()
            let responseTIme = endTime.timeIntervalSince(startTime)
            print("the response TIme taking is: \(responseTIme) seconds")
            
            if let error = error {
                
                let nsError = error as NSError
                if nsError.code == NSURLErrorTimedOut {
                    Crashlytics.crashlytics().log("Timeout error for URL: \(urlString)")
                } else {
                    Crashlytics.crashlytics().log("Network error: \(error.localizedDescription)")
                }
                
                callback("Error: \(error.localizedDescription)" as AnyObject)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                Crashlytics.crashlytics().log("Invalid HTTPURLResponse for URL: \(urlString)")
                callback("Error: Invalid response" as AnyObject)
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
                    Crashlytics.crashlytics().log("API \(urlString) returned status code \(httpResponse.statusCode) — Error: \(errorMessage)")
                    callback("Error: \(errorMessage)" as AnyObject)
                } catch let error {
                    Crashlytics.crashlytics().log("Error parsing error JSON for URL: \(urlString) — \(error.localizedDescription)")
                    callback("Error parsing error response JSON: \(error.localizedDescription)" as AnyObject)
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                
                if let dict = json as? [String: Any], dict.isEmpty {
                    Crashlytics.crashlytics().log("API \(urlString) returned empty dictionary.")
                } else if json is NSNull {
                    Crashlytics.crashlytics().log("API \(urlString) returned null.")
                }
                
                OperationQueue.main.addOperation {
                    callback(json as AnyObject)
                }
            } catch let error {
                Crashlytics.crashlytics().log("JSON parse error for URL \(urlString): \(error.localizedDescription)")
                callback("Error parsing JSON: \(error.localizedDescription)" as AnyObject)
            }

        }
        
        task.resume()
    }

    


}
