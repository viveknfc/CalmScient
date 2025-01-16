//
//  CurvedOutlineButton.swift
//  CalmscientIOS
//
//  Created by NFC User on 29/11/24.
//

import Foundation
import UIKit

class CurvedOutlineButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        // Set a default corner radius and border width
        self.layer.cornerRadius = 18
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(named: "VTextColor2")?.cgColor
        self.clipsToBounds = true
        
        // Set default transparent background
        self.backgroundColor = .clear
        
        self.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14) // Default font
        self.setTitleColor(UIColor(named: "VTextColor2")!)
        self.contentHorizontalAlignment = .left
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        self.widthAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
    }
    
    // Optionally, you can add properties to customize these values
    func setCornerRadius(_ radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    func setBorderColor(_ color: UIColor) {
        self.layer.borderColor = color.cgColor
    }
    
    func setBorderWidth(_ width: CGFloat) {
        self.layer.borderWidth = width
    }
    
    func setFont(_ font: UIFont) {
            self.titleLabel?.font = font
        }
        
    func setTitleAlignment(_ alignment: UIControl.ContentHorizontalAlignment) {
            self.contentHorizontalAlignment = alignment
        }
    
    func setTitleColor(_ color: UIColor) {
            self.setTitleColor(color, for: .normal)
        }
}
