//
//  CreateAccountVC.swift
//  MentalHealth
//
//  on 14/02/24.
//

import UIKit

@available(iOS 16.0, *)
class CreateAccountVC: ViewController,UITextFieldDelegate {

    
    @IBOutlet weak var submitButton: CapsuleButton!
    
    @IBOutlet weak var firstNameTF: customUITextField!
    @IBOutlet weak var firstNameLbl: UILabel!
    
    @IBOutlet weak var lastNameTF: customUITextField!
    
    @IBOutlet weak var lastNameLbl: UILabel!
    @IBOutlet weak var emailTF: customUITextField!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var phoneNumberTF: customUITextField!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var passwordTF: ImagePaddingTextField!
    @IBOutlet weak var passwordLbl: UILabel!
    
    @IBOutlet weak var confirmPasswordTF: ImagePaddingTextField!
    @IBOutlet weak var confirmPasswordLbl: UILabel!
    
    private var customAlertBackgroundView:UIVisualEffectView?
    
    @IBAction func submitAction(_ sender: CapsuleButton) {
        self.view.endEditing(true)
        if validateInputFields(){
            addAlertView(title: "Your profile has been updated successfully.", contentText: "Please click on continue to start using Calmscient.")
        }else{
            addAlertView(title: "Alert", contentText: "Please enter all fields to proceed..")
        }
    }
    

    private func addAlertView(title: String? , contentText: String?) {
        customAlertBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        customAlertBackgroundView?.frame = self.view.frame
        var customAlertView:CustomAlertView? = CustomAlertView(frame: .zero)
        customAlertBackgroundView?.contentView.addSubview(customAlertView!)
        customAlertView?.translatesAutoresizingMaskIntoConstraints = false
        customAlertView?.titleLabel.text = title
        customAlertView?.contentLabel.text = contentText
        customAlertView?.okAction = { [weak self] in
            guard let self = self else {
                return
            }
            UIView.transition(with: self.view, duration: 0.25, options: .transitionCrossDissolve, animations: {
                customAlertView?.removeFromSuperview()
                self.customAlertBackgroundView?.removeFromSuperview()
                customAlertView = nil
                self.customAlertBackgroundView = nil
            }, completion: nil)
            
          //  self.navigateToLogin()
        }
        
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.view.addSubview(self.customAlertBackgroundView!)

            }, completion: nil)
        customAlertView?.layer.cornerRadius = 10
        customAlertView?.layer.masksToBounds = true
        customAlertView?.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        customAlertView?.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        customAlertView?.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.9).isActive = true
        customAlertView?.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.35).isActive = true
    
    }
    
    func navigateToLogin(){
        let next = UIStoryboard(name: "LoginVC", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        submitButton.clipsToBounds = true
//        submitButton.layer.cornerRadius = submitButton.frame.height / 2
        setupLanguage()

        
        
        
        firstNameLbl.font = UIFont(name: Fonts().lexendLight, size: 14.0)
        lastNameLbl.font = UIFont(name: Fonts().lexendLight, size: 14.0)
        emailLbl.font = UIFont(name: Fonts().lexendLight, size: 14.0)
        phoneNumberLbl.font = UIFont(name: Fonts().lexendLight, size: 14.0)
        passwordLbl.font = UIFont(name: Fonts().lexendLight, size: 14.0)
        confirmPasswordLbl.font = UIFont(name: Fonts().lexendLight, size: 14.0)
        
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
        
        let multipleAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "Color") ?? UIColor.white,
            NSAttributedString.Key.font: UIFont(name: Fonts().lexendMedium, size: 18.0) ?? UIFont.systemFont(ofSize: 25.0) ]
        let attrButtonName = NSAttributedString(string: "Continue", attributes: multipleAttributes)
        self.submitButton.titleLabel?.attributedText = attrButtonName
        
        
        
        firstNameTF.delegate = self
        lastNameTF.delegate = self
        phoneNumberTF.delegate = self
        passwordTF.delegate = self
        confirmPasswordTF.delegate = self
        
        addCustomBackbutton()
    }
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        
        firstNameLbl.text = AppHelper.getLocalizeString(str: "First Name")
        firstNameTF.placeholder = AppHelper.getLocalizeString(str: "First Name")
        
        lastNameLbl.text = AppHelper.getLocalizeString(str: "Last Name")
        lastNameTF.placeholder = AppHelper.getLocalizeString(str: "Last Name")
        
        emailLbl.text = AppHelper.getLocalizeString(str: "Email")
        emailTF.placeholder = AppHelper.getLocalizeString(str: "Email")
        
        phoneNumberLbl.text = AppHelper.getLocalizeString(str: "Phone Number")
        phoneNumberTF.placeholder = AppHelper.getLocalizeString(str: "Phone Number")
        
        confirmPasswordLbl.text = AppHelper.getLocalizeString(str: "Confirm Password")
        confirmPasswordTF.placeholder = AppHelper.getLocalizeString(str: "Confirm Password")
        submitButton.setTitle(AppHelper.getLocalizeString(str: "Submit"), for: .normal)
        }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            // Define the characters to allow
            let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
            let characterSet = CharacterSet(charactersIn: string)
            return allowedCharacters.isSuperset(of: characterSet)
        }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLanguage()
        self.navigationController?.isNavigationBarHidden = false
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
    
    func validateInputFields() -> Bool{
        guard let firstNAme = firstNameTF.text, let lastName = lastNameTF.text,  let email = emailTF.text,let phoneNumber = phoneNumberTF.text, let password = passwordTF.text, let confirmPassword = confirmPasswordTF.text else {
            return false
        }
        if !firstNAme.isEmpty && !lastName.isEmpty && !email.isEmpty && !phoneNumber.isEmpty && !password.isEmpty && !confirmPassword.isEmpty{
            return true
        }
        
        return false
        return true
    }
}


