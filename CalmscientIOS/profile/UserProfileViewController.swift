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
    case ProfileThemeTableViewCell = "ProfileThemeTableViewCell"
    case ProfileLanguageTableViewCell = "ProfileLanguageTableViewCell"
    case LogoutTableViewCell = "LogoutTableViewCell"
    
    func getCellHeight() -> CGFloat {
        switch self {
        case .ProfileDefaultTableViewCell: return 56
        case .ProfileThemeTableViewCell:  return 82
        case .ProfileLanguageTableViewCell:  return 120
        case .LogoutTableViewCell: return 56
            
        }
    }
}

class UserProfileViewController: ViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UISheetPresentationControllerDelegate{
    
    
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
    
    fileprivate let tableRows:[ProfileTableCells] = [.ProfileDefaultTableViewCell,
                                                     .ProfileThemeTableViewCell,
                                                     .ProfileLanguageTableViewCell,
                                                     .ProfileDefaultTableViewCell,
                                                     .ProfileDefaultTableViewCell,
                                                     .ProfileDefaultTableViewCell,
                                                     .ProfileDefaultTableViewCell,
                                                     .LogoutTableViewCell
                            ]
    fileprivate let profileSvgIcons = ["profile_svg","theme_svg","language_svg","privacy_svg","notification_svg","license_svg","helpNsupport_svg","logout_svg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.showToastActivity()
        
        self.navigationController?.isNavigationBarHidden = false
        self.title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Settings" : "Ajustes"
        setupView()
        setupTableView()
        setupLanguage()
        
        
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        getUserProfile(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID,bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken){ [self] result in
            switch result {
            case .success(let data):
                handleUserProfileResponse(data: data)
            case .failure(let error):
                print("Error: \(error)")
            }
            
        }
        
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

    }
    
