//
//  introductionTakingPage.swift
//  CalmscientIOS
//
//  Created by mac on 28/05/24.
//

import Foundation
import UIKit
@available(iOS 16.0, *)
class IntroductionPageController: ViewController {
    
    var tutorialFlag : Int?

    @IBOutlet weak var drinkcoach: UIButton!
    @IBOutlet weak var checkbox: UIButton!
    @IBOutlet weak var substainCoach: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var checkBoxLabel: UILabel!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // Set the initial state of the checkbox
           
            setupCustomButton()

        }
    
    func updateCheckboxAppearance() {
        let imageName = (tutorialFlag == 1) ? "checkbox" : "uncheck_img"
        checkbox.setImage(UIImage(named: imageName), for: .normal)
    }
    
    func setupCustomButton() {
        drinkcoach.applyShadow()
        drinkcoach.layer.borderWidth = 0.5
        drinkcoach.layer.borderColor = UIColor.lightGray.cgColor
        drinkcoach.layer.masksToBounds = false

        substainCoach.applyShadow()
        substainCoach.layer.borderWidth = 0.5
        substainCoach.layer.borderColor = UIColor.lightGray.cgColor
        substainCoach.layer.cornerRadius = 10.0
        }
    
    @IBAction func checkTapped(_ sender: UIButton) {
        
        if tutorialFlag == 1 {
            tutorialFlag = 0
        } else {
            tutorialFlag = 1
        }
        
        // Update the checkbox appearance based on the new value of tutorialFlag
        updateCheckboxAppearance()
        saveTakingControlIntroAPICalling()

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
            "tutorialFlag": tutorialFlag as Any
        ]
        
        print("param for saveTakingControlIntroAPICalling while check box is, ", params)

        APIService.saveTakingControlIntroAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            self.getresponseforSaveTakingControlIntroAPI(response: response)
        }
    }
    
    //MARK: - Save Taking Control Intro Data API Response
    
    func getresponseforSaveTakingControlIntroAPI(response: Any) {
        self.view.hideToastActivity()
        
        if let responseDict = response as? [String: Any] {
            print("Response from Get Taking Control Intro Data:", responseDict)

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                let decodedResponse = try JSONDecoder().decode(IntroductionResponse.self, from: jsonData)

                print("the decoded response is ",decodedResponse)
                // 👉 You can now use these flags however you want (e.g. update UI)

            } catch {
                print("Decoding failed with error:", error)
            }

        } else {
            print("Unsupported response type:", type(of: response))
        }
    }

    //END
    
    
    @available(iOS 16.0, *)
    @IBAction func drinkCoachTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "TakingControlIndex") as? TakingControlIndex {
            vc.title = AppHelper.getLocalizeString(str: "Taking control")
            vc.initialSegmentIndex = 0 // Drinking
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func smokingTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "TakingControlIndex") as? TakingControlIndex {
            vc.title = AppHelper.getLocalizeString(str: "Taking control")
            vc.initialSegmentIndex = 1 // Smoking
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
