//
//  SuccessAlertView.swift
//  CalmscientIOS
//
//  Created by NFC User on 06/01/25.
//

import UIKit

class SuccessAlertView: UIView {
    
    
    @IBOutlet weak var centreImage: UIImageView!
    @IBOutlet weak var successContent: FontLR12!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var okButton: LinearGradientButton!
    
    var okButtonAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib(nibName: "SuccessAlertVIew")
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromNib(nibName: "SuccessAlertVIew")
        configureView()
    }
    
    private func loadViewFromNib(nibName: String) {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
               fatalError("Failed to load \(nibName) from nib.")
           }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    private func configureView() {
           // Add rounded corners to the main view
           mainView.layer.cornerRadius = 16.0 // Adjust the radius as needed
           mainView.layer.masksToBounds = true
       }
    
    
    @IBAction func okButtonTapped(_ sender: Any) {
        print("OK button tapped! from SuccessAlertView")
        okButtonAction?()
    }
    
}

extension UIViewController {
    func showSuccessAlert(successContent: String? = nil, centreImage: UIImage? = nil, okButtonAction: (() -> Void)? = nil) {
        
        self.view.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
        
        // Create a dimming background view
        let dimmingView = UIView(frame: UIScreen.main.bounds)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView.alpha = 0 // Start invisible
        dimmingView.tag = 999 // Add a tag to identify and remove it later
        
        // Initialize the SuccessAlertView
//        let alertView = SuccessAlertView(frame: CGRect(x: 40, y: (UIScreen.main.bounds.height - 200) / 2, width: UIScreen.main.bounds.width - 80, height: 200))

//        let alertViewHeight: CGFloat = 200 + (centreImage?.size.height ?? 0) - 100 // Adjust the height based on the new image size
        let alertView = SuccessAlertView(frame: CGRect(x: 40, y: (UIScreen.main.bounds.height - 250) / 2, width: UIScreen.main.bounds.width - 80, height: 280))

        
        // Configure the successContent if provided
        if let content = successContent {
            alertView.successContent.text = content
        }
        
        // Configure the centreImage if provided
        if let image = centreImage {
            alertView.centreImage.image = image
        }
        
        // Set the OK button action
        alertView.okButtonAction = {
            print("OK button tapped! from showSuccessAlert fucntion")
            // Animate the removal of the dimming view and alert view
            UIView.animate(withDuration: 0.3, animations: {
                dimmingView.alpha = 0
                alertView.alpha = 0
            }, completion: { _ in
                dimmingView.removeFromSuperview()
                alertView.removeFromSuperview()
            })
            okButtonAction?() // Execute the provided action
        }
        
        // Add the dimming view and alert view to the current view
        self.view.addSubview(dimmingView)
        self.view.addSubview(alertView)

        
        // Animate the appearance
        UIView.animate(withDuration: 0.3) {
            dimmingView.alpha = 1
            alertView.alpha = 1
        }
    }
}

