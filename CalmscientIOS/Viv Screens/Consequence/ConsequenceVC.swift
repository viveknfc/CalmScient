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
        self.navigationController?.popViewController(animated: true)
    }
    

}
