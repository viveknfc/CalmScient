//
//  ConSub5VC.swift
//  CalmscientIOS
//
//  Created by NFC User on 05/12/24.
//

import UIKit

class ConSub5VC: ViewController {
    
    
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
