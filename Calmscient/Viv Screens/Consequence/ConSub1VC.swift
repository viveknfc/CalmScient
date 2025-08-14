//
//  ConSub1VC.swift
//  CalmscientIOS
//
//  Created by NFC User on 04/12/24.
//

import UIKit

class ConSub1VC: ViewController {
    
    
    @IBOutlet weak var alertButton: UIButton!
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func alertButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
        if let customAlertVC = storyboard.instantiateViewController(withIdentifier: "AlertVC") as? AlertVC {
            customAlertVC.modalPresentationStyle = .overFullScreen
            customAlertVC.modalTransitionStyle = .crossDissolve
            self.present(customAlertVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func completButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
