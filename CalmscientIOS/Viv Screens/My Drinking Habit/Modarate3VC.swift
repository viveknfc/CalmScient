//
//  Modarate3VC.swift
//  CalmscientIOS
//
//  Created by NFC User on 13/12/24.
//

import UIKit

class Modarate3VC: ViewController {
    
    @IBOutlet weak var makeAPlan: FontLL15!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let fullText = "In the Make a Plan section, we’ll guide you through practical strategies to help you make these changes. You’ve got this!"
        let highlightedText = "Make a Plan"
                
        // Create attributed string
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Define attributes for the highlighted text
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: #colorLiteral(red: 0.429181397, green: 0.4192816615, blue: 0.7016126513, alpha: 1) ,
            .font: UIFont(name: Fonts().lexendLight, size: 16)!
        ]
        
        // Find the range of the text to highlight
        if let range = fullText.range(of: highlightedText) {
            let nsRange = NSRange(range, in: fullText)
            attributedString.addAttributes(attributes, range: nsRange)
        }
        
        // Assign attributed text to the label
        makeAPlan.attributedText = attributedString
    }
    

    @IBAction func completeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
