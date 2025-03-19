//
//  TryingToQuitVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 02/01/25.
//

import UIKit

class TryingToQuitVC: ViewController {
    
    @IBOutlet weak var bulletinLabels: FontLL15!
    
    let bullet = "•  " // Bullet with spacing
    let items = [
        "Do something to stay active at home",
        "Call or visit a friend or family member",
        "Brush your teeth",
        "Play with a pet",
        "Update your contact list on your cell phone",
        "Try a new hobby",
        "Switch to coffee with less caffeine or decaf products"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0 // First line starts normally
        paragraphStyle.headIndent = 15 // Indents second and subsequent lines
        paragraphStyle.lineBreakMode = .byWordWrapping

        let bulletList = items.map { bullet + $0 }.joined(separator: "\n") // Combine bullet points

        let attributedString = NSAttributedString(
            string: bulletList,
            attributes: [
                .paragraphStyle: paragraphStyle
            ]
        )

        bulletinLabels.numberOfLines = 0 // Ensure multi-line support
        bulletinLabels.attributedText = attributedString

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
