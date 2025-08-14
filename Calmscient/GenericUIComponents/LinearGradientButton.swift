//
//  LinearGradientButton.swift
//  HealthApp
//
//  Created by KA on 12/03/24.
//

import Foundation
import UIKit

@IBDesignable
public class LinearGradientButton: UIButton {
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setGradient()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setGradient()
    }
    
    var defaultTitleAttributes:[NSAttributedString.Key: Any] = [
        .font: UIFont(name: Fonts().lexendMedium, size: 16.0) ?? UIFont.systemFont(ofSize: 18),
        .foregroundColor: UIColor.white,
    ]
    
    let gradientLayer = CAGradientLayer()
    
    @IBInspectable
    var topGradientColor: UIColor = UIColor(named: "GradientButtonColor1") ?? UIColor.blue {
        didSet {
            setGradient()
        }
    }
    
    @IBInspectable
    var bottomGradientColor: UIColor = UIColor(named: "GradientButtonColor2") ?? UIColor.blue {
        didSet {
            setGradient()
        }
    }
    
    public func setGradient() {
        if layer.sublayers?.contains(gradientLayer) ?? false {
            gradientLayer.removeFromSuperlayer()
        }
        gradientLayer.frame = bounds
        gradientLayer.colors = [topGradientColor.cgColor, bottomGradientColor.cgColor]
        gradientLayer.borderColor = layer.borderColor
        gradientLayer.borderWidth = layer.borderWidth
        gradientLayer.cornerRadius = layer.cornerRadius
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.clipsToBounds = true
        }
    }
    
    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        gradientLayer.frame = bounds
//        setGradient()
    }
    
    public func setAttributedTitle(attributedTitleText:String, attributes:[NSAttributedString.Key: Any]? = nil) {
        let titleAttributes = (attributes != nil) ? attributes : defaultTitleAttributes
        let attributedTitle = NSAttributedString(string: attributedTitleText, attributes: titleAttributes)
        self.setAttributedTitle(attributedTitle, for: .normal)
    }
    
    public func setAttributedTitleWithGradientDefaults(title:String) {
        self.cornerRadius = self.bounds.height/2
        setGradient()
        setAttributedTitle(attributedTitleText: title)
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setGradient()
    }
    
}
