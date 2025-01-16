//
//  CustomProgressBar.swift
//  CalmscientIOS
//
//  Created by NFC Solutions on 6/17/24.
//

import Foundation
import UIKit

class CustomProgressBar: UIView {

    private let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.purple
        view.layer.cornerRadius = 10
        return view
    }()
    
    var progress: CGFloat = 0.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(backgroundView)
        addSubview(progressView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = bounds
        let progressWidth = bounds.width * progress
        progressView.frame = CGRect(x: 0, y: 0, width: progressWidth, height: bounds.height)
    }
}