    @objc func backButtonOverrideAction() {

            print("Navigating to Home Tab Dashboard from settings")
            let storyboard = UIStoryboard(name: "DashboardHomeTab", bundle: nil)
            if let homeTabVC = storyboard.instantiateViewController(withIdentifier: "HomeTabDashboardViewController") as? HomeTabDashboardViewController {
                self.navigationController?.pushViewController(homeTabVC, animated: true)
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
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let presentingVC = presentingViewController as? UserProfileViewController {
            // Hide or remove the dimming view
            presentingVC.dimmingView?.removeFromSuperview()
        }
    }
    func handleUserProfileResponse(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let settings = json["settings"] as? [String: Any] {
                DispatchQueue.main.async {
                    print("getUserProfile,\(json)")
                    self.view.hideToastActivity()
                    
                    if let imageUrlString = settings["profileImage"] as? String, let url = URL(string: imageUrlString) {
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: url) {
                                DispatchQueue.main.async {
                                     self.profileIcon.image = UIImage(data: data)
                                }
                            }
                        }
                    }
                    if let profileIcon = settings["profileIcon"] as? String {
                        self.profileIconList.append(profileIcon)
                    }
                    if let profileTitle = settings["profileTitle"] as? String {
                        self.cellTitleList.append(profileTitle)
                    }
                    if let themeDetails = settings["themeDetails"] as? [String: Any] {
                        if let themeIcon = themeDetails["themeIcon"] as? String {
                            self.profileIconList.append(themeIcon)
                        }
                        if let themeTitle = themeDetails["themeTitle"] as? String {
                            self.cellTitleList.append(themeTitle)
                        }
                    }
                    if let languageIcon = settings["languageIcon"] as? String {
                        self.profileIconList.append(languageIcon)
                    }
                    if let languageTitle = settings["languageTitle"] as? String {
                        self.cellTitleList.append(languageTitle)
                    }
                    
                    if let privacyIcon = settings["privacyIcon"] as? String {
                        self.profileIconList.append(privacyIcon)
                    }
                    if let privacyTitle = settings["privacyTitle"] as? String {
                        self.cellTitleList.append(privacyTitle)
                    }
                    if let notificationIcon = settings["notificationIcon"] as? String {
                        self.profileIconList.append(notificationIcon)
                    }
                    if let notificationTitle = settings["notificationTitle"] as? String {
                        self.cellTitleList.append(notificationTitle)
                    }
                    if let licenseDetails = settings["licenseDetails"] as? [String: Any] {
                        if let licenseIcon = licenseDetails["licenseIcon"] as? String {
                            self.profileIconList.append(licenseIcon)
                        }
                        if let licenseTitle = licenseDetails["licenseTitle"] as? String {
                            self.cellTitleList.append(licenseTitle)
                        }
                        self.licenseKey = licenseDetails["licenseKey"] as! String
                    }
                    if let helpIcon = settings["helpIcon"] as? String {
                        self.profileIconList.append(helpIcon)
                    }
                    if let helpTitle = settings["helpTitle"] as? String {
                        self.cellTitleList.append(helpTitle)
                    }
                    if let logoutIcon = settings["logoutIcon"] as? String {
                        self.profileIconList.append(logoutIcon)
                    }
                    if let logoutTitle = settings["logoutTitle"] as? String {
                        self.cellTitleList.append(logoutTitle)
                    }
                    
                    // Reload table view or perform any UI updates
                    print("profileIconList:\(self.profileIconList)")
                    print("cellTitleList:\(self.cellTitleList)")
                    self.profileTableView.reloadData()
                }
            } else {
                print("Unable to convert data to JSON")
            }
        } catch {
            print("Error converting data to JSON: \(error)")
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
    func getUserProfile(plId: Int, patientId: Int, clientId: Int, bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL
        guard let url = URL(string: "\(baseURLString)identity/api/v1/settings/getUserProfile") else {
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
            "plId": plId,
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
                _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
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
        APIService.DeleteProfilePicAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") {  [self] response in
            // Your closure code here
            getresponseforDeleteProfilePicAPI(response: response)
        }
        
        
    }
    
    //MARK: - Delete API Response
    
    func getresponseforDeleteProfilePicAPI(response:AnyObject)->() {
        self.view.hideToastActivity()
        if let responseString = response as? String {
            print("Response received from Delete Profile Pic API calling is", responseString)
        } else if let responseDict = response as? [String: Any] {
            if let responseMessage = responseDict["responseMessage"] as? String {
                print("Response Message:", responseMessage)
            }

        } else {
            print("Unsupported response type:", type(of: response))
        }
    }
    
    //END
    
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
    guard let url = URL(string: "http://20.197.5.97:8083/identity/api/v1/settings/uploadProfileImage") else {
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
        case .ProfileThemeTableViewCell:
            
            //VIV STart
            
            let cell = tableView.dequeueReusableCell(withIdentifier: data.rawValue, for: indexPath) as! ProfileThemeTableViewCell
            let imageUrlString = profileIconList[indexPath.row]

            if let url = URL(string: imageUrlString) {
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        cell.darkmodeLbl.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Dark Mode" : "la noche"
                        
                        cell.cellIconView.image = UIImage(named: self.profileSvgIcons[indexPath.row])
                        
                        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
                            fatalError("Unable to found Application Shared Info")
                        }
                        
                        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
                        let lan = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
                        
                        let imageName = isDarkMode ? (lan == 1 ? "ToggleSwitch_Yes" : "ToggleSwitch_Si") : "ToggleSwitch_No"
                        cell.darkModeChangeButton.setImage(UIImage(named: imageName), for: .normal)
                        
                        cell.darkModeChangeButton.imageView?.contentMode = .scaleAspectFill
                        cell.darkModeChangeButtonAction = { [weak self, weak cell] in
                            guard let self = self, let cell = cell else { return }
                            
                            let newDarkModeState = !isDarkMode
                            setAppDarkMode(newDarkModeState)
                            
                            let newImageName = newDarkModeState ? (lan == 1 ? "ToggleSwitch_Yes" : "ToggleSwitch_Si") : "ToggleSwitch_No"
                            cell.darkModeChangeButton.setImage(UIImage(named: newImageName), for: .normal)
                            
                            UserDefaults.standard.set(newDarkModeState, forKey: "isDarkMode")
                            
                            self.getUserTheme(
                                patientId: userInfo.patientID,
                                clientId: userInfo.clientID,
                                bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken,
                                dark: newDarkModeState ? 1 : 0
                            ) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success(let data):
                                        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                            print(json)
                                        } else {
                                            print("Unable to convert data to JSON")
                                        }
                                    case .failure(let error):
                                        print("Error: \(error)")
                                    }
                                }
                            }
                            
                            DispatchQueue.main.async {
                                if let tableView = cell.getTableView() {
                                    let indexPath = IndexPath(row: 2, section: 0)
                                    tableView.reloadRows(at: [indexPath], with: .automatic)
                                }
                            }
                        }
                    }
                }
                task.resume() // Start the async request
            }

            
            //END
            
            
