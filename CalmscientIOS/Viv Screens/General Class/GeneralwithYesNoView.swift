//
//  GeneralwithYesNoView.swift
//  CalmscientIOS
//
//  Created by NFC User on 09/04/25.
//

import UIKit

class GeneralwithYesNoView: UIView {

        @IBOutlet weak var alertView: UIView!
        @IBOutlet weak var alertImage: UIImageView!
        @IBOutlet weak var alertMainText: FontLM14!
        @IBOutlet weak var alertSubText: FontLR12!
        @IBOutlet weak var alertOkButton: LinearGradientButton!
        @IBOutlet weak var alertCancelButton: UIButton!
        @IBOutlet weak var BGView: UIView!
        
        
        var okAction: (() -> Void)?
        var cancelAction: (() -> Void)?

        override func awakeFromNib() {
            super.awakeFromNib()
            BGView.isUserInteractionEnabled = false
            alertView.layer.cornerRadius = 16
            alertView.clipsToBounds = true
            
            alertCancelButton.layer.borderColor = #colorLiteral(red: 0.4635629654, green: 0.505692482, blue: 0.7547530532, alpha: 1)
            alertCancelButton.layer.borderWidth = 1.0
            alertCancelButton.layer.cornerRadius = 20 // Optional: to match style
            alertCancelButton.clipsToBounds = true
            
        }

        @IBAction func okButtonTapped(_ sender: UIButton) {
            print("✅ OK Button Pressed")
            okAction?()
            self.removeFromSuperview()
        }
        
        @IBAction func dismissButtonTapped(_ sender: UIButton) {
            print("✅ Dismiss Button Pressed")
            cancelAction?()
            self.removeFromSuperview()
        }
    }


    extension UIViewController {
        func showGeneralAlertYesNo(
            image: UIImage? = nil,
            imageSize: CGSize? = nil,
            title: String,
            subTitle: String,
            okButtonTitle: String = "OK",
            cancelButtonTitle: String = "Cancel",
            okAction: (() -> Void)? = nil,
            cancelAction: (() -> Void)? = nil,
            titleFontSize: CGFloat? = nil,
            subtitleFontSize: CGFloat? = nil
        ) {
            let alertView = Bundle.main.loadNibNamed("GeneralAlertwithYesNo", owner: self, options: nil)?.first as! GeneralwithYesNoView


            // Ensure alertView covers the entire screen
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first {
                alertView.frame = keyWindow.bounds
                keyWindow.addSubview(alertView)
            } else {
                alertView.frame = self.view.bounds
                self.view.addSubview(alertView)
            }
            
            alertView.alertMainText.text = title
            alertView.alertSubText.text = subTitle
            alertView.alertOkButton.setTitle(okButtonTitle, for: .normal)
            alertView.alertCancelButton.setTitle(cancelButtonTitle, for: .normal)
            alertView.okAction = okAction
            alertView.cancelAction = cancelAction

            // Set font sizes if provided
            if let titleFontSize = titleFontSize {
                alertView.alertMainText.font = alertView.alertMainText.font.withSize(titleFontSize)
            }
            if let subtitleFontSize = subtitleFontSize {
                alertView.alertSubText.font = alertView.alertSubText.font.withSize(subtitleFontSize)
            }
            
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
        }
    }
