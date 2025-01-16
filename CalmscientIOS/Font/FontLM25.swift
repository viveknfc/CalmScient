//
//  FontLM25.swift
//  CalmscientIOS
//
//  Created by NFC User on 18/12/24.
//

import Foundation
import UIKit

class FontLM25: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFont()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupFont()
    }
    
    private func setupFont() {
        self.font = UIFont(name: Fonts().lexendMedium, size: 25)
    }
}
