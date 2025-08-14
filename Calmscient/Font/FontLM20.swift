//
//  FontLM20.swift
//  CalmscientIOS
//
//  Created by NFC User on 28/02/25.
//

import Foundation
import UIKit

class FontLM20: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFont()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupFont()
    }
    
    private func setupFont() {
        self.font = UIFont(name: Fonts().lexendMedium, size: 20)
    }
}
