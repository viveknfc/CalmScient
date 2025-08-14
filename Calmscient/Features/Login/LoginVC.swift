//
//  LoginVC.swift
//  MentalHealth
//
//  on 19/02/24.
//

import UIKit
import Toast_Swift

@available(iOS 16.0, *)
class LoginVC: UIViewController,UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userNameTextField: ImagePaddingTextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordTextField: ImagePaddingTextField!
    
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    @IBOutlet weak var selectionButton: SelectionButton!
    @IBOutlet weak var loginButton: LinearGradientButton!
    
    @IBOutlet weak var validateLicenseKeyLabel: UILabel!
    var languageId : Int?
    var isFirstLaunch: Bool?
    
    var navController: UINavigationController?
    let dateFormatter = DateFormatter()
    var formattedDate: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstLaunch")
        
        setupLanguage()
       
//       userNameTextField.text = "masa@calmscient.com"
//       passwordTextField.text = "CDMrVgjdM5"
        
//       userNameTextField.text = "john.doe@example.com"
//       passwordTextField.text = "Test@345"
        
//       userNameTextField.text = "charus@nfcsolutionsusa.com"
//       passwordTextField.text = "Charu@123"
        
//          userNameTextField.text = "kajalkubde28@gmail.com"
//          passwordTextField.text = "Test@123"
        
//          userNameTextField.text = "simhachalamb@nfcsolutionsusa.com"
//          passwordTextField.text = "Simha@1234"
        
//        userNameTextField.text = "vivekl@nfcsolutionsusa.com"
//        passwordTextField.text = "Test@1234"
        
        userNameTextField.delegate = self
        userNameTextField.layer.borderColor = UIColor(named: "AppBorderColor")?.cgColor
        userNameTextField.layer.borderWidth = 1.0
        userNameTextField.layer.cornerRadius = 4
        userNameTextField.layer.masksToBounds = true
        userNameTextField.backgroundColor = UIColor(named: "MainViewBackground")
        userNameTextField.font = UIFont(name: Fonts().lexendLight, size: 16.0)
        userNameTextField.textColor = UIColor(named: "MainTextColor")
        
        passwordTextField.delegate = self
        passwordTextField.layer.borderColor = UIColor(named: "AppBorderColor")?.cgColor
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.layer.cornerRadius = 4
        passwordTextField.layer.masksToBounds = true
        passwordTextField.backgroundColor = UIColor(named: "MainViewBackground")
        passwordTextField.font = UIFont(name: Fonts().lexendLight, size: 16.0)
        passwordTextField.textColor = UIColor(named: "MainTextColor")
 
        self.forgotPasswordLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(forgotPasswordGesture(tapGestureRecognizer:)))
        tapGesture.numberOfTapsRequired = 1
        self.forgotPasswordLabel.addGestureRecognizer(tapGesture)
        
        self.validateLicenseKeyLabel.isHidden = false
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(validateLicenseGesture(tapGestureRecognizer:)))
        tapGesture2.numberOfTapsRequired = 1
        self.validateLicenseKeyLabel.addGestureRecognizer(tapGesture2)
        
        languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        let termsAndConditions = (languageId == 0 ? 1 : languageId  ) == 1 ? "Accept Terms and Conditions" : "Aceptar Términos y Condiciones"
        let termsAndConditionsAttributedText = NSMutableAttributedString(string: termsAndConditions, attributes: [.font: UIFont(name: Fonts().lexendLight, size: 14.0)!, .foregroundColor:UIColor(named: "MainTextColor") ?? UIColor.white])
        
        let linkText = (languageId == 1) ? "Terms and Conditions" : "Términos y Condiciones"
        if let range = Range((termsAndConditions as NSString).range(of: linkText), in: termsAndConditions) {
            termsAndConditionsAttributedText.addAttributes([
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: UIColor(named: "MainTextColor") ?? UIColor.white,
                .link: URL(string: "http://147.93.41.160/courses/terms-of-service")! // Replace with your actual URL
            ], range: NSRange(range, in: termsAndConditions))
        }
        
        termsAndConditionsAttributedText.addAttributes([.underlineStyle : NSUnderlineStyle.single.rawValue, .underlineColor:UIColor(named: "MainTextColor") ?? UIColor.white], range: (termsAndConditions as NSString).range(of: "terms and conditions"))
