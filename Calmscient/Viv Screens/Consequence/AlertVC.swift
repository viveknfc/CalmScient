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
        
        let attributes: [NSAttributedString.Key: Any] = [
                       .paragraphStyle: paragraphStyle,
                       .font: UIFont(name: Fonts().lexendLight, size: 14) as Any // Match font if needed
                   ]
        let bodyText = AppHelper.getLocalizeString(str: "DRINKING_CONTROL_ALERT_DUI_BODY")
        
//        alertBody.attributedText = NSAttributedString(string: text, attributes: attributes)
        alertBody.attributedText = NSAttributedString(string: bodyText, attributes: attributes)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
