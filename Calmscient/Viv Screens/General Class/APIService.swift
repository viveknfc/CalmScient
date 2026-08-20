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
    
    static var Url4Courses = "https://calmscient.in/courses/" //"http://147.93.41.160/courses/" //
    static var BaseUrl = DevURL
    
    static var versionCheck = "identity/api/v1/settings/getAppVersion"
    
    static var RefreshToken = "identity/api/v1/user/refreshToken"
    static var DeleteMedication = "patients/api/v1/medications/deleteMedication"
    static var MarkMedication = "patients/api/v1/medications/markMedication"
    static var GetMedications = "patients/api/v1/medications/getMedications"
    static var AddMedications = "patients/api/v1/medications/addMedications"
    static var SavePatientStartupScreen = "patients/api/v1/patientDetails/savePatientStartupScreen"
    static var forgetPassword = "identity/api/v1/settings/forgetPassword"
    static var AddJournal = "patients/api/v1/patientDetails/addPatientJournalEntry"
    static var FetchMoodScreenData = "patients/api/v1/patientDetails/getPatientStartupScreen"
    static var JournalData = "patients/api/v1/patientDetails/getPatientJournalByPatientIdForMobile"

    static var ProfilePicDelet = "identity/api/v1/settings/deleteProfileImage"

    static var GetTakingControlIndex = "patients/api/v1/takingControl/getTakingControlIndex"
    static var CreateDrinkTracking = "patients/api/v1/alcohol/createDrinkTracking"
    static var GetDrinksList = "patients/api/v1/alcohol/getDrinksList"
    
    static var DeleteeAppointment = "patients/api/v1/appointments/deactivate"
    static var EditAppointment = "patients/api/v1/appointments/update"
    static var SaveAppointment = "patients/api/v1/appointments/create"
    static var getMedicalAppointmentsByPatientId = "patients/api/v1/patientDetails/getMedicalAppointmentsByPatientId"
    static var LocationDetails = "identity/api/v1/location/getLocationList"
    static var ProviderDetails = "identity/api/v1/location/getAllProviders"
    static var getPatientPrivacy = "identity/api/v1/settings/getPatientPrivacy"
    static var updatePatientConsent = "identity/api/v1/settings/updatePatientConsent"
    
    static var UserStartUpScreen = "patients/api/v1/patientDetails/hasSavedStartupScreen"
    static var updatePassword = "identity/api/v1/settings/changePasswordForMob"
    static var getPatientProfileDetails = "identity/api/v1/settings/getPatientProfileDetails"
    static var updatePatientProfileDetails = "identity/api/v1/settings/updatePatientProfileDetails"
    
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
    static var getPatientLanguages = "identity/api/v1/settings/getPatientLanguages"
    static var updateUserLanguage = "identity/api/v1/settings/updateUserLanguage"
    static var uploadProfileImage = "identity/api/v1/settings/uploadProfileImage"
    
    static var ScreeningList4AssessmentId = "patients/api/v1/screening/getScreeningListForMobile"
    static var ScreeningHistoryForMobile = "patients/api/v1/screening/getScreeningHistoryForMobile"
    static var ScreeningResultsForMobile = "patients/api/v1/screening/getScreeningResultsForMobile"
    static var TakingControlIntroFirstScreen = "patients/api/v1/screening/getScreeningQuestionnaireForMobile"
    static var TakingControlIntroFirstAns = "patients/api/v1/screening/savePatientAnswersForMobile"
    
    static var generateOTP = "identity/api/v1/settings/generateOTP"
    static var validateOTP = "identity/api/v1/settings/validateOTP"
    static var userLogin = "identity/api/v1/settings/userLogin"

    /// Home tab / favorites: menu payload includes `favorites` array (used by `FavoriteManager`).
    static var FetchMenus = "identity/api/v1/menu/fetchMenus"
    /// Course favorites for patient (e.g. basic knowledge video favorite state).
    static var GetPatientFavorites = "patients/api/v1/course/getPatientFavorites"
    /// Save or remove an exercise favorite (every exercise fav button).
    static var SavePatientExercisesFavorites = "patients/api/v1/course/savePatientExercisesFavorites"
    static var getPatientCourseWorkPercentageDetailsForMobile =
        "patients/api/v1/course/getPatientCourseWorkPercentageDetailsForMobile"
    static var getPatientCourseIndex = "patients/api/v1/course/getPatientCourseIndex"
    
    static var GetWearableData = "patients/api/v1/health/wearable-data"
    static var GetWearableDataRange = "patients/api/v1/health/wearable-data/range"
    static var PostWearableData = "patients/api/v1/health/wearable-data"
    static var GetWearableAverage = "patients/api/v1/health/wearable-data/average"

    //MARK: - Version CHeck API
    
    static func validateVersionAPICalling(_ view:UIViewController?,params:[String:Any],method:String,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.versionCheck
        APIService.getRequestWithToken(viewController: view, urlString: urlString, params: params, method: method, accessToken: "", acces: true, timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
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

    //MARK: - Validate OTP API Calling

    static func validateOTPAPICalling(_ view: UIViewController?, params: [String: Any], method: String, accessToken: String, acces: Bool, parameterPlacement: String, callBack: @escaping (AnyObject) -> ()) {

        let urlString = APIService.BaseUrl + APIService.validateOTP
        APIService.getRequestWithToken(viewController: view, urlString: urlString, params: params, method: method, accessToken: accessToken, acces: acces, timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }

    //MARK: - User Login API Calling

    static func userLoginAPICalling(_ view: UIViewController?, params: [String: Any], method: String, accessToken: String, acces: Bool, parameterPlacement: String, callBack: @escaping (AnyObject) -> ()) {

        let urlString = APIService.BaseUrl + APIService.userLogin
        APIService.getRequestWithToken(viewController: view, urlString: urlString, params: params, method: method, accessToken: accessToken, acces: acces, timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }

    // MARK: - Home dashboard / favorites (menus)

    static func fetchMenusAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        method: String,
        accessToken: String,
        acces: Bool,
        parameterPlacement: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.FetchMenus
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: method,
            accessToken: accessToken,
            acces: acces,
            timeOut: 6,
            parameterPlacement: parameterPlacement,
            callback: callBack
        )
    }

    static func getPatientFavoritesAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        method: String,
        accessToken: String,
        acces: Bool,
        parameterPlacement: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.GetPatientFavorites
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: method,
            accessToken: accessToken,
            acces: acces,
            timeOut: 6,
            parameterPlacement: parameterPlacement,
            callback: callBack
        )
    }

    // MARK: - Save patient exercise favorite

    static func savePatientExercisesFavoritesAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        method: String,
        accessToken: String,
        acces: Bool,
        parameterPlacement: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.SavePatientExercisesFavorites
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: method,
            accessToken: accessToken,
            acces: acces,
            timeOut: 6,
            parameterPlacement: parameterPlacement,
            callback: callBack
        )
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

    // MARK: - Patient profile (edit screen)

    static func getPatientProfileDetailsAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        method: String,
        accessToken: String,
        acces: Bool,
        parameterPlacement: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.getPatientProfileDetails
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: method,
            accessToken: accessToken,
            acces: acces,
            timeOut: 6,
            parameterPlacement: parameterPlacement,
            callback: callBack
        )
    }

    static func updatePatientProfileDetailsAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        method: String,
        accessToken: String,
        acces: Bool,
        parameterPlacement: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.updatePatientProfileDetails
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: method,
            accessToken: accessToken,
            acces: acces,
            timeOut: 6,
            parameterPlacement: parameterPlacement,
            callback: callBack
        )
    }

    // MARK: - Settings: patient languages

    static func getPatientLanguagesAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        method: String,
        accessToken: String,
        acces: Bool,
        parameterPlacement: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.getPatientLanguages
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: method,
            accessToken: accessToken,
            acces: acces,
            timeOut: 6,
            parameterPlacement: parameterPlacement,
            callback: callBack
        )
    }

    static func updateUserLanguageAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        method: String,
        accessToken: String,
        acces: Bool,
        parameterPlacement: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.updateUserLanguage
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: method,
            accessToken: accessToken,
            acces: acces,
            timeOut: 6,
            parameterPlacement: parameterPlacement,
            callback: callBack
        )
    }

    /// Multipart upload cannot use JSON `getRequestWithToken`; mirrors its URL, auth, connectivity, and status handling.
    static func uploadProfileImageAPICalling(
        _: UIViewController?,
        patientId: Int,
        clientId: Int,
        fileData: Data,
        fileName: String,
        accessToken: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            callBack("Error: No Internet Connection" as AnyObject)
            return
        }

        let urlString = APIService.BaseUrl + APIService.uploadProfileImage
        guard let url = URL(string: urlString) else {
            Crashlytics.crashlytics().log("Invalid URL: \(urlString)")
            callBack("Error: Invalid URL" as AnyObject)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"patientId\"\r\n\r\n")
        body.append("\(patientId)\r\n")
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"clientId\"\r\n\r\n")
        body.append("\(clientId)\r\n")
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(fileData)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n\r\n")
        request.httpBody = body
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        request.timeoutInterval = 6

        Crashlytics.crashlytics().setCustomValue(urlString, forKey: "api_url")
        Crashlytics.crashlytics().setCustomValue("POST", forKey: "http_method")

        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                let nsError = error as NSError
                if nsError.code == NSURLErrorNotConnectedToInternet ||
                    nsError.code == NSURLErrorNetworkConnectionLost {
                    DispatchQueue.main.async {
                        NoInternetBanner.shared.show()
                    }
                    callBack("Error: No Internet Connection" as AnyObject)
                    return
                }
                Crashlytics.crashlytics().log("Network error: \(error.localizedDescription)")
                OperationQueue.main.addOperation {
                    callBack("Error: \(error.localizedDescription)" as AnyObject)
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                OperationQueue.main.addOperation {
                    callBack("Error: Invalid response" as AnyObject)
                }
                return
            }

            guard let data = data else {
                OperationQueue.main.addOperation {
                    callBack("Error: No data received" as AnyObject)
                }
                return
            }

            if httpResponse.statusCode != 200 {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    let errorMessage = (json as? [String: Any])?["message"] as? String ?? "Unknown error"
                    Crashlytics.crashlytics().log("API \(urlString) returned status code \(httpResponse.statusCode) — Error: \(errorMessage)")
                    OperationQueue.main.addOperation {
                        callBack("Error: \(errorMessage)" as AnyObject)
                    }
                } catch let parseError {
                    Crashlytics.crashlytics().log("Error parsing error JSON for URL: \(urlString) — \(parseError.localizedDescription)")
                    OperationQueue.main.addOperation {
                        callBack("Error parsing error response JSON: \(parseError.localizedDescription)" as AnyObject)
                    }
                }
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                OperationQueue.main.addOperation {
                    callBack(json as AnyObject)
                }
            } catch let parseError {
                Crashlytics.crashlytics().log("JSON parse error for URL \(urlString): \(parseError.localizedDescription)")
                OperationQueue.main.addOperation {
                    callBack("Error parsing JSON: \(parseError.localizedDescription)" as AnyObject)
                }
            }
        }
        task.resume()
    }
    
    //MARK: - user StartUp API Calling
    
    static func userStartUpAPICalling(_ view:UIViewController?,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.UserStartUpScreen
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Wearable API Calling daily
    
    static func getWearableDataAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        accessToken: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.GetWearableData
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: "GET",
            accessToken: accessToken,
            acces: false,
            timeOut: 6,
            parameterPlacement: "url",
            callback: callBack
        )
    }
    
    //MARK: - Wearable API Calling Date Range
    
    static func getWearableDataRangeAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        accessToken: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.GetWearableDataRange
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: "GET",
            accessToken: accessToken,
            acces: false,
            timeOut: 6,
            parameterPlacement: "url",
            callback: callBack
        )
    }

    //MARK: - Wearable API Calling Period Averages

    static func getWearableDataAverageAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        accessToken: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.GetWearableAverage
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: "GET",
            accessToken: accessToken,
            acces: false,
            timeOut: 6,
            parameterPlacement: "url",
            callback: callBack
        )
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

    //MARK: - Wearable health data upload

    enum WearableUploadResult {
        case success
        /// The token was rejected. The caller may refresh headlessly and retry once.
        case unauthorized
        case failure(String)
    }

    /// Uploads one health snapshot to `patients/api/v1/health/wearable-data`.
    ///
    /// Built as its own request rather than routed through `getRequestWithToken`, following the
    /// same shape as `uploadProfileImageAPICalling`, for two reasons:
    ///
    ///  - That path calls `NoInternetBanner.shared.show()` on failure. This upload runs from
    ///    background wake-ups with nobody looking at the screen, and a banner raised then would
    ///    surface on whatever the user next opens, unprompted.
    ///  - It takes `[String: Any]`, so a typed body would have to be round-tripped through a
    ///    dictionary, giving up control over how empty values are encoded.
    ///
    /// `async` because every caller is the sync coordinator, not a view model, and returns a
    /// typed result so a 401 can be told apart from a genuine failure — the difference between
    /// "refresh the token and retry" and "leave the slot unmarked and try on the next wake-up".
    static func postWearableData(_ payload: WearableDataUploadRequest,
                                 accessToken: String) async -> WearableUploadResult {

        // The same reachability guard the rest of APIService applies, minus the banner.
        guard NetworkMonitor.shared.isConnected else {
            return .failure("No internet connection")
        }

        let urlString = APIService.BaseUrl + APIService.PostWearableData
        guard let url = URL(string: urlString) else {
            Crashlytics.crashlytics().log("Invalid URL: \(urlString)")
            return .failure("Invalid URL")
        }

        let body: Data
        do {
            body = try JSONEncoder().encode(payload)
        } catch {
            return .failure("Failed to encode payload: \(error.localizedDescription)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = body
        request.timeoutInterval = HealthSyncConfiguration.requestTimeout

        Crashlytics.crashlytics().setCustomValue(urlString, forKey: "api_url")
        Crashlytics.crashlytics().setCustomValue("POST", forKey: "http_method")

        do {
            // `URLSession.shared` rather than a fresh session: a session created per call is
            // never invalidated and leaks its delegate queue, which matters more here than for a
            // one-off profile image because this runs several times a day forever.
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                return .failure("Non-HTTP response")
            }

            switch http.statusCode {
            case 200...299:
                return .success
            case 401, 403:
                return .unauthorized
            default:
                let bodyText = String(data: data, encoding: .utf8) ?? ""
                return .failure("HTTP \(http.statusCode): \(bodyText.prefix(300))")
            }
        } catch {
            return .failure(error.localizedDescription)
        }
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
    
    static func editSaveAppointmentAPICalling(_ view: UIViewController?, params: [String: Any], method: String, accessToken: String, acces: Bool, parameterPlacement: String, callBack: @escaping (AnyObject) -> ()) {
        
        let urlString = APIService.BaseUrl+APIService.EditAppointment
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Save Appointment
    
    static func SaveAppointmentAPICalling(_ view: UIViewController?, params: [String: Any], method: String, accessToken: String, acces: Bool, parameterPlacement: String, callBack: @escaping (AnyObject) -> ()) {
        
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

    //MARK: - Weekly summary graph API Calling

    static func weeklySummaryGraphAPICalling(
        _ view: UIViewController?,
        summaryItem: WeeklySummaryItems,
        startDate: String,
        endDate: String,
        method: String,
        accessToken: String,
        acces: Bool,
        parameterPlacement: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let requestForm = summaryItem.getAPIRequestForWeeklySummary(with: startDate, endDate: endDate)
        let urlString = requestForm.baseURL + requestForm.path
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: requestForm.requestBody,
            method: method,
            accessToken: accessToken,
            acces: acces,
            timeOut: 6,
            parameterPlacement: parameterPlacement,
            callback: callBack
        )
    }

    //MARK: - Screening history API Calling

    static func screeningHistoryAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        method: String,
        accessToken: String,
        acces: Bool,
        parameterPlacement: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.ScreeningHistoryForMobile
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: method,
            accessToken: accessToken,
            acces: acces,
            timeOut: 6,
            parameterPlacement: parameterPlacement,
            callback: callBack
        )
    }

    //MARK: - Screening results API Calling

    static func screeningResultsAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        method: String,
        accessToken: String,
        acces: Bool,
        parameterPlacement: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.ScreeningResultsForMobile
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: method,
            accessToken: accessToken,
            acces: acces,
            timeOut: 6,
            parameterPlacement: parameterPlacement,
            callback: callBack
        )
    }

    //MARK: - Screening questionnaire API Calling

    static func screeningQuestionnaireAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        method: String,
        accessToken: String,
        acces: Bool,
        parameterPlacement: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.TakingControlIntroFirstScreen
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: method,
            accessToken: accessToken,
            acces: acces,
            timeOut: 6,
            parameterPlacement: parameterPlacement,
            callback: callBack
        )
    }

    //MARK: - Screening save patient answers API Calling

    static func screeningSavePatientAnswersAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        method: String,
        accessToken: String,
        acces: Bool,
        parameterPlacement: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.TakingControlIntroFirstAns
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: method,
            accessToken: accessToken,
            acces: acces,
            timeOut: 6,
            parameterPlacement: parameterPlacement,
            callback: callBack
        )
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
    
    // MARK: - Course lesson index (Discovery courses)

    static func getPatientCourseIndexAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        method: String,
        accessToken: String,
        acces: Bool,
        parameterPlacement: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.getPatientCourseIndex
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: method,
            accessToken: accessToken,
            acces: acces,
            timeOut: 6,
            parameterPlacement: parameterPlacement,
            callback: callBack
        )
    }

    // MARK: - Course work progress (weekly summary)

    static func getPatientCourseWorkPercentageDetailsAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        method: String,
        accessToken: String,
        acces: Bool,
        parameterPlacement: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.getPatientCourseWorkPercentageDetailsForMobile
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: method,
            accessToken: accessToken,
            acces: acces,
            timeOut: 6,
            parameterPlacement: parameterPlacement,
            callback: callBack
        )
    }

    // MARK: - Medical appointments list (next appointments)

    static func getMedicalAppointmentsAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        method: String,
        accessToken: String,
        acces: Bool,
        parameterPlacement: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.getMedicalAppointmentsByPatientId
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: method,
            accessToken: accessToken,
            acces: acces,
            timeOut: 6,
            parameterPlacement: parameterPlacement,
            callback: callBack
        )
    }

    // MARK: - Patient privacy (profile consent sheet)

    static func getPatientPrivacyAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        method: String,
        accessToken: String,
        acces: Bool,
        parameterPlacement: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.getPatientPrivacy
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: method,
            accessToken: accessToken,
            acces: acces,
            timeOut: 6,
            parameterPlacement: parameterPlacement,
            callback: callBack
        )
    }

    static func updatePatientConsentAPICalling(
        _ view: UIViewController?,
        params: [String: Any],
        method: String,
        accessToken: String,
        acces: Bool,
        parameterPlacement: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let urlString = APIService.BaseUrl + APIService.updatePatientConsent
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: method,
            accessToken: accessToken,
            acces: acces,
            timeOut: 6,
            parameterPlacement: parameterPlacement,
            callback: callBack
        )
    }

    //MARK: - Get Location Details in Appointment
    
    static func LocationDetailsAPICalling(_ view: UIViewController?, params: [String: Int], method: String, accessToken: String, acces: Bool, parameterPlacement: String, callBack: @escaping (AnyObject) -> ()) {
        
        let urlString = APIService.BaseUrl+APIService.LocationDetails
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Get Provider Details in Appointment
    
    static func ProviderDetailsAPICalling(_ view: UIViewController?, params: [String: Int], method: String, accessToken: String, acces: Bool, parameterPlacement: String, callBack: @escaping (AnyObject) -> ()) {
        
        let urlString = APIService.BaseUrl+APIService.ProviderDetails
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }
    
    //MARK: - Mark Medication
    
    static func MarkMedicationAPICalling(_ view:UIViewController,params:[String:Any],method:String,accessToken:String, acces:Bool,parameterPlacement:String,callBack:@escaping (AnyObject)->()) {
        
        let urlString = APIService.BaseUrl+APIService.MarkMedication
        APIService.getRequestWithToken(viewController:view, urlString: urlString, params: params, method:method, accessToken: accessToken, acces: acces,timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
    }

    // MARK: - Get / add medications (typed NetworkAPIRequest)

    static func getMedicationsAPICalling(
        params: [String: Any],
        callBack: @escaping NetworkRequestCompletionHandler<MedicationDetailsResponse>
    ) {
        let requestForm = GetMedicationsRequestForm(params)
        guard let requestURL = requestForm.getURLRequest() else {
            callBack(nil, nil, DefaultError())
            return
        }
        NetworkAPIRequest.sendRequest(request: requestURL, completionHandler: callBack)
    }

    static func addMedicationsAPICalling(
        jsonData: Data,
        callBack: @escaping NetworkRequestCompletionHandler<AddMedicationSavedResponse>
    ) {
        let requestForm = AddMedicationsRequestForm(jsonData)
        guard let requestURL = requestForm.getURLRequest() else {
            callBack(nil, nil, DefaultError())
            return
        }
        NetworkAPIRequest.sendRequest(request: requestURL, completionHandler: callBack)
    }

    // MARK: - Save patient startup screen (day feedback)

    static func savePatientStartupScreenAPICalling(
        answers: PatientLog,
        callBack: @escaping NetworkRequestCompletionHandler<ResponseDetails>
    ) {
        guard let requestForm = SaveUserStartupScreenDetailsRequestForm(answers),
              let requestURL = requestForm.getURLRequest() else {
            callBack(nil, nil, DefaultError())
            return
        }
        NetworkAPIRequest.sendRequest(request: requestURL, completionHandler: callBack)
    }

    // MARK: - Forget password (reset after OTP)

    static func forgetPasswordAPICalling(
        _ view: UIViewController?,
        emailId: String,
        password: String,
        confirmPassword: String,
        callBack: @escaping (AnyObject) -> ()
    ) {
        let params: [String: Any] = [
            "emailId": emailId,
            "password": password,
            "confirmPassword": confirmPassword,
        ]
        let urlString = APIService.BaseUrl + APIService.forgetPassword
        APIService.getRequestWithToken(
            viewController: view,
            urlString: urlString,
            params: params,
            method: "POST",
            accessToken: "",
            acces: false,
            timeOut: 6,
            parameterPlacement: "body",
            callback: callBack
        )
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

    // MARK: - Drinking getDrinksList

    static func getDrinksListAPICalling(_ view: UIViewController, params: [String: Any], method: String, accessToken: String, acces: Bool, parameterPlacement: String, callBack: @escaping (AnyObject) -> ()) {
        let urlString = APIService.BaseUrl + APIService.GetDrinksList
        APIService.getRequestWithToken(viewController: view, urlString: urlString, params: params, method: method, accessToken: accessToken, acces: acces, timeOut: 6, parameterPlacement: parameterPlacement, callback: callBack)
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
        
        // 🚫 Block API if no internet
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            callback("Error: No Internet Connection" as AnyObject)
            return
        }
        
        var request: URLRequest
        
        guard let url = URL(string: urlString) else {
            Crashlytics.crashlytics().log("Invalid URL: \(urlString)")
            callback("Error: Invalid URL" as AnyObject)
            return
        }
        
        print("the access token is \(accessToken)")
        
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
            
//            if let error = error {
//                
//                let nsError = error as NSError
//                if nsError.code == NSURLErrorTimedOut {
//                    Crashlytics.crashlytics().log("Timeout error for URL: \(urlString)")
//                } else {
//                    Crashlytics.crashlytics().log("Network error: \(error.localizedDescription)")
//                }
//                
//                callback("Error: \(error.localizedDescription)" as AnyObject)
//                return
//            }
            if let error = error {
                
                let nsError = error as NSError
                
                // 🚫 No Internet case
                if nsError.code == NSURLErrorNotConnectedToInternet ||
                   nsError.code == NSURLErrorNetworkConnectionLost {
                    
                    DispatchQueue.main.async {
                        NoInternetBanner.shared.show()
                    }
                    
                    callback("Error: No Internet Connection" as AnyObject)
                    return
                }
                
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

private extension Data {
    mutating func append(_ string: String) {
        if let d = string.data(using: .utf8) { append(d) }
    }
}
