//
//  TryingToQuitVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 02/01/25.
//

import UIKit

class TryingToQuitVC: ViewController {
    
    @IBOutlet weak var bulletinLabels: FontLL15!
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    let bullet = "•  " // Bullet with spacing
    
    var items: [String] = []
    
    static let localizedItems = [
        "Do something to stay active at home".localized,
        "Call or visit a friend or family member".localized,
        "Brush your teeth".localized,
        "Play with a pet".localized,
        "Update your contact list on your cell phone".localized,
        "Try a new hobby".localized,
        "Switch to coffee with less caffeine or decaf products".localized
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = Self.localizedItems
        
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
        completeButton.setTitle("Complete".localized, for: .normal)
        completeButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14)
        
        
    }
    
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
