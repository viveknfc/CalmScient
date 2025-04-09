//
//  InfoButtonVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 09/04/25.
//

import UIKit

class InfoButtonVC: UIViewController {
    
    @IBOutlet weak var containerView1: UIView!
    @IBOutlet weak var containerView2: UIView!
    @IBOutlet weak var containerView3: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        [containerView1, containerView2, containerView3].forEach { $0?.applyShadow() }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