//        selectionButton.contentLabel.attributedText = termsAndConditionsAttributedText
        selectionButton.textView.attributedText = termsAndConditionsAttributedText
        
        selectionButton.textView.isUserInteractionEnabled = true
        selectionButton.textView.isEditable = false
        selectionButton.textView.isSelectable = true
        selectionButton.textView.dataDetectorTypes = .link
        selectionButton.textView.delegate = self
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture1.cancelsTouchesInView = false // Allow table view cell selection
        view.addGestureRecognizer(tapGesture1)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(saveUsername),
            name: UIApplication.willResignActiveNotification,
            object: nil)

        NotificationCenter.default.addObserver(self,
            selector: #selector(restoreUsername),
            name: UIApplication.didBecomeActiveNotification,
            object: nil)
        
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func saveUsername() {
        UserDefaults.standard.set(userNameTextField.text, forKey: "temp_username")
        UserDefaults.standard.set(passwordTextField.text, forKey: "temp_password")
    }

    @objc func restoreUsername() {
        if let saved = UserDefaults.standard.string(forKey: "temp_username") {
            userNameTextField.text = saved
        }
        if let savedPassword = UserDefaults.standard.string(forKey: "temp_password") {
            passwordTextField.text = savedPassword
        }

    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.absoluteString == "https://calmscient.com/privacy-policy/" {
            // Open the URL
            UIApplication.shared.open(URL)
            return false // Return false to prevent default handling
        }
        return true
    }

    
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        
        
        
        
        let attributedText = NSMutableAttributedString(string: (languageId == 0 ? 1 : languageId  ) == 1 ?  "Forgot password?" : "¿Olvidaste la contrasňa?", attributes: [.font: UIFont(name: Fonts().lexendLight, size: 14.0)!, .foregroundColor:UIColor(named: "MainTextColor") ?? UIColor.white, .underlineStyle : NSUnderlineStyle.single.rawValue, .underlineColor:UIColor(named: "MainTextColor") ?? UIColor.white])
        forgotPasswordLabel.attributedText = attributedText
        
       
        let validateLicenseAttributedText = NSMutableAttributedString(string:  (languageId == 0 ? 1 : languageId  ) == 1 ?  "Validate your license key" : "Valida tu clave de licencia", attributes: [.font: UIFont(name: Fonts().lexendLight, size: 14.0)!, .foregroundColor:UIColor(named: "MainTextColor") ?? UIColor.white, .underlineStyle : NSUnderlineStyle.single.rawValue, .underlineColor:UIColor(named: "MainTextColor") ?? UIColor.white])
        validateLicenseKeyLabel.attributedText = validateLicenseAttributedText
        
        
        self.loginButton.setAttributedTitleWithGradientDefaults(title: (languageId == 0 ? 1 : languageId  ) == 1 ?  "Login" : "Login")
        selectionButton.contentLabel.text = (languageId == 0 ? 1 : languageId  ) == 1 ? "Accept Terms & Conditions" : "Aceptar Términos y Condiciones"
        userNameLabel.text = AppHelper.getLocalizeString(str: "Username")
        passwordLabel.text = AppHelper.getLocalizeString(str: "Password")

