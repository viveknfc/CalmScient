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
    @IBOutlet weak var userLicenseTextView: UITextView!
    @IBOutlet weak var submitButton: LinearGradientButton!
    @IBOutlet weak var checkBoxWithTitleButton1: SelectionButton!
    @IBOutlet weak var checkBoxWithTitleButton2: SelectionButton!
    
    
    private var customAlertBackgroundView:UIVisualEffectView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        licenseTextField.layer.borderColor = UIColor(named: "AppBorderColor")?.cgColor
        licenseTextField.layer.borderWidth = 1.0
        licenseTextField.layer.cornerRadius = 4
        licenseTextField.backgroundColor = UIColor(named: "MainViewBackground")
        licenseTextField.font = UIFont(name: Fonts().lexendLight, size: 16.0)
        licenseTextField.textColor = UIColor(named: "MainTextColor")
        self.userLicenseTextView.layer.borderColor = UIColor(named: "UserRegistrationTextViewBorderColor")?.cgColor
        self.userLicenseTextView.backgroundColor = UIColor(named: "UserRegistrationTextViewBackgroundColor")
        self.userLicenseTextView.layer.borderWidth = 1.0
        self.userLicenseTextView.layer.cornerRadius = 4
        //self.submitButton.setTitle("Submit", for: .normal)
        
       
        
        self.submitButton.setAttributedTitleWithGradientDefaults(title: "Submit")
        self.userLicenseTextView.textContainerInset = UIEdgeInsets(top: 15, left: 16, bottom: 15, right: 10)
        self.navigationController?.isNavigationBarHidden = true
        printSystemFonts()
        
        checkBoxWithTitleButton1.contentLabel.text = "I have read it and understood."
        checkBoxWithTitleButton2.contentLabel.text = "I agree to share my info with medical provider"
    }
    
    public func printSystemFonts() {
        // Use this identifier to filter out the system fonts in the logs.
        let identifier: String = "[SYSTEM FONTS]"
        // Here's the functionality that prints all the system fonts.
        for family in UIFont.familyNames as [String] {
            debugPrint("\(identifier) FONT FAMILY :  \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                debugPrint("\(identifier) FONT NAME :  \(name)")
            }
        }
    }
    
    
   
    @IBAction func didClickOnSubmitButton(_ sender: UIButton) {
//        navigateToCreateAccount()
        addAlertView()
//        let next = UIStoryboard(name: "UserIntro", bundle: nil)
//        let vc = next.instantiateViewController(withIdentifier: "UserIntroDayFeedbackViewController") as? UserIntroDayFeedbackViewController
//        vc?.afternoonVC = true
//        vc?.titleString = "Good Afternoon"
//        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    private func addAlertView() {
        customAlertBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        customAlertBackgroundView?.frame = self.view.frame
        var customAlertView:CustomAlertView? = CustomAlertView(frame: .zero)
        customAlertBackgroundView?.contentView.addSubview(customAlertView!)
        customAlertView?.translatesAutoresizingMaskIntoConstraints = false
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
            self.navigateToCreateAccount()
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
    
    func navigateToCreateAccount(){

        let next = UIStoryboard(name: "CreateAccountVC", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "CreateAccountVC") as? CreateAccountVC
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    

}
