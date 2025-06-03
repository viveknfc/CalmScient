//
//  TakingIntroLastVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 12/05/25.
//

import UIKit

class TakingIntroLastVC: ViewController {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: FontLL14!
    @IBOutlet weak var label3: FontLL14!
    @IBOutlet weak var label4: FontLL14!
    @IBOutlet weak var label5: FontLL14!
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    let Text2 = AppHelper.getLocalizeString(str: "text2")
    let Text3 = AppHelper.getLocalizeString(str: "text3")
    let Text4 = AppHelper.getLocalizeString(str: "text4")
    let Text5 = AppHelper.getLocalizeString(str: "text5")

    override func viewDidLoad() {
        super.viewDidLoad()

        title = AppHelper.getLocalizeString(str: "Taking control introduction")
        
        let headingFont = UIFont(name: Fonts().lexendMedium, size: 16)!
        let bodyFont = UIFont(name: Fonts().lexendLight, size: 14)!

        let fullText = NSLocalizedString("thank_you_message", comment: "")
        let attributedText = NSMutableAttributedString(string: fullText, attributes: [.font: bodyFont])

        let heading1 = NSLocalizedString("thank_you_heading", comment: "Heading to bold")

        if let range1 = fullText.range(of: heading1) {
            let nsRange1 = NSRange(range1, in: fullText)
            attributedText.addAttribute(.font, value: headingFont, range: nsRange1)
        }

        label1.attributedText = attributedText
        
        styleButton(button1)
        styleButton(button2)
        styleButton(button3)
        
        label2.text = Text2
        label3.text = Text3
        label4.text = Text4
        label5.text = Text5
        
        button4.setImage(UIImage(named: "uncheck_img"), for: .normal)
        button4.setImage(UIImage(named: "checkbox"), for: .selected)

    }
    
    
    @IBAction func drinkingciachButtonPressed(_ sender: Any) {
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "TakingControlIndex") as? TakingControlIndex
        vc?.title = AppHelper.getLocalizeString(str: "Taking control")
        vc?.initialSegmentIndex = 0
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func pcpButtonPressed(_ sender: Any) {
    }
    
    
    @IBAction func smokingButton(_ sender: Any) {
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "TakingControlIndex") as? TakingControlIndex
        vc?.title = AppHelper.getLocalizeString(str: "Taking control")
        vc?.initialSegmentIndex = 1
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @IBAction func checkBoxPressed(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        if sender.isSelected {
            saveTakingControlIntroAPICalling()
        }
        
    }
    
    
    @IBAction func backbuttonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    private func styleButton(_ button: UIButton) {
        button.backgroundColor = .white
        button.setTitleColor(UIColor(red: 99/255, green: 107/255, blue: 179/255, alpha: 1), for: .normal)

        button.applyShadow(
            cornerRadius: 8,
            shadowColor: .black,
            shadowOpacity: 0.3,
            shadowOffset: CGSize(width: 0, height: 1),
            shadowRadius: 2
        )
    }
    
    //MARK: - Save Taking Control Intro Data API Calling
    
    func saveTakingControlIntroAPICalling() {
        self.view.showToastActivity()
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Any] = [
            "clientId": userInfo.clientID,
            "patientId": userInfo.patientID,
            "plId": userInfo.patientLocationID,
            "introductionFlag": NSNull(),
            "auditFlag": NSNull(),
            "dastFlag": NSNull(),
            "cageFlag": NSNull(),
            "tutorialFlag": 0
        ]
        
        print("param for saveTakingControlIntroAPICalling while check box is, ", params)

        APIService.saveTakingControlIntroAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            self.getresponseforDontShowTakingControlIntroAPI(response: response)
        }
    }
    
    //MARK: - Save Taking Control Intro Data API Response
    
    func getresponseforDontShowTakingControlIntroAPI(response: Any) {
        self.view.hideToastActivity()
        
        if let responseDict = response as? [String: Any],
           let statusResponse = responseDict["statusResponse"] as? [String: Any],
           let responseMessage = statusResponse["responseMessage"] as? String {

            // ✅ Show success alert with extracted message
//            self.showSuccessAlert(successContent: responseMessage, centreImage: nil, okButtonAction: {
//
//            })

        } else {
            print("Invalid response format or missing keys.")
        }
    }

    //END

}