//        forgotPasswordLabel.text = (languageId == 0 ? 1 : languageId  ) == 1 ?  "Forgot password?" : "¿Has olvidado tu contraseña?"
        
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Disallow spaces
            return string.rangeOfCharacter(from: .whitespaces) == nil
        }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    
    @objc func forgotPasswordGesture(tapGestureRecognizer: UITapGestureRecognizer)
    {
        print("forgot passwrod clicked")
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let next = UIStoryboard(name: "ForgotPasswordVC", bundle: nil)
        guard let vc = next.instantiateViewController(withIdentifier: "ForgotPasswordVC") as? ForgotPasswordVC else {
            print("❌ Failed to instantiate ForgotPasswordVC")
            return
        }

        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func validateLicenseGesture(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let storyboard = UIStoryboard(name: "UserRegistration", bundle: nil)
        let registrationViewController = storyboard.instantiateViewController(withIdentifier: "UserRegistrationViewController") as! UserRegistrationViewController

        registrationViewController.navigationItem.title = ""
        self.navController = UINavigationController(rootViewController: registrationViewController)
        
        UserDefaults.standard.set(true, forKey: "isFirstLaunch")
        
        if let navigationController = self.navigationController {
            navigationController.pushViewController(registrationViewController, animated: true)
        } else {
            print("Navigation Controller not available")
        }
        
//        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
//            sceneDelegate.changeRootViewController(to: self.navController!)
//        }
    }
    
    @IBAction func didClickOnLoginButton(_ sender: UIButton) {
        
        UserDefaults.standard.removeObject(forKey: "temp_username")
        UserDefaults.standard.removeObject(forKey: "temp_password")
        
        guard let userNameText = userNameTextField.text?.trimmingCharacters(in: .whitespaces), !userNameText.isEmpty else {
            self.view.showToast(message: "Username or Password can't be empty.")
            return
        }
        
        guard let passwordText = passwordTextField.text, !passwordText.isEmpty else {
            self.view.showToast(message: "Password can't be empty.")
            return
        }
        
        if userNameText.contains(" ") || passwordText.contains(" ") {
               let alert = UIAlertController(title: "Error", message: "Username and Password should not contain spaces.", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               self.present(alert, animated: true)
               return
           }
        
        guard selectionButton.isSelected else {
            self.view.showToast(message: "Accept Terms and Conditions")
            return
        }
        
        self.view.showToastActivity()
        self.createLoginRequest(userName: userNameText, password: passwordText)
        
    }
    
    fileprivate func createLoginRequest(userName:String,password:String) {
 
        let url = URL(string: "\(baseURLString)identity/api/v1/settings/userLogin")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "userName": userName,
            "password": password
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("Error: Unable to serialize parameters")
            return
        }
        
        let startTime = Date()
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                
                let endTime = Date()
                let responseTIme = endTime.timeIntervalSince(startTime)
                print("the response TIme taking for login VC is: \(responseTIme) seconds")
            
            guard let self = self else {
                return
            }
            if let _ = error {
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.view.showToast(message: error?.localizedDescription ?? "An unknown error occured. Please Try Again!")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                    self.view.showToast(message: error?.localizedDescription ?? "An unknown error occured. Please Try Again!")
                }
                return
            }
            NetworkLogger.log(response: data)
            do {
                if let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                    
                    DispatchQueue.main.async {
                        if loginResponse.statusResponse.responseCode != 200 {
                            self.view.hideToastActivity()
                            self.view.showToast(message: loginResponse.statusResponse.responseMessage)
                        } else {

                            ApplicationSharedInfo.shared.loginResponse = loginResponse.loginDetails
                            ApplicationSharedInfo.shared.tokenResponse = loginResponse.tokenResponse

                            if self.selectionButton.isRememberMeSelected {
                                UserDefaults.standard.set(1, forKey: "rememberMe")
                            } else {
                                UserDefaults.standard.set(0, forKey: "rememberMe")
                            }
                            
                            //For checking access token expiry
                            TokenManager.shared.saveTokenData(accessToken: loginResponse.tokenResponse.accessToken, expiresIn: loginResponse.tokenResponse.expiresIn)
                            
                            UserDefaultsHelper.saveLoginDetailsToUserDefaults(loginDetails: loginResponse.loginDetails, tokenResponse: loginResponse.tokenResponse)
                            
                            UserDefaults.standard.set("\(loginResponse.loginDetails.firstName)", forKey: "titleString")
                            UserDefaults.standard.set("\(loginResponse.loginDetails.languageId)", forKey: "SelectedLanguageID")
                            
                            self.languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
                            print("the language id after login is getting as ", self.languageId as Any)
                            
                            if self.languageId == 1 {
                                UserDefaults.standard.set("en", forKey: "appLanguage")
                                Bundle.setLanguage("en")
                            }
                            if self.languageId == 2 {
                                UserDefaults.standard.set("es", forKey: "appLanguage")
                                Bundle.setLanguage("es")
                                
                            }
                            
                            let loginCount = loginResponse.loginDetails.loginCount
                            
                            if loginCount == 1 {
                                let storyboard = UIStoryboard(name: "UpdatePasswordVC", bundle: nil)
                                if let vc = storyboard.instantiateViewController(withIdentifier: "UpdatePasswordVC") as? UpdatePasswordVC {
                                    vc.updateEmailString = loginResponse.loginDetails.email
                                    let nav = UINavigationController(rootViewController: vc)
                                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                        sceneDelegate.changeRootViewController(to: nav)
                                    }
                                }
                            } else {
                                self.userStartUpAPICall ()
                            }
   


                        }
                    }
                } else {
                    
                    print("decoding is failing")
 
                    if let failureResponse = try? JSONDecoder().decode(FailureResponse.self, from: data) {
                        DispatchQueue.main.async {
                            self.view.hideToastActivity()
                            self.view.showToast(message: failureResponse.statusResponse.responseMessage)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.view.hideToastActivity()
                            self.view.showToast(message: "Please Try Again!")
                        }
                    }
                    
                }
            }
        }
        task.resume()
    }
    
    //MARK: - User Start up API Call
    
    func userStartUpAPICall () {
        
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            return
        }
        let plId = loginResponse.patientLocationID
        let patientId = loginResponse.patientID
        let clientId = loginResponse.clientID
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Specify the desired format
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        
        let params: [String: Any] = ["patientLocationId": plId, "clientId": clientId, "patientId": patientId, "time": formattedDate]
        
        print("params for the user startup api is", params)

        APIService.userStartUpAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            self.getresponseforUserStartUpAPI(response: response)
        }
        
    }
    
    //MARK: - User Start Up API Response
    
    func getresponseforUserStartUpAPI(response:AnyObject)->() {
        
        DispatchQueue.main.async {
            self.view.hideToastActivity()
        }
       
        if let responseString = response as? String {
            print("Response received from User Startup API calling is", responseString)
            
            // Show alert with retry button
                   let alertController = UIAlertController(title: "Error",
                                                           message: "Failed to fetch data. Would you like to retry?",
                                                           preferredStyle: .alert)
                   
                   alertController.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                       // Call the API again or reload the view
                       self.loginButton.sendActions(for: .touchUpInside)
                   }))
                   
                   alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                   
                   self.present(alertController, animated: true)
            
        } else if let responseDict = response as? [String: Any] {
            
            print("the response from user startup api is", responseDict)

                if let responseMessage = responseDict["saved"] as? Int {
                    
                    if responseMessage != 1 {
                        
                        print("entering mood screen from startup api true")
                        
                        let storyboard = UIStoryboard(name: "UserIntro", bundle: nil)
                            let homeViewController = storyboard.instantiateViewController(withIdentifier: "UserIntroDayFeedbackViewController") as! UserIntroDayFeedbackViewController
                        homeViewController.afternoonVC = true
                        if let titleString = UserDefaults.standard.string(forKey: "titleString") {
                            homeViewController.titleString = titleString
                        }

                            // Wrap the home view controller in a navigation controller if needed
                        self.navController = UINavigationController(rootViewController: homeViewController)
                        
                    } else {

                            print("Time zone remains the same.")
                            let storyboard = UIStoryboard(name: "AppTabBar", bundle: nil)
                                let homeViewController = storyboard.instantiateViewController(withIdentifier: "AppMainTabViewController") as! AppMainTabViewController
                            homeViewController.isInitalView = false
                            self.navController = UINavigationController(rootViewController: homeViewController)
                            self.navController?.navigationBar.isHidden = true
                        
                    }
                    
                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                        sceneDelegate.changeRootViewController(to: self.navController!)
                    }

               } else {
                   print("Response Message not found or is not a string.")
               }

        } else {
            print("Unsupported response type:", type(of: response))
        }
    }

    
    fileprivate func showUnKnownErrorMessage() {
        
    }
    
}

