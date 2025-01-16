//
//  CheckMailVC.swift
//  HealthApp
//
//  Created by KA on 02/03/24.
//

import UIKit

class CheckMailVC: ViewController {
    
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var checkMailLbl: UILabel!
    
    //    @IBOutlet weak var codeTF1: UITextField!
    //    @IBOutlet weak var codeTF2: UITextField!
    //    @IBOutlet weak var codeTF3: UITextField!
    //    @IBOutlet weak var codeTF4: UITextField!
    
    @IBOutlet var digitFields: [UITextField]!
    
    @IBOutlet weak var verifyCodeButton: CapsuleButton!
    @IBOutlet weak var resendMailLbl: UILabel!
    let emailID = "xxxxxxxxxx@gmail.com"
    let resendmailText = "Resend email"
    var concatenatedString = ""
    var emailString = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        print("emailString===\(emailString)")
        digitFields.forEach {
            configureDigitField($0)
        }
    }
    
    
    func addCustomBackbutton(){
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        backButton.setImage(UIImage(named: "BackArrow.png"), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    func addAttributeText(){
        guard let text = resendMailLbl.text, text.count > 0 else { return }
        let resendmailTextRange = (text as NSString).range(of: resendmailText)
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.addAttribute(.underlineStyle,
                                    value: NSUnderlineStyle.single.rawValue,
                                    range: resendmailTextRange)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "AppThemeColor"), range: resendmailTextRange)
        attributedText.addAttributes([.font: (UIFont(name: Fonts().lexendLight, size: 16.0))], range: NSRange(0..<text.count))
        // Add other attributes if needed
        self.resendMailLbl.attributedText = attributedText
        
        
        self.resendMailLbl.isUserInteractionEnabled = true
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnresendMailLabel(_ :)))
        tapgesture.numberOfTapsRequired = 1
        self.resendMailLbl.addGestureRecognizer(tapgesture)
        
        
        guard let text = instructionLbl.text, text.count > 0 else { return }
        let emailIDRange = (text as NSString).range(of: emailID)
        let emailattributedText = NSMutableAttributedString(string: text)
        emailattributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "AppThemeColor"), range: emailIDRange)
        emailattributedText.addAttributes([.font: (UIFont(name: Fonts().lexendLight, size: 16.0))], range: NSRange(0..<text.count))
        // Add other attributes if needed
        self.instructionLbl.attributedText = emailattributedText
    }
    
    //MARK:- tappedOnLabel
    @objc func tappedOnresendMailLabel(_ gesture: UITapGestureRecognizer) {
        guard let text = self.resendMailLbl.text else { return }
        let emailidRange = (text as NSString).range(of: emailID)
        if gesture.didTapAttributedTextInLabel(label: self.resendMailLbl, inRange: emailidRange) {
            print("user tapped on email text")
        }
    }
    
    @objc func backAction () {
        // do the magic
        self.navigationController?.popViewController(animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //codeTF1.becomeFirstResponder()
        addCustomBackbutton()
        addAttributeText()
        checkMailLbl.font = UIFont(name:Fonts().lexendMedium, size: 20.0)
        let multipleAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "Color") ?? UIColor.white,
            NSAttributedString.Key.font: UIFont(name: Fonts().lexendMedium, size: 18.0) ?? UIFont.systemFont(ofSize: 25.0) ]
        let attrButtonName = NSAttributedString(string: "Verify Code", attributes: multipleAttributes)
        self.verifyCodeButton.titleLabel?.attributedText = attrButtonName
        
        digitFields[0].becomeFirstResponder()
        setupLanguage()
    }
    func validateOTP(otp: String, completion: @escaping (Result<Data, Error>) -> Void){
        // Define the URL
        guard let url = URL(string: "\(baseURLString)identity/api/v1/settings/validateOTP") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        //  request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        // Define the JSON payload
        let payload: [String: Any] = [
            "emailId": emailString,
            "otp": otp
            
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
    fileprivate func configureDigitField(_ digitField: UITextField) {
        digitField.delegate = (self as UITextFieldDelegate)
        digitField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    
    func printDigitFieldsAsString() {
        
        for textField in digitFields {
            if let text = textField.text {
                concatenatedString += text
            }
        }
        print("Concatenated String: \(concatenatedString)")
    }
    @objc fileprivate func textFieldDidChange(textField: UITextField) {
        if textField.text?.count == 1 {
            let remaining = digitFields.filter { $0.text?.count == 0 }
            if remaining.count > 0 {
                remaining[0].becomeFirstResponder()
            } else {
                digitFields.forEach { $0.resignFirstResponder() }
            }
        }
    }
    
    func setupLanguage() {
        
        let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        
        if languageId == 1 {
            UserDefaults.standard.set("en", forKey: "Language")
            
        } else if languageId == 2 {
            UserDefaults.standard.set("es", forKey: "Language")
            
        }
        
        checkMailLbl.text = AppHelper.getLocalizeString(str: "Check your email")
        instructionLbl.text = AppHelper.getLocalizeString(str: "Enter the 4-digit code that we have sent via email xxxxxxxxxx@gmail.com")
        
    }
    @IBAction func verifyCodeAction(_ sender: UIButton) {
        if digitFields.isEmpty {
            self.view.showToast(message: "Please fill OTP Fields")
        }
        else {
            printDigitFieldsAsString()
            self.view.showToastActivity()
            validateOTP( otp: concatenatedString as String) { [self] result in
                switch result {
                case .success(let data):
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            DispatchQueue.main.async { [self] in
                                self.view.hideToastActivity()
                                let responseCode = json["responseCode"] as! Int
                                if responseCode == 400 {
                                    //self.view.showToast(message: json["responseMessage"] as! String)
                                    let alertController = UIAlertController(title: "Alert", message: json["responseMessage"] as? String, preferredStyle: .alert)
                                    
                                    let yesAction = UIAlertAction(title: "OK", style: .default) { _ in
                                       
                                        alertController.dismiss(animated: true)
                                    }
                                    
                                    alertController.addAction(yesAction)
                                
                                    present(alertController, animated: true, completion: nil)
                                }
                                else {
                                    
                                    
                                    self.view.hideToastActivity()
                                    self.view.endEditing(true)
                                    let next = UIStoryboard(name: "UpdatePasswordVC", bundle: nil)
                                    let vc = next.instantiateViewController(withIdentifier: "UpdatePasswordVC") as? UpdatePasswordVC
                                    vc?.updateEmailString = emailString
                                    self.navigationController?.pushViewController(vc!, animated: true)
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
    }
    
}

extension CheckMailVC: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get the current text, or use an empty string if that failed
        let currentText = textField.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        // make sure the result is under 16 characters
        return updatedText.count <= 1
    }
    
}
