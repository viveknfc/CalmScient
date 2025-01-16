//
//  ImagePaddingTextField.swift
//  CalmscientIOS
//
//  Created by NFC on 02/05/24.
//

import Foundation
import UIKit

@IBDesignable
public class ImagePaddingTextField : UITextField {
    
    @IBInspectable public var leftPadding:CGFloat = 0
    {
        didSet {
            self.rightViewSetup()
        }
    }
    @IBInspectable public var rightPadding:CGFloat = 0 {
        didSet {
            self.rightViewSetup()
        }
    }
    
    private var paddingInsets:UIEdgeInsets = .zero
    
    @IBInspectable var rightViewDefaultImage:UIImage? {
        didSet {
            self.rightViewSetup()
        }
    }
    
    @IBInspectable var rightViewSelectedImage:UIImage? {
        didSet {
            self.rightViewSetup()
        }
    }
    
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        rightViewSetup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        rightViewSetup()
    }
    
    private func rightViewSetup() {
        self.rightView?.removeFromSuperview()
        self.rightView = nil
        
        
        guard let rightViewDefaultImage = rightViewDefaultImage else {
            self.paddingInsets = UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: rightPadding)
            return
        }
        self.rightViewMode = .always
        self.rightView = UIImageView(image: rightViewDefaultImage)
        self.rightView?.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnRightView(tapGestureRecognizer:)))
        tapGesture.numberOfTapsRequired = 1
        self.rightView?.addGestureRecognizer(tapGesture)
        if rightViewSelectedImage != nil {
            self.isSecureTextEntry = true
        }
        self.paddingInsets = UIEdgeInsets(top: 0, left: leftPadding, bottom: 0, right: rightPadding + rightViewDefaultImage.size.width + 8)
       
    }
    
    public override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        guard let _rightViewDefaultImage = rightViewDefaultImage else {
            return .zero
        }
        let centerYTextField = bounds.height / 2
        let rightViewY = centerYTextField - (_rightViewDefaultImage.size.height / 2)
        let rightViewFrame = CGRect(x: (bounds.width - rightPadding - (_rightViewDefaultImage.size.width)), y: rightViewY, width: _rightViewDefaultImage.size.width, height: _rightViewDefaultImage.size.height)
        return rightViewFrame
    }
    
    @objc func tappedOnRightView(tapGestureRecognizer: UITapGestureRecognizer)
    {
        guard let tappedImageView = tapGestureRecognizer.view as? UIImageView else {
            return
        }
        tappedImageView.contentMode = .scaleAspectFit
        guard let _ = rightViewSelectedImage else {
            return
        }
        let state = self.isSecureTextEntry

        if state == false {
            UIView.transition(with: tappedImageView, duration: 0.15,options: .transitionCrossDissolve) {
                tappedImageView.image = self.rightViewDefaultImage
            }

        } else {
            UIView.transition(with: tappedImageView, duration: 0.15,options: .transitionCrossDissolve) {
                tappedImageView.image = self.rightViewSelectedImage
            }
        }
        self.isSecureTextEntry.toggle()
        let tempText = self.text
        self.text = ""
        self.text = tempText
    }
 
    
      override open func textRect(forBounds bounds: CGRect) -> CGRect {
          return bounds.inset(by: self.paddingInsets)
      }
      
      override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
          return bounds.inset(by: self.paddingInsets)
      }
      
      override open func editingRect(forBounds bounds: CGRect) -> CGRect {
          return bounds.inset(by: self.paddingInsets)
      }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.rightViewSetup()
    }
}
