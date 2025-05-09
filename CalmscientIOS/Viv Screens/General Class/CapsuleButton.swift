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
        let title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Complete" : "Finalizar"
        let font = UIFont(name: Fonts().lexendLight, size: 16) ?? UIFont.systemFont(ofSize: 16)

        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = #colorLiteral(red: 0.429181397, green: 0.4192816615, blue: 0.7016126513, alpha: 1)
            config.baseForegroundColor = .white
            config.cornerStyle = .capsule
            config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)

            // Set attributed title with font
            let attributedString = NSAttributedString(string: title, attributes: [
                .font: font,
                .foregroundColor: UIColor.white
            ])
            config.attributedTitle = AttributedString(attributedString)

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
        let title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Complete" : "Finalizar"
        let font = UIFont(name: Fonts().lexendMedium, size: 14) ?? UIFont.systemFont(ofSize: 14)

        if #available(iOS 15.0, *) {
            var updatedConfig = self.configuration ?? UIButton.Configuration.filled()
            let attributedString = NSAttributedString(string: title, attributes: [
                .font: font,
                .foregroundColor: UIColor.white
            ])
            updatedConfig.attributedTitle = AttributedString(attributedString)
            self.configuration = updatedConfig
        } else {
            self.setTitle(title, for: .normal)
            self.titleLabel?.font = font
        }
    }
}

