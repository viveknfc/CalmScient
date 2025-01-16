//
//  ForgotPasswordVC.swift
//  HealthApp
//
//  Created by KA on 02/03/24.
//

import UIKit

class ForgotPasswordVC: ViewController {
    
    @IBOutlet weak var forgotPasswordNameLbl: UILabel!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var emailOrNumberTF: customUITextField!
    @IBOutlet weak var emailPhoneNumberLbl: UILabel!
    @IBOutlet weak var resetPasswordButton: CapsuleButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = false
        
        addCustomBackbutton()
        forgotPasswordNameLbl.font = UIFont(name:Fonts().lexendMedium, size: 20.0)
        descriptionLbl.font = UIFont(name:Fonts().lexendLight, size: 16.0)
        emailPhoneNumberLbl.font = UIFont(name:Fonts().lexendLight, size: 14.0)
        
        let multipleAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "Color") ?? UIColor.white,
            NSAttributedString.Key.font: UIFont(name: Fonts().lexendMedium, size: 18.0) ?? UIFont.systemFont(ofSize: 25.0) ]
        let attrButtonName = NSAttributedString(string: "Reset Password", attributes: multipleAttributes)
        self.resetPasswordButton.titleLabel?.attributedText = attrButtonName
        
    }
    
    func addCustomBackbutton(){
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        backButton.setImage(UIImage(named: "BackArrow.png"), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc func backAction () {
        // do the magic
        self.navigationController?.popViewController(animated: true)
        // self.navigationController?.isNavigationBarHidden = true
        
    }
    func generateOTP(emailId: String, completion: @escaping (Result<Data, Error>) -> Void){
        // Define the URL
        guard let url = URL(string: "\(baseURLString)identity/api/v1/settings/generateOTP") else {
            print("Invalid URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //  request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        
        // Define the JSON payload
        let payload: [String: Any] = [
            
            "emailId": emailOrNumberTF.text as Any
        ]
        
        
        print("payload\(payload)")
        // Convert the payload to JSON data
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
    @IBAction func resetPasswordAction(_ sender: Any) {
        if emailOrNumberTF.text == "" {
            self.view.showToast(message: "Please add email address")
        }
        else {
            self.view.showToastActivity()
            
            generateOTP( emailId: (emailOrNumberTF.text ?? "") as String) { [self] result in
                switch result {
                case .success(let data):
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            DispatchQueue.main.async { [self] in
                                print(json)
                                
                                self.view.hideToastActivity()
                                self.view.endEditing(true)
                                let next = UIStoryboard(name: "CheckMailVC", bundle: nil)
                                let vc = next.instantiateViewController(withIdentifier: "CheckMailVC") as? CheckMailVC
                                vc?.emailString = emailOrNumberTF.text ?? ""
                                self.navigationController?.pushViewController(vc!, animated: true)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
    }
    
    func setupLanguage() {
        
        let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        
        if languageId == 1 {
            UserDefaults.standard.set("en", forKey: "Language")
            
        } else if languageId == 2 {
            UserDefaults.standard.set("es", forKey: "Language")
            
        }
        
        forgotPasswordNameLbl.text = AppHelper.getLocalizeString(str: "Forgot password")
        descriptionLbl.text = AppHelper.getLocalizeString(str: "Please enter your email to reset the password")
        emailPhoneNumberLbl.text = AppHelper.getLocalizeString(str: "Your email/Phone number ")
        
        
    }
    
}
