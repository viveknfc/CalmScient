//
//  UserProfileViewController.swift
//  CalmscientIOS
//
//  Created by KA on NA.
//

import UIKit
import SVGKit

fileprivate enum ProfileTableCells : String {
    case ProfileDefaultTableViewCell = "ProfileDefaultTableViewCell"
//    case ProfileThemeTableViewCell = "ProfileThemeTableViewCell"
    case ProfileLanguageTableViewCell = "ProfileLanguageTableViewCell"
    case LogoutTableViewCell = "LogoutTableViewCell"
    
    func getCellHeight() -> CGFloat {
        switch self {
        case .ProfileDefaultTableViewCell: return 56
//        case .ProfileThemeTableViewCell:  return 82
        case .ProfileLanguageTableViewCell:  return 120
        case .LogoutTableViewCell: return 56
            
        }
    }
}

class UserProfileViewController: ViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UISheetPresentationControllerDelegate, SettingsAlarmDelegate{
    
    
    var dimmingView: UIView?
    @IBOutlet weak var profileIcon: UIImageView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var gallerySelectionImageView: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var profileTableView: UITableView!
    var languagesData: [[String: Any]] = []
    
    var imagePicker: UIImagePickerController!
    var profileIconList: [String] = []
    var cellTitleList: [String] = []
    var licenseKey : String = ""
    var alarmValue: Int = 0
    var alarmTile: String = ""
    
    fileprivate let tableRows:[ProfileTableCells] = [.ProfileDefaultTableViewCell,
                                                     
                                                     .ProfileLanguageTableViewCell,
                                                     .ProfileDefaultTableViewCell,
                                                     .ProfileDefaultTableViewCell,
                                                     .ProfileDefaultTableViewCell,
                                                     .ProfileDefaultTableViewCell,
                                                     .ProfileDefaultTableViewCell,
                                                     .LogoutTableViewCell
                            ] //.ProfileThemeTableViewCell,
    fileprivate let profileSvgIcons = ["profile_svg","language_svg","privacy_svg","alarm_svg","notification_svg","license_svg","helpNsupport_svg","logout_svg"] //"theme_svg"
    
    var shouldPopBack: Bool = false
    var shouldPopToDis: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.showToastActivity()
        
        self.navigationController?.isNavigationBarHidden = false
        self.title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Settings" : "Ajustes"
        self.alarmTile = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Alarm settings" : "Configuración de alarma"
        setupView()
        setupTableView()
        setupLanguage()
        
