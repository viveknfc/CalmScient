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
        
        let attributes: [NSAttributedString.Key: Any] = [
                       .paragraphStyle: paragraphStyle,
                       .font: UIFont(name: Fonts().lexendLight, size: 14) as Any // Match font if needed
                   ]
        
        alertBody.attributedText = NSAttributedString(string: text, attributes: attributes)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
