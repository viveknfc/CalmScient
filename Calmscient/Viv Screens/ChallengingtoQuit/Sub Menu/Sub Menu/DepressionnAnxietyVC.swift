//
//  DepressionnAnxietyVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 12/03/25.
//

import UIKit

class DepressionnAnxietyVC: UIViewController {
    
    @IBOutlet weak var subContext7: FontLL15!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let context7text = """
If you're still not feeling great after a couple of weeks or if it's just too much, reach out to a healthcare provider.
You call 1-800-QUIT-NOW, you can speak confidentially with a highly trained quit coach.
"""
        
        subContext7.attributedText = TextHighlighter.getFormattedText(fullText: context7text, highlightTexts: ["1-800-QUIT-NOW"], highlightColor: UIColor(hex: "6E6BB3"))
        
        
    }
    
    @IBAction func closeButtonPreessed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