        profilePicAPICalling()
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }

        
        getPatientLanguages(patientId: userInfo.patientID, clientId: userInfo.clientID,bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            
                            self.languagesData = json["patientLanguages"] as! [[String : Any]]
                            print("classgetPatientLanguages===\(self.languagesData)")
                            self.profileTableView.reloadData()
                            self.view.hideToastActivity()
                            
                        }
                        
                    } else {
                        print("Unable to convert data to JSON")
                    }
                } catch {
                    print("Error converting data to JSON: \(error)")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        
        profileTableView.reloadData()
        
        
        if self.traitCollection.userInterfaceStyle == .dark {
            print("traitCollection=====,\(self.traitCollection.userInterfaceStyle)")
        } else {
            print("traitCollection=====,\(self.traitCollection.userInterfaceStyle)")
            
            // Do any additional setup after loading the view.
        }
        
        //nav bar back button start
        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)

        // Create a UIButton
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonOverrideAction), for: .touchUpInside)

        // Set constraints to adjust the size
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true // Set desired width
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true // Set desired height

        // Create a UIBarButtonItem using the UIButton
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        //end

        NotificationCenter.default.addObserver(self, selector: #selector(removeDimmingView), name: Notification.Name("RemoveDimmingView"), object: nil)
        
        shouldPopToDis = UserDefaults.standard.bool(forKey: "shouldPopToDis") //UserDefaults.standard.removeObject(forKey: "shouldPopToDis")
        print("value of shouldPopToDis is", shouldPopToDis)
    }
    
    @objc func removeDimmingView() {
        dimmingView?.removeFromSuperview()
        dimmingView = nil
        print("Dimming view removed via notification.")
    }
    
    @objc func backButtonOverrideAction() {
        
        if shouldPopBack {
            self.navigationController?.popViewController(animated: true)
        }
        else if shouldPopToDis {
            print("Navigating to Discovery main from settings")
            
            let storyboard = UIStoryboard(name: "DiscoveryMainDashboard", bundle: nil)
            if #available(iOS 16.0, *) {
                if let homeTabVC = storyboard.instantiateViewController(withIdentifier: "DiscoveryMainViewController") as? DiscoveryMainViewController {
                    self.navigationController?.pushViewController(homeTabVC, animated: true)
                }
            } else {
                // Fallback on earlier versions
            }
        }
        else {
            print("Navigating to Home Tab Dashboard from settings")
            let storyboard = UIStoryboard(name: "DashboardHomeTab", bundle: nil)
            if let homeTabVC = storyboard.instantiateViewController(withIdentifier: "HomeTabDashboardViewController") as? HomeTabDashboardViewController {
                self.navigationController?.pushViewController(homeTabVC, animated: true)
            }
        }
    
       }

    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
                self.versionLabel.text = AppHelper.getLocalizeString(str: "Version 1.0.1")
               
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
                self.versionLabel.text = AppHelper.getLocalizeString(str: "Version 1.0.1")

            }
        }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
        
        
        if let customFont = UIFont(name: Fonts().lexendMedium, size: 18) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            
            appearance.titleTextAttributes = [
                .font: customFont,
                .foregroundColor: UIColor.black
            ]

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let presentingVC = presentingViewController as? UserProfileViewController {
            // Hide or remove the dimming view
            presentingVC.dimmingView?.removeFromSuperview()
        }
    }

    func updateUserLanguage(patientId: Int, clientId: Int, languageId: Int,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL
        guard let url = URL(string: "\(baseURLString)identity/api/v1/settings/updateUserLanguage") else {
            print("Invalid URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        
        let payload: [String: Any] = [
            "patientId": patientId,
            "clientId": clientId,
            "languageId": languageId,
            "flag":1
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
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
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                //  print("Response JSON: \(jsonResponse)")
            } catch {
                print("Error parsing JSON response: \(error)")
                completion(.failure(error))
                return
            }
            // If needed, handle the response here
            completion(.success(data))
        }
        
        // Start the data task
        task.resume()
    }

    func getUserTheme(patientId: Int, clientId: Int, bearerToken: String,dark: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL
        guard let url = URL(string: "\(baseURLString)identity/api/v1/settings/updatePatientTheme") else {
            print("Invalid URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        
        // Define the JSON payload
        let payload: [String: Any] = [
            "patientId": patientId,
            "clientId": clientId,
            "dark": dark
        ]
        
        print("the payload for theme change api is", payload)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
//            print(jsonData)
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
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                //  print("Response JSON: \(jsonResponse)")
            } catch {
                print("Error parsing JSON response: \(error)")
                completion(.failure(error))
                return
            }
            // If needed, handle the response here
            completion(.success(data))
        }
        
        // Start the data task
        task.resume()
    }
    
    func getPatientLanguages(patientId: Int, clientId: Int, bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL
        guard let url = URL(string: "\(baseURLString)identity/api/v1/settings/getPatientLanguages") else {
            print("Invalid URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        
        // Define the JSON payload
        let payload: [String: Any] = [
            "patientId": patientId,
            "clientId": clientId,
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
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
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                //  print("Response JSON: \(jsonResponse)")
            } catch {
                print("Error parsing JSON response: \(error)")
                completion(.failure(error))
                return
            }
            // If needed, handle the response here
            completion(.success(data))
        }
        
        // Start the data task
        task.resume()
    }
    
    private func setupView() {
        
        profileIcon.layer.cornerRadius = self.profileIcon.frame.size.width / 2
        profileIcon.clipsToBounds = true
        profileIcon.contentMode = .scaleAspectFill

        profileIcon.layer.borderWidth = 2.0
        profileIcon.layer.borderColor = UIColor(hex: "#6E6BB3").cgColor
        circleView.layer.cornerRadius = circleView.bounds.width / 2
        circleView.layer.masksToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didClickOnGallerSelectionImage(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        self.gallerySelectionImageView.isUserInteractionEnabled = true
        self.gallerySelectionImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "ProfileLanguageTableViewCell", bundle: nil)
        profileTableView.register(nib, forCellReuseIdentifier: "ProfileLanguageTableViewCell")
        let dafaultNib = UINib(nibName: "ProfileDefaultTableViewCell", bundle: nil)
        profileTableView.register(dafaultNib, forCellReuseIdentifier: "ProfileDefaultTableViewCell")
        let darkmodeNib = UINib(nibName: "ProfileThemeTableViewCell", bundle: nil)
        profileTableView.register(darkmodeNib, forCellReuseIdentifier: "ProfileThemeTableViewCell")
        profileTableView.separatorStyle = .none
        let nib1 = UINib(nibName: "LogoutTableViewCell", bundle: nil)
        profileTableView.register(nib1, forCellReuseIdentifier: "LogoutTableViewCell")
        
        profileTableView.dataSource = self
        profileTableView.delegate = self
    }
    private func handleLanguageSelection(languageId: Int) {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        updateUserLanguage(patientId: userInfo.patientID, clientId: userInfo.clientID,languageId: languageId ,bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            print(json)
                           
                            let userProfileViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
                            self.navigationController?.pushViewController(userProfileViewController, animated: false)
                            
                            self.dimmingView?.removeFromSuperview()

                        }
                        
                    } else {
                        print("Unable to convert data to JSON")
                    }
                } catch {
                    print("Error converting data to JSON: \(error)")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
    @objc func didClickOnGallerSelectionImage(_ sender: UITapGestureRecognizer) {

        let alert = UIAlertController(title: "Profile Picture", message: "Choose an option", preferredStyle: .actionSheet)
           
           // Option to select a picture from the photo library
           let choosePhotoAction = UIAlertAction(title: "Choose Photo", style: .default) { _ in
               self.view.showToastActivity()
               self.imagePicker = UIImagePickerController()
               self.imagePicker.delegate = self
               self.imagePicker.sourceType = .photoLibrary
               self.present(self.imagePicker, animated: true, completion: nil)
           }
           
           // Option to delete the profile picture
           let deletePhotoAction = UIAlertAction(title: "Delete Photo", style: .destructive) { _ in
              
               self.deleteProfilePicture()
           }
           
           // Cancel action
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
           
           // Add actions to the alert controller
           alert.addAction(choosePhotoAction)
           alert.addAction(deletePhotoAction)
           alert.addAction(cancelAction)
           
           // Present the alert controller
           present(alert, animated: true, completion: nil)
    }
    
    func deleteProfilePicture() {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Int] = ["patientId": userInfo.patientID, "clientId": userInfo.clientID]
        print("Params of Profile pic deleeete api is :", params)
        self.view.showToastActivity()
        APIService.DeleteProfilePicAPICalling(self, params: params, method: "DELETE", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "url") {  [self] response in
            // Your closure code here
            getresponseforDeleteProfilePicAPI(response: response)
        }
        
        
    }
    
    //MARK: - Delete API Response
    
    func getresponseforDeleteProfilePicAPI(response:AnyObject)->() {
        self.view.hideToastActivity()
        if let responseDict = response as? [String: Any],
           let status = responseDict["status"] as? [String: Any],
           let responseCode = status["responseCode"] as? Int, responseCode == 200 {
            print("the delete profile pic response is", status)
            self.profileIcon.image = UIImage(named: "profileIcon")  // Remove the profile image
        } else {
            print("Unsupported response type or failed status:", type(of: response))
        }
    }
    
    //END
    
    //MARK: - Profile Pic API Calling
    
    func profilePicAPICalling() {
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let payload: [String: Any] = [
            "plId": userInfo.patientLocationID,
            "patientId": userInfo.patientID,
            "clientId": userInfo.clientID,
        ]
        self.view.showToastActivity()
        print("param for user profile is",payload)
        
        APIService.profilePicAPICalling(
            self,
            params: payload,
            method: "POST",
            accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken,
            acces: false,
            parameterPlacement: "body"
        ) { response in
            self.handleUserProfileResponse1(response: response)
            
        }
        
    }
    
    //MARK: - Profile Pic API Response
    
    func handleUserProfileResponse1(response: AnyObject) -> () {
        DispatchQueue.main.async {
            self.view.hideToastActivity()
        }
        
        if let responseString = response as? String {
            print("Response received from Profile API is:", responseString)
        } else if let responseDict = response as? [String: Any] {
            print("Parsed Profile API Response:", responseDict)
            
            guard let settings = responseDict["settings"] as? [String: Any] else {
                print("Settings not found in response")
                return
            }

            // Load profile image
            if let imageUrlString = settings["profileImage"] as? String,
               let url = URL(string: imageUrlString) {
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.profileIcon.image = image
                        }
                    } else {
                        print("Failed to load profile image: \(error?.localizedDescription ?? "No error info")")
                    }
                }.resume()
            }
            
            // PROFILE
            if let title = settings["profileTitle"] as? String {
                self.cellTitleList.append(title)
            }

            // LANGUAGE
            if let title = settings["languageTitle"] as? String {
                self.cellTitleList.append(title)
            }

            // PRIVACY
            if let title = settings["privacyTitle"] as? String {
                self.cellTitleList.append(title)
            }

            // ALARM
            if let alarmDuration = settings["alarmDuration"] as? Int {
                self.alarmValue = alarmDuration
                print("the alarm duration is",self.alarmValue)
                let alarmTitle = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Alarm settings" : "Configuración de alarma"
                self.cellTitleList.append(alarmTitle)
            }

            // NOTIFICATIONS
            if let title = settings["notificationTitle"] as? String {
                self.cellTitleList.append(title)
            }

            // LICENSE
            if let licenseDetails = settings["licenseDetails"] as? [String: Any] {
                if let title = licenseDetails["licenseTitle"] as? String {
                    self.cellTitleList.append(title)
                }
                self.licenseKey = licenseDetails["licenseKey"] as? String ?? ""
            }

            // HELP & SUPPORT
            if let title = settings["helpTitle"] as? String {
                self.cellTitleList.append(title)
            }

            // LOGOUT
            if let title = settings["logoutTitle"] as? String {
                self.cellTitleList.append(title)
            }


            // Reload the table
            DispatchQueue.main.async {
                self.profileTableView.reloadData()
            }
        } else {
            print("Unsupported response type:", type(of: response))
        }
    }

    
    //MARK: - Settings Delegate
    
    func didUpdateAlarmValue(_ newValue: Int) {
        self.alarmValue = newValue
        // Optionally reload table or other UI
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Dismiss the image picker
        picker.dismiss(animated: true, completion: nil)
        
        // Get the selected image
        guard let image = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        
        let resizedImage = resizeImage(image: image, targetSize: CGSize(width: 500, height: 500))
        guard let imageData = resizedImage?.jpegData(compressionQuality: 0.5) else {
            print("Unable to convert image to data")
            return
        }
        
        
        // Define the filename (e.g., "profile.jpg")
        let fileName = "profile.jpeg"
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        uploadProfileImage(patientId:  userInfo.patientID, clientId: userInfo.clientID, fileData: imageData, fileName: fileName, bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken
) { result in
            switch result {
            case .success(let data):
                print("the data receiving from upload profile pic is", data)
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any] {
                        DispatchQueue.main.async {
                            print("uploadProfileImage===\(json)")
                            self.profileIcon.image = UIImage(data: imageData)
                            
                            // Ensure circular shape
                           self.profileIcon.layer.cornerRadius = self.profileIcon.frame.size.width / 2
                           self.profileIcon.clipsToBounds = true
                           self.profileIcon.contentMode = .scaleAspectFill
                            
                            self.view.hideToastActivity()
                        }
                    } else {
                        print("Unable to convert data to JSON")
                        DispatchQueue.main.async {
                            self.view.hideToastActivity()
                        }
                    }
                } catch {
                    print("Error converting data to JSON: \(error)")
                    DispatchQueue.main.async {
                        self.view.hideToastActivity()
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                }
            }
        }

    }

       // This method is called when the user cancels the image picker
       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           // Dismiss the image picker
           picker.dismiss(animated: true, completion: nil)
       }
    
    //MARK: - For resizing image
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?
            CGSize(width: size.width * heightRatio, height: size.height * heightRatio) :
            CGSize(width: size.width * widthRatio, height: size.height * widthRatio)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

}
@available(iOS 16.0, *)
private func setAppDarkMode(_ isDarkMode: Bool) {
    if let sceneDelegate = UIApplication.shared.connectedScenes
        .first(where: { $0.activationState == .foregroundActive })?
        .delegate as? SceneDelegate {
        
        let style: UIUserInterfaceStyle = isDarkMode ? .dark : .light
        sceneDelegate.changeToUserInterfaceStyle(style)
    }
}
func uploadProfileImage( patientId: Int, clientId: Int, fileData: Data, fileName: String, bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
    // Define the URL
    let validURL = APIService.BaseUrl + "identity/api/v1/settings/uploadProfileImage" //"https://calmscient.in/api/identity/api/v1/settings/uploadProfileImage"
    guard let url = URL(string: validURL) else {
        print("Invalid URL")
        return
    }
    
    print("the input param for upload profile image is patient id ", patientId, " client id ",clientId, " file name is ",fileName,"file data is \n", fileData)
    print("fileData first 100 bytes:", fileData.prefix(100))


    // Create the request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    let boundary = UUID().uuidString
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")

    // Create the multipart form data
    var body = Data()

    // Add the patientId field
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"patientId\"\r\n\r\n")
    body.append("\(patientId)\r\n")
    
    // Add the clientId field
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"clientId\"\r\n\r\n")
    body.append("\(clientId)\r\n")

    // Add the file field
    body.append("--\(boundary)\r\n")
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n")
    body.append("Content-Type: image/jpeg\r\n\r\n")

