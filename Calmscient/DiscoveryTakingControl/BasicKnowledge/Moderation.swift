//
//  USGuidlines.swift
//  CalmscientIOS
//
//  Created by mac on 02/06/24.
//

import Foundation
import UIKit

class Moderation: ViewController {

    @IBOutlet weak var headerLabel: FontLM16!
    @IBOutlet weak var normalTextLabel: UILabel!
    @IBOutlet weak var hyperTextLabel: UITextView!
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    var sectionID3: Int?
    
    private var primaryReasonsArr: [String] {
        [
            AppHelper.getLocalizeString(str: "moderation_primary_reason_1"),
            AppHelper.getLocalizeString(str: "moderation_primary_reason_2"),
            AppHelper.getLocalizeString(str: "moderation_primary_reason_3"),
            AppHelper.getLocalizeString(str: "moderation_primary_reason_4"),
            AppHelper.getLocalizeString(str: "moderation_primary_reason_5")
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
       // setupLanguage()
        self.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        headerLabel.text = AppHelper.getLocalizeString(str: "When is drinking in moderation still too much?")
        fontConfigaration()
        completeButton.updateTitleForLanguage()
    }
    
    func fontConfigaration(){
        self.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
//        headerLabel.font = UIFont(name: Fonts().lexendLight, size: 15)!
        let someAdditionalInfo = NSMutableAttributedString(string: AppHelper.getLocalizeString(str: "moderation_intro_text"))
        someAdditionalInfo.addAttribute(.font, value: UIFont(name: Fonts().lexendLight, size: 16)!, range: NSRange(location: 0, length: someAdditionalInfo.length))
        someAdditionalInfo.addAttribute(.foregroundColor, value: UIColor(named: "424242Color")!, range: NSRange(location: 0, length: someAdditionalInfo.length))

        let primaryReasons = add(stringList: primaryReasonsArr, font: UIFont(name: Fonts().lexendLight, size: 16)!)
        
        primaryReasons.addAttribute(.foregroundColor, value: UIColor(named: "424242Color")!, range: NSRange(location: 0, length: primaryReasons.length))
        
        let fullText = AppHelper.getLocalizeString(str: "moderation_full_text")
        let targetStrings = [
            AppHelper.getLocalizeString(str: "moderation_target_women"),
            AppHelper.getLocalizeString(str: "moderation_target_men")
        ]
        

                // Create a mutable attributed string
                let attributedText =  NSMutableAttributedString(string: fullText)
        
        // Define the font and size
               let font = UIFont(name: Fonts().lexendLight, size: 16)!
               
               // Set the entire text to green color with the desired font and size
               let fullRange = NSRange(location: 0, length: attributedText.length)
               attributedText.addAttributes([
                   .foregroundColor: UIColor.green,
                   .font: font
               ], range: fullRange)
        
                let fullRange1 = NSRange(location: 0, length: attributedText.length)
                attributedText.addAttribute(.foregroundColor, value: UIColor(named: "blackAndWhite") as Any, range: fullRange1)
        
        for target in targetStrings {
            let range = (fullText as NSString).range(of: target)
            if range.location != NSNotFound {
                attributedText.addAttribute(.foregroundColor, value: UIColor(named: "CustomAlertTitleColor") as Any, range: range)
            }
        }

        let combinedAttributedString = NSMutableAttributedString()
        combinedAttributedString.append(someAdditionalInfo)
        combinedAttributedString.append(primaryReasons)
        combinedAttributedString.append(attributedText)
        
                // Assign the attributed string to the text view
        hyperTextLabel.attributedText = combinedAttributedString
        
    }
    
    
    func setupLanguage() {
        
headerLabel.text = AppHelper.getLocalizeString(str: "What’s a standard drink")
        
        normalTextLabel.text = AppHelper.getLocalizeString(str: "According to the 2020-2025 Dietary Guidelines for Americans, certain individuals should not consume alcohol. It’s safest to void alcohol altogether if you are: Taking medications that interact with alcohol Managing a medical condition that can be made Worse by drinking Under the age of 21, the minimum legal drinking age in the United States Recovering from alcohol use disorder (AUD) or unable to control the amount you drink Pregnant or might be pregnant In addition, certain individuals, particularly older adults, who are planning to drive a vehicle or operate machinery-or who are participating in activities that require skill, coordination, and alertness-should avoid alcohol completely.")
        hyperTextLabel.text = AppHelper.getLocalizeString(str: "Lorem ipsum dolor sit er elit lamet, consectetaur cillium adipisicing pecu, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Nam liber te conscient to factor tum poen legum odioque civiuda.")
        }    
    
    func add(stringList: [String],
             font: UIFont,
             bullet: String = "  \u{2022}",
             indentation: CGFloat = 20,
             lineSpacing: CGFloat = 2,
             paragraphSpacing: CGFloat = 12,
             textColor: UIColor = UIColor(hex: "#424242"),
             bulletColor: UIColor = .black) -> NSMutableAttributedString {

        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
        let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: bulletColor]

        let paragraphStyle = NSMutableParagraphStyle()
        let nonOptions = [NSTextTab.OptionKey: Any]()
        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
        paragraphStyle.defaultTabInterval = indentation
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.headIndent = indentation

        let bulletList = NSMutableAttributedString()
        for (index,string) in stringList.enumerated() {
            let formattedString = "\(bullet)\t\(string)\n"
            let attributedString = NSMutableAttributedString(string: formattedString)

            attributedString.addAttributes(
                [NSAttributedString.Key.paragraphStyle : paragraphStyle],
                range: NSMakeRange(0, attributedString.length))

            attributedString.addAttributes(
                textAttributes,
                range: NSMakeRange(0, attributedString.length))

            let string:NSString = NSString(string: formattedString)
            let rangeForBullet:NSRange = string.range(of: bullet)
            attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
            bulletList.append(attributedString)
        }

        return bulletList
    }
    
    //MARK: - Complete Button Pressed
    
    @IBAction func completeButtonPressed(_ sender: Any) {
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
            "sectionId":sectionID3 ?? 0
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
            self.navigationController?.popViewController(animated: true)
            
        } else {
            print("Unsupported response type:", type(of: response))
        }
    }
    
    
}

