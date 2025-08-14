//
//  FeelingJumpyVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 12/03/25.
//

import UIKit

class FeelingJumpyVC: UIViewController {
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var circle1: UIView!
    
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var circle2: UIView!
    
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var circle3: UIView!
    
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var circle4: UIView!
    
    @IBOutlet weak var view5: UIView!
    @IBOutlet weak var circle5: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Apply styling
        [view1, view2, view3, view4, view5].forEach { $0?.applyShadow() }
        [circle1, circle2, circle3, circle4, circle5].forEach { $0?.makeCircle(with: UIColor(hex: "#6E6BB3")) }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    


}
