//
//  ImageView.swift
//  CalmscientIOS
//
//  Created by NFC User on 30/11/24.
//

import Foundation
import UIKit

class RoundedImageView: UIImageView {
    private var cornerRadius: CGFloat = 10

    // Custom initializer
    init(cornerRadius: CGFloat = 10) {
        super.init(frame: .zero)
        self.cornerRadius = cornerRadius
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
        self.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
    }

}
