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
    
    let eitems = [
        "Do something to stay active at home",
        "Call or visit a friend or family member",
        "Brush your teeth",
        "Play with a pet",
        "Update your contact list on your cell phone",
        "Try a new hobby",
        "Switch to coffee with less caffeine or decaf products"
    ]

    let sitems = [
        "Haz algo para mantenerte activo en casa",
        "Llama o visita a un amigo o familiar",
        "Cepíllate los dientes",
        "Juega con una mascota",
        "Update your contact list on your cell phone",
        "Prueba un nuevo pasatiempo",
        "Cambia a café con menos cafeína o productos descafeinados"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? eitems : sitems
        
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
        let selectedLanguageID = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        let title = selectedLanguageID == 1 ? "Complete" : "Finalizar"
        completeButton.setTitle(title, for: .normal)
        completeButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14)
        
        
    }
    
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
