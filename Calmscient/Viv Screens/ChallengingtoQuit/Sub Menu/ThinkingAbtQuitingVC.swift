//
//  ThinkingAbtQuitingVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 02/01/25.
//

import UIKit

class ThinkingAbtQuitingVC: ViewController {
    
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let selectedLanguageID = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        let title = selectedLanguageID == 1 ? "Complete" : "Finalizar"
        completeButton.setTitle(title, for: .normal)
        completeButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14)
    }

    @IBAction func CompleteButtonPressed(_ sender: Any) {
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    
}
