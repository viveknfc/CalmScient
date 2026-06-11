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
