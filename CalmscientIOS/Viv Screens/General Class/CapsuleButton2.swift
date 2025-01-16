//
//  CapsuleButton2.swift
//  CalmscientIOS
//
//  Created by NFC User on 18/12/24.
//

import Foundation
import UIKit

class CapsuleButton2: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAppearance()
    }
    
    private func setupAppearance() {
        self.layer.borderColor = #colorLiteral(red: 0.392156899, green: 0.3921568394, blue: 0.392156899, alpha: 1)
        self.layer.borderWidth = 2
        self.setTitleColor(.darkGray, for: .normal) // Static title color
        self.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14) // Static font
        self.layer.cornerRadius = 15 // Capsule shape
        self.clipsToBounds = true
        self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20) // Optional padding
    }
}
