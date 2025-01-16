//
//  FontLL12.swift
//  CalmscientIOS
//
//  Created by NFC User on 04/12/24.
//

import Foundation
import UIKit

class FontLL12: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFont()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupFont()
    }
    
    private func setupFont() {
        self.font = UIFont(name: Fonts().lexendLight, size: 12)
    }
}
