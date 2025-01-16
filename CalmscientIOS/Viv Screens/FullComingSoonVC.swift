//
//  FullComingSoonVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 18/12/24.
//

import UIKit

class FullComingSoonVC: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