//    body.append("Content-Type: application/octet-stream\r\n\r\n")
    body.append(fileData)
    body.append("\r\n")

    // End the boundary
//    body.append("--\(boundary)--\r\n")
    body.append("--\(boundary)--\r\n\r\n")

   
    print("body=======\(body)")
    // Set the request body
    request.httpBody = body
    request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")

    print("the final request is", request)

    // Create the URLSession data task
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error with request: \(error)")
            completion(.failure(error))
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print("HTTP Status Code:", httpResponse.statusCode)
        }


        guard let data = data else {
            print("No data received")
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            return
        }
        
        // Return the data for further processing
        completion(.success(data))
    }

    // Start the data task
    task.resume()
}

// Extension to append data to a Data object
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
@available(iOS 16.0, *)
extension UserProfileViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTitleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = tableRows[indexPath.row]
        switch data {
        case .ProfileDefaultTableViewCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: data.rawValue, for: indexPath) as! ProfileDefaultTableViewCell
            
            cell.cellIconView.image = UIImage(named: profileSvgIcons[indexPath.row])

            cell.cellTitleLabel.text = cellTitleList[indexPath.row]
            return cell
            
//        case .ProfileThemeTableViewCell:
            
            //VIV STart
            
//            let cell = tableView.dequeueReusableCell(withIdentifier: data.rawValue, for: indexPath) as! ProfileThemeTableViewCell
//            let imageUrlString = profileIconList[indexPath.row]
//
//            if let url = URL(string: imageUrlString) {
//                let task = URLSession.shared.dataTask(with: url) { data, response, error in
//                    guard let data = data, error == nil else {
//                        print("Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
//                        return
//                    }
//                    
//                    DispatchQueue.main.async {
//                        cell.darkmodeLbl.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Dark Mode" : "la noche"
//                        
//                        cell.cellIconView.image = UIImage(named: self.profileSvgIcons[indexPath.row])
//                        
//                        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
//                            fatalError("Unable to found Application Shared Info")
//                        }
//                        
//                        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
//                        let lan = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
//                        
//                        let imageName = isDarkMode ? (lan == 1 ? "ToggleSwitch_Yes" : "ToggleSwitch_Si") : "ToggleSwitch_No"
//                        print("dark mode change button image is",imageName)
//                        cell.darkModeChangeButton.setImage(UIImage(named: imageName), for: .normal)
//                        
//                        cell.darkModeChangeButton.imageView?.contentMode = .scaleAspectFill
//                        cell.darkModeChangeButtonAction = { [weak self, weak cell] in
//                            guard let self = self, let cell = cell else { return }
//                            
//                            let currentDarkModeState = UserDefaults.standard.bool(forKey: "isDarkMode")
//                            let newDarkModeState = !currentDarkModeState
//
//                            UserDefaults.standard.set(newDarkModeState, forKey: "isDarkMode")
//                            setAppDarkMode(newDarkModeState)
//                            print("change action button clicked", newDarkModeState)
//                            
//                            let newImageName = newDarkModeState ? (lan == 1 ? "ToggleSwitch_Yes" : "ToggleSwitch_Si") : "ToggleSwitch_No"
//                            cell.darkModeChangeButton.setImage(UIImage(named: newImageName), for: .normal)
//                            print("dark mode change button image while clicking is",newImageName)
//                            
//                            
//                            self.getUserTheme(
//                                patientId: userInfo.patientID,
//                                clientId: userInfo.clientID,
//                                bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken,
//                                dark: newDarkModeState ? 1 : 0
//                            ) { result in
//                                DispatchQueue.main.async {
//                                    switch result {
//                                    case .success(let data):
//                                        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                                            print("response for themee change api is ",json)
//                                        } else {
//                                            print("Unable to convert data to JSON")
//                                        }
//                                    case .failure(let error):
//                                        print("Error: \(error)")
//                                    }
//                                }
//                            }
//                            
//                            DispatchQueue.main.async {
//                                if let tableView = cell.getTableView() {
//                                    let indexPath = IndexPath(row: 2, section: 0)
//                                    tableView.reloadRows(at: [indexPath], with: .automatic)
//                                }
//                            }
//                        }
//                    }
//                }
//                task.resume() // Start the async request
//            }
//  
//            cell.cellTitleLabel.text = cellTitleList[indexPath.row]
//            return cell
        
            //END
            
        case .ProfileLanguageTableViewCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: data.rawValue, for: indexPath) as! ProfileLanguageTableViewCell