//            let cell = tableView.dequeueReusableCell(withIdentifier: data.rawValue, for: indexPath) as! ProfileThemeTableViewCell
//            if let imageUrlString = profileIconList[indexPath.row] as? String, let url = URL(string: imageUrlString) {
//                DispatchQueue.global().async {
//                    if let data = try? Data(contentsOf: url) {
//                        DispatchQueue.main.async {
//                            cell.darkmodeLbl.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Dark Mode" : "la noche"
//
//                            cell.cellIconView.image = UIImage(named: self.profileSvgIcons[indexPath.row])
//                            guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
//                                fatalError("Unable to found Application Shared Info")
//                            }
//                            
//                            let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
//                            let lan = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
//                            
//                            if lan == 1 {
//                                cell.darkModeChangeButton.setImage(UIImage(named: isDarkMode ? "ToggleSwitch_Yes" : "ToggleSwitch_No"), for: .normal)
//                            } else {
//                                cell.darkModeChangeButton.setImage(UIImage(named: isDarkMode ? "ToggleSwitch_Si" : "ToggleSwitch_No"), for: .normal)
//                            }
//                            
//                            
//                            cell.darkModeChangeButton.imageView?.contentMode = .scaleAspectFill
//                            cell.darkModeChangeButtonAction = { [weak self, weak cell] in
//                                guard let self = self, let cell = cell else { return }
//                                if cell.darkModeChangeButton.currentImage == UIImage(named: "ToggleSwitch_No") {
//                                    setAppDarkMode(true)
//                                    
//                                    if lan == 1 {
//                                        cell.darkModeChangeButton.setImage(UIImage(named: "ToggleSwitch_Yes"), for: .normal)
//                                    }else {
//                                        cell.darkModeChangeButton.setImage(UIImage(named: "ToggleSwitch_Si"), for: .normal)
//                                    }
//                                    
//                                    UserDefaults.standard.set(true, forKey: "isDarkMode")
//                                    
//                                    self.getUserTheme( patientId: userInfo.patientID, clientId: userInfo.clientID,bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, dark : 1) { [self] result in
//                                        switch result {
//                                        case .success(let data):
//                                            // Convert data to JSON object and print it
//                                            do {
//                                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                                                    DispatchQueue.main.async {
//                                                        print(json)
//                                                        
//                                                    }
//                                                    
//                                                } else {
//                                                    print("Unable to convert data to JSON")
//                                                }
//                                            } catch {
//                                                print("Error converting data to JSON: \(error)")
//                                            }
//                                        case .failure(let error):
//                                            print("Error: \(error)")
//                                        }
//                                    }
//                                    let indexPath = IndexPath(row: 2, section: 0)
//                                            tableView.reloadRows(at: [indexPath], with: .automatic)
//                                    print("Switch is ON")
//                                } else {
//                                    setAppDarkMode(false)
//                                    
//                                    cell.darkModeChangeButton.setImage(UIImage(named: "ToggleSwitch_No"), for: .normal)
//                                    UserDefaults.standard.set(false, forKey: "isDarkMode")
//                                    
//                                    self.getUserTheme( patientId: userInfo.patientID, clientId: userInfo.clientID,bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, dark : 0) { [self] result in
//                                        switch result {
//                                        case .success(let data):
//                                            // Convert data to JSON object and print it
//                                            do {
//                                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                                                    DispatchQueue.main.async {
//                                                        print(json)
//                                                        
//                                                    }
//                                                    
//                                                } else {
//                                                    print("Unable to convert data to JSON")
//                                                }
//                                            } catch {
//                                                print("Error converting data to JSON: \(error)")
//                                            }
//                                        case .failure(let error):
//                                            print("Error: \(error)")
//                                        }
//                                    }
//                                    let indexPath = IndexPath(row: 2, section: 0)
//                                            tableView.reloadRows(at: [indexPath], with: .automatic)
//                                }
//                            }
//                            
//                        }
//                    }
//                }
//            }
            
            
            
            guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
                fatalError("Unable to found Application Shared Info")
            }
            cell.switchValueChanged = { isOn in
                
                if isOn {
                    setAppDarkMode(true)
                    UserDefaults.standard.set(true, forKey: "isDarkMode")
                    cell.darkModeSwitch.onImage = UIImage(named: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "ToggleSwitch_Yes" : "ToggleSwitch_Si")
                    
                    self.getUserTheme( patientId: userInfo.patientID, clientId: userInfo.clientID,bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, dark : 1) { [self] result in
                        switch result {
                        case .success(let data):
                            // Convert data to JSON object and print it
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                    DispatchQueue.main.async {
                                        print(json)
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
                    print("Switch is ON")
                } else {
                    setAppDarkMode(false)
                    UserDefaults.standard.set(false, forKey: "isDarkMode")
                    cell.darkModeSwitch.onImage = UIImage(named: "ToggleSwitch_No")
                    
                    self.getUserTheme( patientId: userInfo.patientID, clientId: userInfo.clientID,bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, dark : 0) { [self] result in
                        switch result {
                        case .success(let data):
                            // Convert data to JSON object and print it
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                    DispatchQueue.main.async {
                                        print(json)
                                        
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
                    
                    print("Switch is OFF")
                }
            }
            
            cell.cellTitleLabel.text = cellTitleList[indexPath.row]
            return cell
        case .ProfileLanguageTableViewCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: data.rawValue, for: indexPath) as! ProfileLanguageTableViewCell
            let imageUrlString = profileIconList[indexPath.row]
            if let url = URL(string: imageUrlString) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
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
                            
                            
                        }
                    }
                }
                
            }
            print("-4-4-4-4-4--4")
            print(cellTitleList[indexPath.row])
            cell.cellTitleLabel.text = cellTitleList[indexPath.row]
            
            
            return cell
            
        case .LogoutTableViewCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: data.rawValue, for: indexPath) as! LogoutTableViewCell
            let imageUrlString = profileIconList[indexPath.row]
            if let url = URL(string: imageUrlString) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
