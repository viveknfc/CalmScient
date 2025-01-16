//
//  USGuideLineForDrinkingVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 03/12/24.
//

import UIKit

class USGuideLineForDrinkingVC: ViewController {
    
    
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
