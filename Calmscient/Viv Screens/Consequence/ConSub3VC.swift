//
//  ConSub3VC.swift
//  CalmscientIOS
//
//  Created by NFC User on 05/12/24.
//

import UIKit

class ConSub3VC: ViewController {
    
    
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    

}
