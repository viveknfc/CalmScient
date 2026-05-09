//
//  ConSub4VC.swift
//  CalmscientIOS
//
//  Created by NFC User on 05/12/24.
//

import UIKit

class ConSub4VC: ViewController {
    
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    var details: [String] = []
    
    let detailsKeys = [
        "DRINKING_CONTROL_Consequence_Four_Message_One",
        "DRINKING_CONTROL_Consequence_Four_Message_Two",
        "DRINKING_CONTROL_Consequence_Four_Message_Three",
        "DRINKING_CONTROL_Consequence_Four_Message_Four",
        "DRINKING_CONTROL_Consequence_Four_Message_Five",
        "DRINKING_CONTROL_Consequence_Four_Message_Six"
    ]

    
    @IBOutlet weak var bulletPointsLabel: FontLL15!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        details = detailsKeys.map { AppHelper.getLocalizeString(str: $0) }

        // Create the bullet point text with proper indentation for wrapped lines
        let bulletPointText = details.map { "•  \($0)" }.joined(separator: "\n")

        // Create an NSMutableAttributedString
        let attributedString = NSMutableAttributedString(string: bulletPointText)

        // Define paragraph style to control line breaks and indentation
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.paragraphSpacing = 3
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.headIndent = 16  // Indentation for wrapped lines
        paragraphStyle.alignment = .left

        // Apply the paragraph style to the entire text
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        
        
        bulletPointsLabel.attributedText = attributedString
    }
    

    @IBAction func completeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
