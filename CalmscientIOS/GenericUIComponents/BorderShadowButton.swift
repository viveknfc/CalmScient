//
//  BorderShadowButton.swift
//  MainTabBarApp
//
//  Created by KA on 11/04/24.
//

import UIKit

class BorderShadowButton: UIButton {

    let shadowLayer = CAShapeLayer()

    @IBInspectable
    var shadowColor: UIColor = UIColor.red {
        didSet {
            makeRoundedAndShadowed()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            makeRoundedAndShadowed()
        }
    }
    
    @IBInspectable var customBorderWidth: CGFloat = 3.0 {
        didSet {
            makeRoundedAndShadowed()
        }
    }
    
    @IBInspectable var customBorderColor: UIColor = UIColor(named: "borderButtonMainColor") ?? UIColor.blue {
        didSet {
            makeRoundedAndShadowed()
        }
    }
    
    
    var defaultTitleAttributes:[NSAttributedString.Key: Any] = [
        .font: UIFont(name: Fonts().lexendMedium, size: 18.0) ?? UIFont.systemFont(ofSize: 18),
        .foregroundColor: UIColor(named: "borderButtonMainColor") ?? UIColor.blue,
    ]

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()
        makeRoundedAndShadowed()
    }
    
    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        shadowLayer.frame = bounds
    }
    
    
    func makeRoundedAndShadowed() {
        self.backgroundColor = UIColor(named: "AppBackGroundColor")!
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.layer.borderColor = customBorderColor.cgColor
        self.layer.borderWidth = customBorderWidth
        
        if layer.sublayers?.contains(shadowLayer) ?? false {
            shadowLayer.removeFromSuperlayer()
        }
        shadowLayer.path = UIBezierPath(roundedRect: self.bounds,
                                        cornerRadius: self.layer.cornerRadius).cgPath
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.fillColor = self.backgroundColor?.cgColor
        shadowLayer.shadowColor = UIColor.red.cgColor
        shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        shadowLayer.shadowOpacity = 1
        shadowLayer.shadowRadius = 5.0
        self.layer.insertSublayer(shadowLayer, at: 0)
    }
    
    public func setAttributedTitleWithGradientDefaults(title:String) {
        self.cornerRadius = self.bounds.height/2
        makeRoundedAndShadowed()
        setAttributedTitle(attributedTitleText: title)
    }
    
    public func setAttributedTitle(attributedTitleText:String, attributes:[NSAttributedString.Key: Any]? = nil) {
        
        let titleAttributes = (attributes != nil) ? attributes : defaultTitleAttributes
        let attributedTitle = NSAttributedString(string: attributedTitleText, attributes: titleAttributes)
        self.setAttributedTitle(attributedTitle, for: .normal)
    }

}