//            let imageUrlString = profileIconList[indexPath.row]
//            if let url = URL(string: imageUrlString) {
//                DispatchQueue.global().async {
//                    if let data = try? Data(contentsOf: url) {
//                        DispatchQueue.main.async {
//                            cell.cellIconView.image = UIImage(data: data)
                            cell.cellIconView.image = UIImage(named: self.profileSvgIcons[indexPath.row])
                            cell.languagesArray = self.languagesData
//                            cell.delegate = self
                            cell.languageSelectionClosure = { [weak self] languageId in
                                
                                if let window = UIApplication.shared.connectedScenes
                                    .compactMap({ $0 as? UIWindowScene })
                                    .first?.windows.first(where: { $0.isKeyWindow }) {
                                    let dimmingView = UIView(frame: window.bounds)
                                    dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                                    dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                                    window.addSubview(dimmingView)
                                    self?.dimmingView = dimmingView
                                }

                               
                                self?.view.showToastActivity()
                                self?.handleLanguageSelection(languageId: languageId)
                                
                                UserDefaults.standard.set(languageId, forKey: "SelectedLanguageID")

                                if languageId == 1 {
                                    UserDefaults.standard.set("en", forKey: "appLanguage")
                                    Bundle.setLanguage("en")
                                }
                                if languageId == 2 {
                                    UserDefaults.standard.set("es", forKey: "appLanguage")
                                    Bundle.setLanguage("es")
                                    
                                }
                            }
                            
                            
