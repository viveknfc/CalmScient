//
//  FontLR18.swift
//  CalmscientIOS
//
//  Created by NFC User on 28/11/24.
//

import Foundation
import UIKit

class FontLR18: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFont()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupFont()
    }
    
    private func setupFont() {
        self.font = UIFont(name: Fonts().lexendRegular, size: 18)
    }
}
