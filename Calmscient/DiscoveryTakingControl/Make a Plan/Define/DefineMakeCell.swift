//
//  DefineMakeCell.swift
//  CalmscientIOS
//
//  Created by mac on 25/06/24.
//

import Foundation
import Foundation
import UIKit

class DefineMakeCell: UITableViewCell {
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
    
    
    private func setupLabel() {
        let fullText = """
        First of all, let's define what is the best for you.

        If you're considering changing your drinking, you'll need to decide whether to cut down or quit. It's a good idea to discuss different options with a healthcare professional, a friend, or someone else you trust.

        Please note, when someone who has been drinking heavily for a prolonged period of time suddenly stops drinking, the body can go into a painful or even potentially life-threatening process of withdrawal.

        Symptoms can include nausea, rapid heart rate, seizures, or other problems. Seek medical help to plan a safe recovery. Doctors can prescribe medications to address these symptoms and make the process safer and less distressing.
        """
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        let defaultTextColor: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "AppLightTextColor") ?? UIColor.darkGray
        ]
        attributedString.addAttributes(defaultTextColor, range: NSRange(location: 0, length: attributedString.length))
        
        let hyperlinkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "AppThemeColor")!
        ]
        
        attributedString.addAttributes(hyperlinkAttributes, range: (fullText as NSString).range(of: " a painful or even potentially life-threatening process of withdrawal."))
        attributedString.addAttributes(hyperlinkAttributes, range: (fullText as NSString).range(of: "nausea, rapid heart rate, seizures, or other problems."))
//        attributedString.addAttributes(hyperlinkAttributes, range: (fullText as NSString).range(of: "pros and cons of doing so?"))
        
        label.attributedText = attributedString
        label.font = UIFont(name: Fonts().lexendRegular, size: 15)

    }
    
    private func setupSpanishLabel() {
        let fullText = """
        En primer lugar, definamos qué es lo mejor para ti.

        Si estás considerando cambiar tu forma de beber, tendrás que decidir si reducir o dejar de beber. Es una buena idea hablar sobre las diferentes opciones con un profesional de la salud, un amigo o alguien en quien confíes.

        Ten en cuenta que, cuando una persona que ha estado bebiendo en exceso durante un período prolongado deja de beber repentinamente, su cuerpo puede entrar en un proceso de abstinencia doloroso o incluso potencialmente mortal.

        Los síntomas pueden incluir náuseas, ritmo cardíaco acelerado, convulsiones u otros problemas. Busca ayuda médica para planificar una recuperación segura. Los médicos pueden recetar medicamentos para tratar estos síntomas y hacer que el proceso sea más seguro y menos angustiante.
        """
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        let defaultTextColor: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "AppLightTextColor") ?? UIColor.darkGray
        ]
        attributedString.addAttributes(defaultTextColor, range: NSRange(location: 0, length: attributedString.length))
        
        let hyperlinkAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "AppThemeColor")!
        ]
        
        attributedString.addAttributes(hyperlinkAttributes, range: (fullText as NSString).range(of: "un proceso de abstinencia doloroso o incluso potencialmente mortal."))
        attributedString.addAttributes(hyperlinkAttributes, range: (fullText as NSString).range(of: "náuseas, ritmo cardíaco acelerado, convulsiones u otros problemas."))
    //    attributedString.addAttributes(hyperlinkAttributes, range: (fullText as NSString).range(of: "pros y contras de hacerlo?"))
        
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
