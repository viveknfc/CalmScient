//
//  ChangeCell.swift
//  CalmscientIOS
//
//  Created by mac on 19/06/24.
//

import Foundation
import UIKit

class ChangeCell: UITableViewCell {
    @IBOutlet weak var label: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let selectedLanguageID = UserDefaults.standard.integer(forKey: "SelectedLanguageID")

        if selectedLanguageID == 1 {
            setupLabel()
        }
        else{
            setupSpanishLabel()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    private func setupSpanishLabel() {
        let fullText = """
        ¿Pensando en un cambio?
        
        ¡Queremos que sepas que la decisión de reducir el consumo de alcohol/drogas es completamente tuya!
        
        Pero si te encuentras superando constantemente las pautas recomendadas para el consumo de alcohol, sería prudente considerar detener, reducir o disminuir tu consumo.
        Es normal tener sentimientos encontrados.
        
        ¿Has pensado en los pros y contras de hacerlo?
        """
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Default text color
        let defaultTextColor: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "AppLightTextColor") ?? UIColor.darkGray
        ]
        attributedString.addAttributes(defaultTextColor, range: NSRange(location: 0, length: attributedString.length))

        let hyperlinkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "AppThemeColor")!
        ]
        
        attributedString.addAttributes(hyperlinkAttributes, range: (fullText as NSString).range(of: "la decisión de reducir el consumo de alcohol/drogas es completamente tuya!"))
        attributedString.addAttributes(hyperlinkAttributes, range: (fullText as NSString).range(of: "detener, reducir o disminuir tu consumo."))
    //    attributedString.addAttributes(hyperlinkAttributes, range: (fullText as NSString).range(of: "pros y contras de hacerlo?"))
        
        label.attributedText = attributedString
        label.font = UIFont(name: Fonts().lexendRegular, size: 15)

    }

    private func setupLabel() {
        let fullText = """
        Thinking about a change?
        
        We want you to know that the decision to reduce alcohol/drug consumption is entirely yours!
        
        But If you find yourself consistently exceeding recommended guidelines for alcohol consumption, it would be wise to consider stopping, cutting down, or reducing your drinking.
        Mixed feelings are normal.
        
        Have you thought about the pros and cons of doing so?
        """
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Default text color
        let defaultTextColor: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "AppLightTextColor") ?? UIColor.darkGray
        ]
        attributedString.addAttributes(defaultTextColor, range: NSRange(location: 0, length: attributedString.length))

        
        let hyperlinkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "AppThemeColor")!
        ]
        
        attributedString.addAttributes(hyperlinkAttributes, range: (fullText as NSString).range(of: " the decision to reduce alcohol/drug consumption is entirely yours!"))
        attributedString.addAttributes(hyperlinkAttributes, range: (fullText as NSString).range(of: "stopping, cutting down, or reducing your drinking."))
//        attributedString.addAttributes(hyperlinkAttributes, range: (fullText as NSString).range(of: "pros and cons of doing so?"))
        
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
