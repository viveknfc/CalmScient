//
//  UserRegistrationViewController.swift
//  HealthApp
//
//

import UIKit

@available(iOS 16.0, *)
class UserRegistrationViewController: UIViewController {

    @IBOutlet weak var licenseTextLabel: UILabel!
    @IBOutlet weak var licenseTextField: customUITextField!
    @IBOutlet weak var submitButton: LinearGradientButton!
    
//    @IBOutlet weak var firstCheck: UIButton!
//    @IBOutlet weak var firstLabel: FontLR15!
//    @IBOutlet weak var secondCheck: UIButton!
//    @IBOutlet weak var secondLabel: FontLR15!
    
    var buttonState1: SelectionButtonState = .dafault
    var buttonState2: SelectionButtonState = .dafault
    var window: UIWindow?

    private var customAlertBackgroundView:UIVisualEffectView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        licenseTextField.layer.borderColor = UIColor(named: "AppBorderColor")?.cgColor
        licenseTextField.layer.borderWidth = 1.0
        licenseTextField.layer.cornerRadius = 4
        licenseTextField.backgroundColor = UIColor(named: "MainViewBackground")
        licenseTextField.font = UIFont(name: Fonts().lexendLight, size: 16.0)
        licenseTextField.textColor = UIColor(named: "MainTextColor")
 
        self.submitButton.setAttributedTitleWithGradientDefaults(title: "Submit")
        self.navigationController?.isNavigationBarHidden = false
        
//        updateButtonImage1()
//        updateButtonImage2()
//        firstLabel.text = "I have read it and understood."
//        secondLabel.text = "I agree to share my info with medical provider"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
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
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func backButtonOverrideAction() {
        print("back button pressed from user regiastration screen")
            self.navigationController?.popViewController(animated: true)
    
        }
    
    //CHeck Box
    
//    @IBAction func firstCheckboxPressed(_ sender: Any) {
//        buttonState1 = (buttonState1 == .dafault) ? .selected : .dafault
//        updateButtonImage1()
//    }
//    
//    private func updateButtonImage1() {
//        firstCheck.setImage(buttonState1.getAssetImageForState(), for: .normal)
//        }
    
    
//    @IBAction func secondCheckboxPressed(_ sender: Any) {
//        buttonState2 = (buttonState2 == .dafault) ? .selected : .dafault
//        updateButtonImage2()
//    }
//    
//    private func updateButtonImage2() {
//        secondCheck.setImage(buttonState2.getAssetImageForState(), for: .normal)
//        }
    
   
    @IBAction func didClickOnSubmitButton(_ sender: UIButton) {
            
            // 1. Check if license key is empty
            guard let license = licenseTextField.text, !license.trimmingCharacters(in: .whitespaces).isEmpty else {
                showGeneralAlert(
                    image: UIImage(named: "InfoIcon"),
                    imageSize: CGSize(width: 40, height: 40),
                    title: "Please enter the license key",
                    okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                    okAction: {},
                    showDismissButton: false
                )
                return
            }
            
            // 2. Check if checkboxes are selected
            if buttonState1 != .selected {
                showGeneralAlert(
                    image: UIImage(named: "InfoIcon"),
                    imageSize: CGSize(width: 40, height: 40),
                    title: "Please confirm that you have read and understood the license",
                    okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                    okAction: {},
                    showDismissButton: false
                )
                return
            }

            if buttonState2 != .selected {
                showGeneralAlert(
                    image: UIImage(named: "InfoIcon"),
                    imageSize: CGSize(width: 40, height: 40),
                    title: "Please agree to share your information with the medical provider",
                    okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                    okAction: {},
                    showDismissButton: false
                )
                return
            }

            // 3. All good — proceed with API call
            let params: [String: String] = ["licenseKey": license]
            print("the license key param is ",license)
            
            self.view.showToastActivity()
            APIService.validateLicenseKeyAPICalling(
                self,
                params: params,
                method: "POST",
                accessToken: "",
                acces: true,
                parameterPlacement: "body"
            ) { response in
                self.getresponseforsubmitAPI(response: response)
            }
        }

    
    //MARK: - Submit API response
    
    func getresponseforsubmitAPI(response: AnyObject) {
        self.view.hideToastActivity()
        
        if let responseString = response as? String {
            print("Response received from validate API calling is", responseString)
            
        } else if let responseDict = response as? [String: Any] {
            print("The validate API response is", responseDict)
            
            if let statusResponse = responseDict["statusResponse"] as? [String: Any],
               let responseCode = statusResponse["responseCode"] as? Int,
               let responseMessage = statusResponse["responseMessage"] as? String {
                
                if responseCode == 200 {
                    self.showSuccessAlert(successContent: responseMessage, centreImage: nil, okButtonAction: {
                        self.navigateToCreateAccount()
                    })
                } else {
                    self.showGeneralAlert(
                        image: UIImage(named: "InfoIcon"),
                        imageSize: CGSize(width: 40, height: 40),
                        title: responseMessage,
                        okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                        okAction: {
                            self.navigateToCreateAccount()
                        },
                        showDismissButton: false
                    )
                }
            } else {
                print("Invalid statusResponse format.")
            }
            
        } else {
            print("Unsupported response type: \(type(of: response))")
        }
    }

    
    //END
    
    func navigateToCreateAccount() {
        let homeController = UIStoryboard(name: "LoginVC", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        let navC = UINavigationController(rootViewController: homeController)
        navC.navigationBar.isHidden = true

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = navC
            window.makeKeyAndVisible()
        }
    }
    

}
