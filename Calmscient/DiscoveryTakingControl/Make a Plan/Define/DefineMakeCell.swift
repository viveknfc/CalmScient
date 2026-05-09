//
//  DefineMakeCell.swift
//  CalmscientIOS
//
//  Created by mac on 25/06/24.
//

import UIKit

class DefineMakeCell: UITableViewCell {
    @IBOutlet weak var label: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupLocalizedLabel()
      
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    
    private func setupLocalizedLabel() {
        let fullText = AppHelper.getLocalizeString(str: "define_make_full_text")
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        let defaultTextColor: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "AppLightTextColor") ?? UIColor.darkGray
        ]
        attributedString.addAttributes(defaultTextColor, range: NSRange(location: 0, length: attributedString.length))
        
        let hyperlinkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "AppThemeColor")!
        ]
        
        let highlight1 = AppHelper.getLocalizeString(str: "define_make_highlight_1")
        let highlight2 = AppHelper.getLocalizeString(str: "define_make_highlight_2")
        attributedString.addAttributes(hyperlinkAttributes, range: (fullText as NSString).range(of: highlight1))
        attributedString.addAttributes(hyperlinkAttributes, range: (fullText as NSString).range(of: highlight2))
        
        label.attributedText = attributedString
        label.font = UIFont(name: Fonts().lexendRegular, size: 15)

    }

//
    private func indexOfCharacter(at point: CGPoint, in label: UILabel) -> Int {
        guard let attributedText = label.attributedText else { return NSNotFound }
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        textContainer.lineFragmentPadding = 0.0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let boundingRect = layoutManager.boundingRect(forGlyphRange: NSMakeRange(0, textStorage.length), in: textContainer)
        guard boundingRect.contains(point) else { return NSNotFound }
        
        let glyphIndex = layoutManager.glyphIndex(for: point, in: textContainer)
        return layoutManager.characterIndexForGlyph(at: glyphIndex)
    }
}
