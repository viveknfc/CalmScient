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
        print(UIFont(name: Fonts().lexendLight, size: 16) ?? "Font not found")
        let font = UIFont(name: Fonts().lexendLight, size: 16) ?? UIFont.systemFont(ofSize: 16)

        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = #colorLiteral(red: 0.429181397, green: 0.4192816615, blue: 0.7016126513, alpha: 1)
            config.baseForegroundColor = .white
            config.cornerStyle = .capsule
            config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)

            var attributedTitle = AttributedString(title)
            attributedTitle.font = font
            attributedTitle.foregroundColor = .white

            config.attributedTitle = attributedTitle
            self.configuration = config
        } else {
            self.backgroundColor = #colorLiteral(red: 0.429181397, green: 0.4192816615, blue: 0.7016126513, alpha: 1)
            self.setTitleColor(.white, for: .normal)
            self.titleLabel?.font = font
            self.layer.cornerRadius = 20
            self.clipsToBounds = true
            self.setTitle(title, for: .normal)
        }
    }

    func updateTitleForLanguage() {
        let title = getLocalizedTitle()
        let font = UIFont(name: Fonts().lexendMedium, size: 14) ?? UIFont.systemFont(ofSize: 14)

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


