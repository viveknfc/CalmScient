//
//  ProfileTextField.swift
//  CalmscientIOS
//
//  Created by NFC User on 24/12/24.
//

import Foundation
import UIKit

class CustomTextField: UITextField {
    
    private let toggleButton = UIButton(type: .custom)
    
    // Initializer for programmatically created text fields
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    // Initializer for storyboard/xib-based text fields
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // Setup UI appearance
    private func setupUI() {
        self.layer.cornerRadius = 10 // Rounded corners
        self.layer.borderWidth = 1.0 // Border width
        self.layer.borderColor = #colorLiteral(red: 0.429181397, green: 0.4192816615, blue: 0.7016126513, alpha: 1)
        self.font = UIFont(name: Fonts().lexendRegular, size: 14) // Custom font
        self.placeholder = "******" // Default placeholder
        self.textAlignment = .left // Optional: text alignment
        self.isSecureTextEntry = true
        self.delegate = self
        configureToggleButton()
    }
    
    // Configure the eye toggle button
    private func configureToggleButton() {
        toggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal) // Eye slash for hidden
        toggleButton.tintColor = .gray
        toggleButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        
        // Set button size
       toggleButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20) // Reduced size
       
       // Add padding on the right
       let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 30)) // Add padding space
       paddingView.addSubview(toggleButton)
       toggleButton.center = paddingView.center
       
       // Set the padding view as the right view
       self.rightView = paddingView
       self.rightViewMode = .always
    }
    
    // Action to toggle password visibility
    @objc private func togglePasswordVisibility() {
        self.isSecureTextEntry.toggle() // Toggle secure text entry
        let imageName = self.isSecureTextEntry ? "eye.slash" : "eye" // Change icon
        toggleButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // Prevent text changes containing spaces
    override func insertText(_ text: String) {
        if !text.contains(" ") {
            super.insertText(text)
        }
    }
    
}

extension CustomTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !string.contains(" ") // Block space entry
    }
}
