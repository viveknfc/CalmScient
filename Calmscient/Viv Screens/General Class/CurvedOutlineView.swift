//
//  CurvedOutlineView.swift
//  CalmscientIOS
//
//  Created by NFC User on 26/12/24.
//

import Foundation
import UIKit

class CurvedOutlineView: UIView {
    
    // Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // Set default corner radius and border width
        self.layer.cornerRadius = 18
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(named: "VTextColor2")?.cgColor
        self.clipsToBounds = true
        
        // Set a default background color
        self.backgroundColor = .clear
    }
    
    // MARK: - Customization Methods
    
    func setCornerRadius(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    func setBorderColor(_ color: UIColor) {
        self.layer.borderColor = color.cgColor
    }
    
    func setBorderWidth(_ width: CGFloat) {
        self.layer.borderWidth = width
    }
    
    func setBackgroundColor(_ color: UIColor) {
        self.backgroundColor = color
    }
}