//                            cell.cellIconView.image = UIImage(data: data)
                            cell.cellIconView.image = UIImage(named: self.profileSvgIcons[indexPath.row])
                        }
                    }
                }
            }
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
        if indexPath.row == 3 {

            let next = UIStoryboard(name: "ProfilePrivacy", bundle: nil)
            guard let viewControllerToPresent = next.instantiateViewController(withIdentifier: "ProfilePrivacyViewController") as? ProfilePrivacyViewController else {
                return
            }

            // Create a dimming view and add it to the window
            if let window = UIApplication.shared.keyWindow {
                let dimmingView = UIView(frame: window.bounds)
                dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                window.addSubview(dimmingView)
                self.dimmingView = dimmingView // Store the reference
            }

            viewControllerToPresent.onScheetClosed = { [weak self] in
                self?.dimmingView?.removeFromSuperview()
            }

            if #available(iOS 15.0, *) {
                if let sheet = viewControllerToPresent.sheetPresentationController {
                    sheet.detents = [.medium(), .large()]
                    sheet.largestUndimmedDetentIdentifier = .medium
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.prefersEdgeAttachedInCompactHeight = true
                    sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                    sheet.delegate = self // To handle delegate methods and adjust dimming view
                }
            } else {
                // Fallback on earlier versions
            }

            present(viewControllerToPresent, animated: true, completion: nil)

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
                    
                    sceneDelegate.changeRootViewController(to: newViewController)
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

