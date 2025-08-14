//
//  AlertVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 04/12/24.
//

import UIKit

class AlertVC: UIViewController {
    
    @IBOutlet weak var alertBody: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        alertBody.font = UIFont(name: Fonts().lexendLight, size: 14)
        alertBody.isEditable = false
        let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
        
        let text = "Above 1.5 million people are arrested each year for driving under the influence of alcohol or drugs. DUI citations typically remain on your criminal record for many years, leading to higher insurance rates, difficulty in securing employment, and many other problems. Can you imagine the long-term negative consequences on your life and the stress it could cause? If someone has more than two DUIs, it doesn’t matter if they occur within days or over a ten-year period. They will be regarded as compounding offenses, resulting in increased penalties and possible imprisonment."
        
        let stext = "Aproximadamente 1.5 millones de personas son arrestadas cada año por conducir bajo los efectos del alcohol o las drogas. Las citaciones por conducir bajo la influencia (DUI, por sus siglas en inglés) generalmente permanecen en tu historial criminal durante muchos años, lo que conlleva tasas de seguro más altas, dificultades para conseguir empleo y muchos otros problemas. ¿Puedes imaginar las consecuencias negativas a largo plazo en tu vida y el estrés que podría causar? Si alguien tiene más de dos DUI, no importa si ocurren dentro de días o en un período de diez años. Serán consideradas como infracciones acumulativas, lo que resultará en penas más severas y posible encarcelamiento."
        
        let attributes: [NSAttributedString.Key: Any] = [
                       .paragraphStyle: paragraphStyle,
                       .font: UIFont(name: Fonts().lexendLight, size: 14) as Any // Match font if needed
                   ]
        
        let selectedLanguageID = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        print("the selecteed langauge is", selectedLanguageID)
        let bodyText = selectedLanguageID == 1 ? text : stext
        
//        alertBody.attributedText = NSAttributedString(string: text, attributes: attributes)
        alertBody.attributedText = NSAttributedString(string: bodyText, attributes: attributes)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
