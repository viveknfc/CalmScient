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
        
        successContent.numberOfLines = 0
        successContent.lineBreakMode = .byWordWrapping

       }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure the main view encompasses all subviews
        let requiredHeight = calculateRequiredHeight()
        if bounds.height < requiredHeight {
            frame.size.height = requiredHeight
        }
        
        print("After layout - Self bounds: \(bounds)")
        print("MainView bounds: \(mainView.bounds)")
        print("Button frame: \(okButton.frame)")
        print("Button maxY: \(okButton.frame.maxY), Self height: \(bounds.height)")
    }

    func calculateRequiredHeight() -> CGFloat {
        layoutIfNeeded()
        
        let imageHeight = centreImage.frame.maxY
        let contentHeight = successContent.frame.maxY
        let buttonHeight = okButton.frame.maxY
        
        return max(imageHeight, contentHeight, buttonHeight) + 20 // Add padding
    }
    
    
    @IBAction func okButtonTapped(_ sender: Any) {
        print("OK button tapped! from SuccessAlertView")
        okButtonAction?()
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        return hitView
    }
    
}

extension UIViewController {
    func showSuccessAlert(successContent: String? = nil, centreImage: UIImage? = nil, okButtonAction: (() -> Void)? = nil) {
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let window = windowScene.windows.first else { return }
        
        window.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
        
//        self.view.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
        
        // Create a dimming background view
        let dimmingView = UIView(frame: UIScreen.main.bounds)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView.alpha = 0 // Start invisible
        dimmingView.tag = 999 // Add a tag to identify and remove it later

//        let alertView = SuccessAlertView(frame: CGRect(x: 40, y: (UIScreen.main.bounds.height - 250) / 2, width: UIScreen.main.bounds.width - 80, height: 280))

        let alertWidth: CGFloat = UIScreen.main.bounds.width - 80

        let alertView = SuccessAlertView(
            frame: CGRect(x: 0, y: 0, width: alertWidth, height: 0) // height = 0 placeholder
        )

        // let it lay out its subviews and compute intrinsic size
        alertView.layoutIfNeeded()

        // adjust height based on calculated content
        let requiredHeight = alertView.calculateRequiredHeight()
        alertView.frame.size.height = requiredHeight

        // finally, center it in window
        alertView.center = window.center

        
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

        window.addSubview(dimmingView)
        window.addSubview(alertView)

        alertView.center = window.center

        
        // Animate the appearance
        UIView.animate(withDuration: 0.3) {
            dimmingView.alpha = 1
            alertView.alpha = 1
        }
    }
}