//                        }
//                    }
//                }
//                
//            }
            print("-4-4-4-4-4--4")
            print(cellTitleList[indexPath.row])
            cell.cellTitleLabel.text = cellTitleList[indexPath.row]
            
            
            return cell
            
        case .LogoutTableViewCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: data.rawValue, for: indexPath) as! LogoutTableViewCell
            cell.cellIconView.image = UIImage(named: self.profileSvgIcons[indexPath.row])
//            let imageUrlString = profileIconList[indexPath.row]
//            if let url = URL(string: imageUrlString) {
//                DispatchQueue.global().async {
//                    if let data = try? Data(contentsOf: url) {
//                        DispatchQueue.main.async {
//                            cell.cellIconView.image = UIImage(data: data)
//                            
//                        }
//                    }
//                }
//            }
            cell.cellTitleLabel.text = cellTitleList[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableRows[indexPath.row].getCellHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            
            let next = UIStoryboard(name: "ProfileViewController", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController
            vc?.title = AppHelper.getLocalizeString(str: "Profile")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        if indexPath.row == 2 {

            let next = UIStoryboard(name: "ProfilePrivacy", bundle: nil)
            guard let viewControllerToPresent = next.instantiateViewController(withIdentifier: "ProfilePrivacyViewController") as? ProfilePrivacyViewController else {
                return
            }
            
            addDimmingView()
            
            if let sheet = viewControllerToPresent.sheetPresentationController {
                sheet.detents = [
                    UISheetPresentationController.Detent.medium(),
                    UISheetPresentationController.Detent.large()
                ]
                sheet.largestUndimmedDetentIdentifier = UISheetPresentationController.Detent.Identifier.medium
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                sheet.prefersGrabberVisible = true
            }

            present(viewControllerToPresent, animated: true, completion: nil)

        }
        
        if indexPath.row == 3 {
            let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
            guard let settingsVC = storyboard.instantiateViewController(withIdentifier: "settingsAlarmVC") as? settingsAlarmVC else {
                return
            }
            print("the alarm value passing from here is",alarmValue)
            settingsVC.selectedIndex = alarmValue
            
            settingsVC.delegate = self
            
            // Add custom dimming view
            addDimmingView()
            
                if let sheet = settingsVC.sheetPresentationController {
                    sheet.detents = [
                        UISheetPresentationController.Detent.medium(),
                        UISheetPresentationController.Detent.large()
                    ]
                    sheet.largestUndimmedDetentIdentifier = UISheetPresentationController.Detent.Identifier.medium
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.prefersEdgeAttachedInCompactHeight = true
                    sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                    sheet.prefersGrabberVisible = true
                }
//            settingsVC.presentationController?.delegate = self
            present(settingsVC, animated: true, completion: nil)
        }

        
        if indexPath.row == 5 {
            let alert = UIAlertController(title:UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "License Key" : "Clave de Licencia", message: self.licenseKey, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        }
        if indexPath.row == 7 {
            
            
            //  func showAlert() {
            // Create the alert controller
            let alertController = UIAlertController(title: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Confirmation" : "Confirmación", message: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Are you sure you want to logout?" : "¿Estás seguro de que quieres cerrar sesión?", preferredStyle: .alert)
            
            // Create the "Yes" action
            let yesAction = UIAlertAction(title:  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Yes" : "Sí", style: .default) { _ in
                print("User tapped Yes")
                let next = UIStoryboard(name: "LoginVC", bundle: nil)
                UserDefaults.standard.set(0, forKey: "rememberMe")
                
                UserDefaultsHelper.clearLoginDetailsFromUserDefaults()
                ApplicationSharedInfo.shared.loginResponse = nil
                ApplicationSharedInfo.shared.tokenResponse = nil
                
                // to Remove all Alarms in medications page
                self.removeAllAlarms()
                
                self.clearFavorites()
                
                // Add your code to handle the "Yes" action here
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    let newViewController = next.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                    let navController = UINavigationController(rootViewController: newViewController)
                    sceneDelegate.changeRootViewController(to: navController)
                }

            }
            
            // Create the "No" action
            let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
                print("User tapped No")
                alertController.dismiss(animated: true)
                // Add your code to handle the "No" action here
            }
            
            // Add the actions to the alert controller
            alertController.addAction(yesAction)
            alertController.addAction(noAction)
            
            // Present the alert
            present(alertController, animated: true, completion: nil)
            //  }
   
        }
        
    }
    
    //MARK: - Adding dimming view
    
    func addDimmingView() {
        if dimmingView == nil {
            if let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {

                dimmingView = UIView(frame: window.bounds)
                dimmingView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                dimmingView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                window.addSubview(dimmingView!)
                print("Dimming view added.")
            }
        }
    }
    
    func clearFavorites() {
        UserDefaults.standard.removeObject(forKey: "favoriteExcersises")
        UserDefaults.standard.removeObject(forKey: "favoriteItems")
        UserDefaults.standard.set(false, forKey: "hasFetchedFavorites")
        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: .favoritesUpdated, object: nil) // Notify UI
    }
 
    func removeAllAlarms() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("All alarms have been removed.")
    }
    
    func clearUserDefaults() {
        let defaults = UserDefaults.standard
        if let appDomain = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: appDomain)
        }
        defaults.synchronize()
    }

}

extension UITableViewCell {
    func getTableView() -> UITableView? {
        var view = self.superview
        while let superview = view, !(superview is UITableView) {
            view = superview.superview
        }
        return view as? UITableView
    }
}

//extension UserProfileViewController: UIAdaptivePresentationControllerDelegate {
//    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
//        print("presentationControllerDidDismiss called")
//        if let dimmingView = self.dimmingView {
//            dimmingView.removeFromSuperview()
//            self.dimmingView = nil
//            print("Dimming view removed in presentationControllerDidDismiss.")
//        }
//    }
//}
//
//private struct AssociatedKeys {
//    static var dimmingView: UInt8 = 0
//}




