//
//  CustomAlertView.swift
//  HealthApp
//
//

import Foundation
import UIKit



class CustomAlertView : UIView {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var continueButton: LinearGradientButton!
    public var okAction:(() -> Void)?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromNib(nibName: "CustomAlertView")
    }
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        titleLabel.text = AppHelper.getLocalizeString(str: "Your License key has\nbeen verified.")
        contentLabel.text = AppHelper.getLocalizeString(str: "Please complete your profile to start using Calmscient.")
        continueButton.titleLabel?.text = AppHelper.getLocalizeString(str: "Continue")
        
        }
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib(nibName: "CustomAlertView")
        continueButton.layer.cornerRadius = continueButton.frame.height/2
        continueButton.layer.masksToBounds = true
        setupLanguage()
    }
    
    
    @IBAction func didClickOnContinueButton(_ sender: Any) {
        self.okAction?()
    }
    
    
    private func loadViewFromNib(nibName: String) {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    deinit {
        print("CustomAlertView Deinit called")
    }
    
}

