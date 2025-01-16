//
//  CustomCollectionViewCell.swift
//  TestCollectionViewCell
//
//  Created by KA on 24/03/24.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell
{
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .red
        // Initialization code
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addCircularShape()
        addTextLayer()
    }
    
    @IBInspectable var contentTextColor:UIColor? = UIColor(named: "circleTextColor")
    
    private func getTextAttributes() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        paragraphStyle.lineSpacing = 0
        let textAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: contentTextColor ?? UIColor.darkGray,
            .font: UIFont.boldSystemFont(ofSize: 10),
            .paragraphStyle: paragraphStyle
        ]
        return textAttributes
    }
    
    
    public func setCircleText(text:String) {
        addTextLayer(text: text)
    }
    
    @IBInspectable var circleFillColor:UIColor? = UIColor(named: "circleFillColor") {
        didSet {
            addCircularShape()
        }
    }
    
    @IBInspectable var circleStrokeColor:UIColor? = UIColor(named: "circleBorderColor") {
        didSet {
            addCircularShape()
        }
    }
    
    @IBInspectable var circleBorderWidth:CGFloat = 2 {
        didSet {
            addCircularShape()
        }
    }
    
    
    private var circleShapeLayer = CAShapeLayer()
    private var textLayer = CATextLayer()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addCircularShape()
        addTextLayer()
    }
    
    public func addCircularShape() {
        if circleShapeLayer.superlayer != nil {
            circleShapeLayer.removeFromSuperlayer()
        }
        circleShapeLayer = CAShapeLayer()
        circleShapeLayer.path = UIBezierPath(ovalIn: self.bounds).cgPath
        circleShapeLayer.fillColor = circleFillColor?.cgColor
        circleShapeLayer.strokeColor = circleStrokeColor?.cgColor
        circleShapeLayer.lineWidth = circleBorderWidth
        self.layer.addSublayer(circleShapeLayer)
    }
    
    public func addTextLayer(text:String = " 1\(Int.random(in: 1...9))\nPM ") {
        if textLayer.superlayer != nil {
            textLayer.removeFromSuperlayer()
        }
        let uiText = NSAttributedString(string: text, attributes: getTextAttributes())
        let textSize = uiText.size()
        let viewWidth = self.bounds.width
        let viewHeight = self.bounds.height
        textLayer = CATextLayer()
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.string = uiText
        textLayer.frame = CGRect(x: (viewWidth-textSize.width)/2, y: (viewHeight-textSize.height)/2, width: textSize.width, height: textSize.height)
        self.layer.addSublayer(textLayer)
    }
    
}