extension UIView {
    public func updateToastStyleWithAppDefaults() {
        var toastStyle = ToastManager.shared.style
        toastStyle.backgroundColor = UIColor(named: "toastBackgroundColor")!
        toastStyle.titleColor = .white
        toastStyle.messageColor = .white
        toastStyle.messageAlignment = .center
        toastStyle.messageNumberOfLines = 0
        toastStyle.messageFont = UIFont(name: Fonts().lexendLight, size: 14) ?? .systemFont(ofSize: 14)
        toastStyle.titleFont = UIFont(name: Fonts().lexendLight, size: 16) ?? .systemFont(ofSize: 16)
        toastStyle.titleAlignment = .center
        toastStyle.activityBackgroundColor = UIColor(named: "toastBackgroundColor")!
        toastStyle.activityIndicatorColor = .white
        ToastManager.shared.style = toastStyle
    }
    
    public func showToast(message: String, title: String? = nil, point: CGPoint? = nil) {
        DispatchQueue.main.async {
            self.hideAllToasts(includeActivity: true)
            self.updateToastStyleWithAppDefaults()
            
            let window = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
            
            let safeAreaBottom = window?.safeAreaInsets.bottom ?? 0
            let tabBarHeight = self.findViewController()?.tabBarController?.tabBar.frame.height ?? 49
            let bottomPadding: CGFloat = 16
            let adjustedY = self.frame.height - (tabBarHeight + safeAreaBottom + bottomPadding)
            let defaultPoint = CGPoint(x: self.frame.width / 2, y: adjustedY)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.makeToast(message, duration: 2, point: point ?? defaultPoint, title: title, image: nil) { _ in
                    self.hideToastActivity()
                }
            }
        }
    }
    
    public func showToastActivity() {
        self.isUserInteractionEnabled = false
//        self.hideAllToasts(includeActivity: true)
        self.updateToastStyleWithAppDefaults()
        self.makeToastActivity(.center)
    }
    
    public func hideToastActivity() {
        print("hideToastActivity() called")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isUserInteractionEnabled = true
            self.hideAllToasts(includeActivity: true)
        }
    }

  
}


