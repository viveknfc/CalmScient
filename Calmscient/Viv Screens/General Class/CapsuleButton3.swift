//
//  CapsuleButton3.swift
//  CalmscientIOS
//
//  Created by NFC User on 22/02/25.
//

import Foundation
import UIKit

class CapsuleButton3: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAppearance()
    }
    
    private func setupAppearance() {
        self.layer.borderColor = #colorLiteral(red: 0.431372549, green: 0.4196078431, blue: 0.7019607843, alpha: 1)
        self.layer.borderWidth = 2
        self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.setTitleColor(#colorLiteral(red: 0.431372549, green: 0.4196078431, blue: 0.7019607843, alpha: 1), for: .normal) // Static title color
        self.titleLabel?.font = UIFont(name: Fonts().lexendMedium, size: 14) // Static font
        self.layer.cornerRadius = 20 // Capsule shape
        self.clipsToBounds = true
        self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20) // Optional padding
        let title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Go back" : "Volver"
        self.setTitle(title, for: .normal)
    }
}
