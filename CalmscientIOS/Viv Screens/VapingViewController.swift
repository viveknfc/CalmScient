//
//  VapingViewController.swift
//  CalmscientIOS
//
//  Created by NFC User on 27/12/24.
//

import UIKit

class VapingViewController: ViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func urlButtonPressed(_ sender: Any) {
    }
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
