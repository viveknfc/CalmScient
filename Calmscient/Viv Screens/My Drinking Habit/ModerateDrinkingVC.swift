//
//  ModerateDrinkingVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 13/12/24.
//

import UIKit

class ModerateDrinkingVC: ViewController {
    
    
    @IBOutlet weak var feelFreeLabel: FontLL15!
    var sectionID: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fullText = "Feel free to use My progress section to track your drinking habit if you'd like to."
        let highlightedText = "My progress"
                
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
        feelFreeLabel.attributedText = attributedString

        // Do any additional setup after loading the view.
    }

    @IBAction func completeButtonPressed(_ sender: Any) {
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
        completeButtonAPICall()
    }
    
    //MARK: - Complete Button API Call
    
    func completeButtonAPICall() {
        self.view.showToastActivity()
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Any] = [
            "isCompleted":1,
            "patientId": userInfo.patientID,
            "sectionId":sectionID ?? 0
        ]

        APIService.DUpdateBasicKAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            self.getresponseforBasicKnowAPI(response: response)
        }
    }
    
    //MARK: - Complete Button API Response
    
    func getresponseforBasicKnowAPI(response: Any) {
        self.view.hideToastActivity()
        
        if let responseDict = response as? [String: Any] {
            
            print("Response from Basic standard complete button:", responseDict)
            let next = UIStoryboard(name: "Basicknowledge", bundle: nil)
            if #available(iOS 16.0, *) {
                let vc = next.instantiateViewController(withIdentifier: "Basicknowledge") as? Basicknowledge
                vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
                self.navigationController?.pushViewController(vc!, animated: true)
            } else {
                // Fallback on earlier versions
            }
            
        } else {
            print("Unsupported response type:", type(of: response))
        }
    }
    
}
