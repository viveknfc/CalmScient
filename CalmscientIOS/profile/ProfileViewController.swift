//
//  ProfileViewController.swift
//  CalmscientIOS
//
//  Created by BVK on 04/07/24.
//

import UIKit

@available(iOS 16.0, *)
class ProfileViewController: ViewController,UIScrollViewDelegate {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var profileScrollView: UIScrollView!
    @IBOutlet weak var lastNameTextfield: UITextField!
    
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var phoneTF: UITextField!
    
    @IBOutlet weak var oldPasswordTF: CustomTextField!
    @IBOutlet weak var newPasswordTF: CustomTextField!
    @IBOutlet weak var confirmPasswordTF: CustomTextField!
    
    
    
    @IBOutlet weak var ContentView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var firstView: UIView!
    
    @IBOutlet weak var newView: UIView!
    
    @IBOutlet weak var lastView: UIView!
    @IBOutlet weak var confirmView: UIView!
    var profileDetails: [[String: Any]] = []
    
    
//    @IBOutlet weak var profileTitle: UILabel!
    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var lastName: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var newPassLabel: UILabel!
    @IBOutlet weak var confirmPassLabel: UILabel!
    @IBOutlet weak var submitButton: LinearGradientButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cornerRadius: CGFloat = 7.0
        let borderColor = UIColor(named: "AppBorderColor")?.cgColor
        
        
        phoneTF.delegate = self
        phoneTF.keyboardType = .numberPad
        phoneTF.isUserInteractionEnabled = false
        emailTF.isUserInteractionEnabled = false
        
        submitButton.setTitle(UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Submit" : "Enviar", for: .normal)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        //self.title = "Profile"
        // Apply the corner radius and border color to each text field
        firstView.setCornerRadiusAndBorder(cornerRadius: cornerRadius, borderColor: borderColor ?? "" as! CGColor)
        lastView.setCornerRadiusAndBorder(cornerRadius: cornerRadius, borderColor: borderColor ?? "" as! CGColor)
        emailView.setCornerRadiusAndBorder(cornerRadius: cornerRadius, borderColor: borderColor ?? "" as! CGColor)
        phoneView.setCornerRadiusAndBorder(cornerRadius: cornerRadius, borderColor: borderColor ?? "" as! CGColor)
        
        profileScrollView.delegate = self

               // Assuming contentView is already constrained inside the scrollView
        profileScrollView.contentSize = CGSize(width: profileScrollView.frame.width, height: ContentView.frame.height)

        profileScrollView.bounces = false
        profileScrollView.alwaysBounceVertical = false
        profileScrollView.alwaysBounceHorizontal = false
        
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
            
        }
        
        self.view.showToastActivity()
        
        getPatientProfileDetails( patientId: userInfo.patientID,bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            self.view.hideToastActivity()
                            
                            if let profileDetails1 = json["patientProfileDetails"] as? [String: Any] {
                                //self.profileDetails = profileDetails1
                                
                                // Update the text fields
                                if let firstName = profileDetails1["firstName"] as? String {
                                    firstNameTextField.text = firstName
                                }
                                if let lastName = profileDetails1["lastName"] as? String {
                                    lastNameTextfield.text = lastName
                                }
                                if let emailAddress = profileDetails1["emailAddress"] as? String {
                                    emailTF.text = emailAddress
                                }
                                if let phone = profileDetails1["phone"] as? String {
                                    print("the Phone number is ", phone)
                                    phoneTF.text = phone
                                }
                            }
                        
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
    
    //MARK: - Update Password Button Pressed
    
    @IBAction func updatePasswordButtonPressed(_ sender: Any) {
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let userID = userInfo.userID
        
        guard let email = emailTF.text, !email.isEmpty else {
            showGeneralAlert(
                title: "Email is required.",
                okButtonTitle: "Ok",
                okAction: {

                },
                showDismissButton: false
            )
            return
        }

        guard let oldPassword = oldPasswordTF.text, !oldPassword.isEmpty else {
            showGeneralAlert(
                title: "Old password is required.",
                okButtonTitle: "Ok",
                okAction: {

                },
                showDismissButton: false
            )
            return
        }

        guard let newPassword = newPasswordTF.text, !newPassword.isEmpty else {
            showGeneralAlert(
                title: "New password is required.",
                okButtonTitle: "Ok",
                okAction: {

                },
                showDismissButton: false
            )
            return
        }

        guard let confirmNewPassword = confirmPasswordTF.text, !confirmNewPassword.isEmpty else {
            showGeneralAlert(
                title: "Confirm password is required.",
                okButtonTitle: "Ok",
                okAction: {

                },
                showDismissButton: false
            )
            return
        }

        guard newPassword == confirmNewPassword else {
            showGeneralAlert(
                title: "New password and confirm password must be the same.",
                okButtonTitle: "Ok",
                okAction: {

                },
                showDismissButton: false
            )
            return
        }

        // Proceed with further processing if all validations pass

        
        let params: [String: Any] = ["emailId": email, "userId": userID, "oldPassword": oldPassword, "newPassword": newPassword, "confirmNewPassword": confirmNewPassword]
        
        self.view.showToastActivity()
        APIService.updatePasswordAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            self.getresponseforUpdatePasswordAPI(response: response)
        }
        
    }
    
