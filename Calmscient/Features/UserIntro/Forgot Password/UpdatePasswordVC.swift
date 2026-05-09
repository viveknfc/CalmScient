//
//  UpdatePasswordVC.swift
//  HealthApp
//
//  Created by KA on 02/03/24.
//

import UIKit

class UpdatePasswordVC: UIViewController,UITextFieldDelegate {
    @IBOutlet var updateView: UIView!
    
    @IBOutlet weak var updateImage: UIImageView!
    
    @IBOutlet weak var setNewPasswordLbl: UILabel!
    @IBOutlet weak var passwordTF: ImagePaddingTextField!
    @IBOutlet weak var createPasswordDescriptionLbl: UILabel!
    @IBOutlet weak var confirmPasswordTF: ImagePaddingTextField!
    @IBOutlet weak var passwordLbl: UILabel!
    
    @IBOutlet weak var confirmPasswordLbl: UILabel!
    @IBOutlet weak var showPasswordBtn: UIButton!
    @IBOutlet weak var showConfirmPasswordBtn: UIButton!
    
    @IBOutlet weak var updatePasswordButton: LinearGradientButton!
    private var customAlertBackgroundView:UIVisualEffectView?
    var updateEmailString = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTF.layer.cornerRadius = 5.0
        passwordTF.layer.borderWidth = 1.0
        passwordTF.layer.borderColor = UIColor(red: 110.0/255.0, green: 107.0/255.0, blue: 179.0/255.0, alpha: 1.0).cgColor
        passwordTF.layer.masksToBounds = true
        passwordTF.clipsToBounds = true
        passwordTF.textColor = UIColor(named: "MainTextColor")
        passwordTF.font = UIFont(name: Fonts().lexendLight, size: 16.0)
        
        confirmPasswordTF.layer.cornerRadius = 5.0
        confirmPasswordTF.layer.borderWidth = 1.0
        confirmPasswordTF.layer.borderColor = UIColor(red: 110.0/255.0, green: 107.0/255.0, blue: 179.0/255.0, alpha: 1.0).cgColor
        confirmPasswordTF.layer.masksToBounds = true
        confirmPasswordTF.clipsToBounds = true
        confirmPasswordTF.textColor = UIColor(named: "MainTextColor")
        confirmPasswordTF.font = UIFont(name: Fonts().lexendLight, size: 16.0)
        
        
        
        updateImage.layer.cornerRadius = 5.0
        updateImage.layer.borderWidth = 1.0
        updateImage.layer.borderColor = UIColor.white.cgColor
        updateImage.layer.masksToBounds = true
        updateImage.clipsToBounds = true
        
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(updateView)
            
            // Add constraints
            NSLayoutConstraint.activate([
                updateView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                updateView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                updateView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                updateView.heightAnchor.constraint(equalToConstant: window.bounds.height)
            ])
        }
        updateView.isHidden = true
        passwordTF.delegate = self
        confirmPasswordTF.delegate = self
        
//        self.title = "Update password"
        self.navigationItem.hidesBackButton = true
    }
    func updateForgetPassword(emailId: String,newPassword: String,confirmPasword: String, completion: @escaping (Result<Data, Error>) -> Void){
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
        
        // Define the URL
        let validURL = APIService.BaseUrl + "identity/api/v1/settings/forgetPassword" //"https://calmscient.in/api/identity/api/v1/settings/forgetPassword"
        guard let url = URL(string: validURL) else {
            print("Invalid URL")
            return
        }
   
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload: [String: Any] = [
            
               "emailId": emailId,
               "password": newPassword,
               "confirmPassword": confirmPasword
        ]
        
        print("payload\(payload)")
        
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
                print("Response JSON: \(jsonResponse)")
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
    func setupLanguage() {
        
}
    override func viewWillAppear(_ animated: Bool) {
        addCustomBackbutton()
        setNewPasswordLbl.font = UIFont(name:Fonts().lexendMedium, size: 20.0)
        createPasswordDescriptionLbl.font = UIFont(name:Fonts().lexendLight, size: 16.0)
        passwordLbl.font = UIFont(name:Fonts().lexendLight, size: 14.0)
        confirmPasswordLbl.font = UIFont(name:Fonts().lexendLight, size: 14.0)
        let multipleAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "Color") ?? UIColor.white,
            NSAttributedString.Key.font: UIFont(name: Fonts().lexendMedium, size: 18.0) ?? UIFont.systemFont(ofSize: 25.0) ]
        let attrButtonName = NSAttributedString(string: "Update password", attributes: multipleAttributes)
        self.updatePasswordButton.titleLabel?.attributedText = attrButtonName
        setupLanguage()
    }
    func addCustomBackbutton(){
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        backButton.setImage(UIImage(named: "BackArrow.png"), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @available(iOS 16.0, *)
    @IBAction func updateButtonAction(_ sender: Any) {
        updateView.removeFromSuperview()
        updateView.isHidden = true
        let next = UIStoryboard(name: "LoginVC", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
        self.navigationController?.pushViewController(vc!, animated: true)

    }
    @objc func backAction () {
            // do the magic
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func showPasswordBtnAction(_ sender: Any) {
        
    }
    @IBAction func showConfirmPasswordBtnAction(_ sender: Any) {
        
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            return string.rangeOfCharacter(from: .whitespaces) == nil
        }
    @IBAction func updatePasswordBtnAction(_ sender: Any) {
        
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?\":{}|<>])[A-Za-z\\d!@#$%^&*(),.?\":{}|<>]{8,}$"
        
        guard let newPassword = passwordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              let confirmPassword = confirmPasswordTF.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: "Unexpected error: password fields missing.",
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {},
                showDismissButton: false
            )
            return
        }
        
        if newPassword.isEmpty || confirmPassword.isEmpty {
            showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: "Please fill in both new password and confirm password.",
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {},
                showDismissButton: false
            )
            return
        }

        guard NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: newPassword) else {
            showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: "Your password must be at least eight characters long and include at least one special character and one number.",
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {},
                showDismissButton: false
            )
            return
        }
        
        guard newPassword == confirmPassword else {
            showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: "New password and confirm password should match.",
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {},
                showDismissButton: false
            )
            return
        }
        
        self.view.showToastActivity()
        
        updateForgetPassword(emailId: updateEmailString, newPassword: newPassword, confirmPasword: confirmPassword) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            print(json)
                            self.showSuccessAlert(successContent: "Password updated successfully", centreImage: nil, okButtonAction: {
                                if #available(iOS 16.0, *) {
                                    let homeController = UIStoryboard(name: "LoginVC", bundle: nil).instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                                    let navC = UINavigationController(rootViewController: homeController)
                                    navC.navigationBar.isHidden = true
                                    
                                    if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
                                       let window = sceneDelegate.window {
                                        window.rootViewController = navC
                                        window.makeKeyAndVisible()
                                    }
                                } else {
                                    print("Login movement stopped here")
                                }
                            })
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

}
