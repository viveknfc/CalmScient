//
//  CapsuleButton.swift
//  CalmscientIOS
//
//  Created by NFC User on 03/12/24.
//

import Foundation
import UIKit

class CapsuleButton1: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAppearance()
    }
    
    private func setupAppearance() {
        self.backgroundColor = #colorLiteral(red: 0.429181397, green: 0.4192816615, blue: 0.7016126513, alpha: 1)
        self.setTitleColor(.white, for: .normal) // Static title color
        self.titleLabel?.font = UIFont(name: Fonts().lexendMedium, size: 14) // Static font
        self.layer.cornerRadius = 20 // Capsule shape
        self.clipsToBounds = true
        self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20) // Optional padding
        let title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Complete" : "Completo"
        self.setTitle(title, for: .normal)
    }
}
