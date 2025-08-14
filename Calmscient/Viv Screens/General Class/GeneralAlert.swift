//
//  GeneralAlert.swift
//  CalmscientIOS
//
//  Created by NFC User on 28/03/25.
//

import UIKit

class GeneralAlert: UIView {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertImage: UIImageView!
    @IBOutlet weak var alertText: FontLL12!
    @IBOutlet weak var alertOkButton: LinearGradientButton!
    @IBOutlet weak var alertDismissButton: UIButton!
    @IBOutlet weak var BGView: UIView!
    
    
    var okAction: (() -> Void)?
    var dismissAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        BGView.isUserInteractionEnabled = false
        alertView.layer.cornerRadius = 16
        alertView.clipsToBounds = true
    }

    @IBAction func okButtonTapped(_ sender: UIButton) {
        print("✅ OK Button Pressed")
        okAction?()
        self.removeFromSuperview()
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        print("✅ Dismiss Button Pressed")
        dismissAction?()
        self.removeFromSuperview()
    }
}

extension UIViewController {
    func showGeneralAlert(
        image: UIImage? = nil,
        imageSize: CGSize? = nil,
        title: String,
        okButtonTitle: String = AppHelper.getLocalizeString(str: "Ok"),
        okAction: (() -> Void)? = nil,
        dismissAction: (() -> Void)? = nil,
        showDismissButton: Bool = true
    ) {
        let alertView = Bundle.main.loadNibNamed("GeneralAlertView", owner: self, options: nil)?.first as! GeneralAlert

        // Ensure alertView covers the entire screen
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let keyWindow = windowScene.windows.first {
            alertView.frame = keyWindow.bounds
            keyWindow.addSubview(alertView)
        } else {
            alertView.frame = self.view.bounds
            self.view.addSubview(alertView)
        }
        
        alertView.alertText.text = title
        alertView.alertOkButton.setTitle(okButtonTitle, for: .normal)
        alertView.okAction = okAction
        alertView.dismissAction = dismissAction

        
        if let alertImage = image {
            alertView.alertImage.image = alertImage
            alertView.alertImage.isHidden = false
            
            // Set image size if provided
            if let imageSize = imageSize {
                alertView.alertImage.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    alertView.alertImage.widthAnchor.constraint(equalToConstant: imageSize.width),
                    alertView.alertImage.heightAnchor.constraint(equalToConstant: imageSize.height)
                ])
            }
            
        } else {
            alertView.alertImage.isHidden = true
            if let heightConstraint = alertView.alertImage.constraints.first(where: { $0.firstAttribute == .height }) {
                heightConstraint.constant = 0
            }
        }
        
        alertView.alertDismissButton.isHidden = !showDismissButton
    }
}
