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
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = #colorLiteral(red: 0.429181397, green: 0.4192816615, blue: 0.7016126513, alpha: 1)
            config.baseForegroundColor = .white
            config.title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Complete" : "Completo"
            config.cornerStyle = .capsule // Ensures the capsule shape
            config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20) // Alternative to contentEdgeInsets
            
            self.configuration = config
        } else {
            self.backgroundColor = #colorLiteral(red: 0.429181397, green: 0.4192816615, blue: 0.7016126513, alpha: 1)
            self.setTitleColor(.white, for: .normal)
            self.titleLabel?.font = UIFont(name: Fonts().lexendMedium, size: 14)
            self.layer.cornerRadius = 20
            self.clipsToBounds = true
            self.setTitle(UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Complete" : "Completo", for: .normal)
        }

    }
    
    func updateTitleForLanguage() {
        let selectedLanguageID = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        let title = selectedLanguageID == 1 ? "Complete" : "Finalizar"

        if #available(iOS 15.0, *) {
            var updatedConfig = self.configuration ?? UIButton.Configuration.filled()
            updatedConfig.title = title
            self.configuration = updatedConfig
        } else {
            self.setTitle(title, for: .normal)
        }
    }

}