    //MARK: - Update Password API Response
    
    func getresponseforUpdatePasswordAPI(response:AnyObject)->() {
        self.view.hideToastActivity()
        print("Response received from update password API calling is", response)
        if let responseString = response as? String {
            print("Response received from update password API calling is", responseString)
        } else if let responseDict = response as? [String: Any] {

                if let responseMessage = responseDict["responseMessage"] as? String {
                    
                    print("Response Message:", responseMessage)
                    self.view.showToast(message: responseMessage)
                    
                       } else {
                           print("Response Message not found or is not a string.")
                       }

        } else {
            print("Unsupported response type:", type(of: response))
        }
    }
    
    
    //MARK: - Phone TF format
    
    func formattedNumber(number: String) -> String
    {
        let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "(XXX) XXX XXXX"
        
        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask where index < cleanPhoneNumber.endIndex {
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }

    
    //end
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            scrollView.contentOffset.x = 0 // Lock horizontal scrolling
        }
    override func viewWillAppear(_ animated: Bool) {
        
//        profileTitle.font = UIFont(name: Fonts().lexendMedium, size: 19)
//        profileTitle.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Profile" : "Perfil"
        
        firstName.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "First Name" : "Nombre"
        firstName.font = UIFont(name: Fonts().lexendRegular, size: 14)
        firstNameTextField.font = UIFont(name: Fonts().lexendRegular, size: 14)
        lastName.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Last Name" : "Apellido"
        lastName.font =  UIFont(name: Fonts().lexendRegular, size: 14)
        lastNameTextfield.font = UIFont(name: Fonts().lexendRegular, size: 14)
        emailLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Email" : "Correo electrónico"
        emailLabel.font =  UIFont(name: Fonts().lexendRegular, size: 14)
        emailTF.font = UIFont(name: Fonts().lexendRegular, size: 14)
        phoneLabel.text =  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Phone" : "Teléfono"
        phoneLabel.font =  UIFont(name: Fonts().lexendRegular, size: 14)
        phoneTF.font = UIFont(name: Fonts().lexendRegular, size: 14)
        
        submitButton.setTitle(UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Submit" : "Enviar", for: .normal)
        
    }
    
    
    @IBAction func submitAction(_ sender: Any) {
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
            
        }
        guard let firstNameText = firstNameTextField.text?.trimmingCharacters(in: .whitespaces), !firstNameText.isEmpty else {
            self.view.showToast(message: "First Name can't be empty.")
            return
        }
        
        guard let lastNameText = lastNameTextfield.text?.trimmingCharacters(in: .whitespaces), !lastNameText.isEmpty else {
            self.view.showToast(message: "Last Name can't be empty.")
            return
        }
        
        guard let emailText = emailTF.text, !emailText.isEmpty else {
            self.view.showToast(message: "Email can't be empty.")
            return
        }
      
        self.view.showToastActivity()
        
        updatePatientProfileDetails( patientId: userInfo.patientID,bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            
                            self.view.hideToastActivity()
                            
                            print(json)
                           
                            self.view.showToast(message: "Profile updated succeffully")
                            self.navigationController?.popViewController(animated: true)
                        
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
    func getPatientProfileDetails(patientId: Int, bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL
        guard let url = URL(string: "\(baseURLString)identity/api/v1/settings/getPatientProfileDetails") else {
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
        ]
        print(payload)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            //    print(jsonData)
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
                // print("Response JSON: \(jsonResponse)")
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
    
    func updatePatientProfileDetails(patientId: Int, bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL
        guard let url = URL(string: "\(baseURLString)identity/api/v1/settings/updatePatientProfileDetails") else {
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
            "firstName": firstNameTextField.text ?? "",
            "lastName": lastNameTextfield.text ?? "",
            "email": emailTF.text ?? "",
            "phone": phoneTF.text ?? ""
        ]
        
        
        
        print(payload)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: .prettyPrinted)
            request.httpBody = jsonData
            //    print(jsonData)
        } catch {
            print("Error converting payload to JSON: \(error)")
            completion(.failure(error))
            return
        }
        
        // Create the URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with request: \(error)")
                DispatchQueue.main.async { [self] in
                    
                    self.view.hideToastActivity()
                    
                
            }
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
                // print("Response JSON: \(jsonResponse)")
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

}

@available(iOS 16.0, *)
extension ProfileViewController: UITextFieldDelegate {
  
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        
        if textField == phoneTF
        {
            guard let text = textField.text else { return false }
            let newString = (text as NSString).replacingCharacters(in: range, with: string)
            textField.text = formattedNumber(number: newString)
            return false
        }
        return true
    }
}

extension UIView {
    func setCornerRadiusAndBorder(cornerRadius: CGFloat, borderColor: CGColor, borderWidth: CGFloat = 1.0) {
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = borderColor
        self.layer.borderWidth = borderWidth
        self.layer.masksToBounds = true
    }
}
