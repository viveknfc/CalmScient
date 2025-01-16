//
//  ThinkingAbtQuitingVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 02/01/25.
//

import UIKit

class ThinkingAbtQuitingVC: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func CompleteButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
