//
//  UIUtility.swift
//  MentalHealth
//
//  Created by KA on 16/02/24.
//

import Foundation
import UIKit

open class customUITextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //setup()
    }
    
    open override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(red: 110.0/255.0, green: 107.0/255.0, blue: 179.0/255.0, alpha: 1.0).cgColor
        self.layer.masksToBounds = true
        self.clipsToBounds = true
//        self.attributedPlaceholder = NSAttributedString(
//            string: self.placeholder ?? "",
//            attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "MainTextColor") ?? UIColor.black]
//        )
        self.textColor = UIColor(named: "MainTextColor")
        self.font = UIFont(name: Fonts().lexendLight, size: 16.0)
    }
    
    let padding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 5)

        override open func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }

        override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }

        override open func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.inset(by: padding)
        }
    
}

extension UIColor {
    public convenience init?(hex1: String) {
        let r, g, b, a: CGFloat

        if hex1.hasPrefix("#") {
            let start = hex1.index(hex1.startIndex, offsetBy: 1)
            let hexColor = String(hex1[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

extension UIView {

    func applyGradient(colours: [UIColor]) -> CAGradientLayer {
        return self.applyGradient(colours: colours, locations: nil)
    }


    func applyGradient(colours: [UIColor], locations: [NSNumber]?) -> CAGradientLayer {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
        return gradient
    }
    
//    shadowView.dropShadow(color: .red, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius

        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
      }
}

public class CapsuleButton: GradientButton{
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 2 / UIScreen.main.nativeScale
        layer.borderColor = UIColor(red: 110.0/255.0, green: 107.0/255.0, blue: 179.0/255.0, alpha: 1.0).cgColor
        self.clipsToBounds = true
        layer.cornerRadius = frame.height / 2
       
        //backgroundColor = UIColor(red: 110.0/255.0, green: 107.0/255.0, blue: 179.0/255.0, alpha: 1.0)
//        self.topGradientColor = UIColor.red//UIColor(red: 110, green: 107, blue: 179, alpha: 1.0)
//        self.bottomGradientColor = UIColor.orange//UIColor(red: 45, green: 51, blue: 74, alpha: 1.0)
        
    }
    
    
    public override func layoutSubviews(){
        super.layoutSubviews()
    }
    
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(
            x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )
        let locationOfTouchInTextContainer = CGPoint(
            x: locationOfTouchInLabel.x - textContainerOffset.x,
            y: locationOfTouchInLabel.y - textContainerOffset.y
        )
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}


extension UITextField {
  func addPaddingAndIcon(_ image: UIImage, padding: CGFloat,isLeftView: Bool) {
    let frame = CGRect(x: 0, y: 0, width: image.size.width + padding, height: image.size.height)
    
    let outerView = UIView(frame: frame)
    let iconView  = UIImageView(frame: frame)
    iconView.image = image
    iconView.contentMode = .center
    outerView.addSubview(iconView)
    
    if isLeftView {
      leftViewMode = .always
      leftView = outerView
    } else {
      rightViewMode = .always
      rightView = outerView
    }
    
  }
}
