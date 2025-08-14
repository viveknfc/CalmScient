//
//  ConsequenceVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 04/12/24.
//

import UIKit

class ConsequenceVC: ViewController {
    
    @IBOutlet weak var Button1: CurvedOutlineButton!
    @IBOutlet weak var Button2: CurvedOutlineButton!
    @IBOutlet weak var Button3: CurvedOutlineButton!
    @IBOutlet weak var button4: CurvedOutlineButton!
    @IBOutlet weak var button5: CurvedOutlineButton!
    
    @IBOutlet weak var completButton: CapsuleButton1!
    
    var sectionID5: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func button1Pressed(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "" // Set an empty string for the back button
        self.navigationItem.backBarButtonItem = backItem
        
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "ConSub1VC") as? ConSub1VC
        vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @IBAction func button2Pressed(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "" // Set an empty string for the back button
        self.navigationItem.backBarButtonItem = backItem
        
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "ConSub2VC") as? ConSub2VC
        vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @IBAction func button3Pressed(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "" // Set an empty string for the back button
        self.navigationItem.backBarButtonItem = backItem
        
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "ConSub3VC") as? ConSub3VC
        vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func button4Pressed(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "" // Set an empty string for the back button
        self.navigationItem.backBarButtonItem = backItem
        
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "ConSub4VC") as? ConSub4VC
        vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @IBAction func button5Pressed(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "" // Set an empty string for the back button
        self.navigationItem.backBarButtonItem = backItem
        
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "ConSub5VC") as? ConSub5VC
        vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    
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
            "sectionId":sectionID5 ?? 0
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
