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
    
    @IBOutlet weak var firstCheck: UIButton!
    @IBOutlet weak var firstLabel: FontLR15!
    @IBOutlet weak var secondCheck: UIButton!
    @IBOutlet weak var secondLabel: FontLR15!
    
    var buttonState1: SelectionButtonState = .dafault
    var buttonState2: SelectionButtonState = .dafault
    
    
    var navController: UINavigationController?
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
        self.userLicenseTextView.isEditable = false
 
        self.submitButton.setAttributedTitleWithGradientDefaults(title: "Submit")
        self.userLicenseTextView.textContainerInset = UIEdgeInsets(top: 15, left: 16, bottom: 15, right: 10)
        self.navigationController?.isNavigationBarHidden = true
        
        updateButtonImage1()
        updateButtonImage2()
        firstLabel.text = "I have read it and understood."
        secondLabel.text = "I agree to share my info with medical provider"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //CHeck Box
    
    @IBAction func firstCheckboxPressed(_ sender: Any) {
        buttonState1 = (buttonState1 == .dafault) ? .selected : .dafault
        updateButtonImage1()
    }
    
    private func updateButtonImage1() {
        firstCheck.setImage(buttonState1.getAssetImageForState(), for: .normal)
        }
    
    
    @IBAction func secondCheckboxPressed(_ sender: Any) {
        buttonState2 = (buttonState2 == .dafault) ? .selected : .dafault
        updateButtonImage2()
    }
    
    private func updateButtonImage2() {
        secondCheck.setImage(buttonState2.getAssetImageForState(), for: .normal)
        }
    
   
    @IBAction func didClickOnSubmitButton(_ sender: UIButton) {

        addAlertView()
        
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
        customAlertView?.heightAnchor.constraint(equalToConstant: 315).isActive = true //self.view.frame.height * 0.30
         

    }
    
    func navigateToCreateAccount(){

//        let next = UIStoryboard(name: "CreateAccountVC", bundle: nil)
//        let vc = next.instantiateViewController(withIdentifier: "CreateAccountVC") as? CreateAccountVC
//        self.navigationController?.pushViewController(vc!, animated: true)
        
        let storyboard = UIStoryboard(name: "UserIntro", bundle: nil)
            let homeViewController = storyboard.instantiateViewController(withIdentifier: "UserIntroDayFeedbackViewController") as! UserIntroDayFeedbackViewController
        homeViewController.afternoonVC = true
        let titleS = ApplicationSharedInfo.shared.loginResponse?.firstName ?? ""
        homeViewController.titleString = "\(titleS)"
        UserDefaults.standard.set("\(titleS)", forKey: "titleString")
            // Wrap the home view controller in a navigation controller if needed
            navController = UINavigationController(rootViewController: homeViewController)
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(to: navController!)
        }
        
    }
    

}
