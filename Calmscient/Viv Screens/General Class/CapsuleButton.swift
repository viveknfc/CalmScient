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
        let title = getLocalizedTitle()
        guard let font = UIFont(name: Fonts().lexendLight, size: 14) else {
            print("Font not found, using system font")
            return
        }

        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = UIColor(red: 0.43, green: 0.42, blue: 0.70, alpha: 1)
            config.baseForegroundColor = .white
            config.cornerStyle = .capsule
            config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)

            // Properly set attributed title
            var attributedTitle = AttributedString(title)
            attributedTitle.font = font
            attributedTitle.foregroundColor = .white
            config.attributedTitle = attributedTitle

            // Optional: force the font transformer to prevent overrides
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = font
                return outgoing
            }

            self.configuration = config
        } else {
            // iOS < 15 fallback
            self.backgroundColor = UIColor(red: 0.43, green: 0.42, blue: 0.70, alpha: 1)
            self.setTitleColor(.white, for: .normal)
            self.titleLabel?.font = font
            self.layer.cornerRadius = 20
            self.clipsToBounds = true
            self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
            self.setTitle(title, for: .normal)
        }
    }

    func updateTitleForLanguage() {
        let title = getLocalizedTitle()
        let font = UIFont(name: Fonts().lexendLight, size: 14) ?? UIFont.systemFont(ofSize: 14)

        if #available(iOS 15.0, *) {
            var updatedConfig = self.configuration ?? UIButton.Configuration.filled()

            var attributedTitle = AttributedString(title)
            attributedTitle.font = font
            attributedTitle.foregroundColor = .white

            updatedConfig.attributedTitle = attributedTitle
            self.configuration = updatedConfig
        } else {
            self.setTitle(title, for: .normal)
            self.titleLabel?.font = font
        }
    }

    private func getLocalizedTitle() -> String {
        return UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Complete" : "Finalizar"
    }
}


