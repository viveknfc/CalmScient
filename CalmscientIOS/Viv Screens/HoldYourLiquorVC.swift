//
//  HoldYourLiquorVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 10/12/24.
//

import UIKit

class HoldYourLiquorVC: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
