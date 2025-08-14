//
//  DifficultyViewController.swift
//  CalmscientIOS
//
//  Created by NFC User on 22/02/25.
//

import UIKit

class DifficultyViewController: UIViewController {
    
    @IBOutlet weak var title1: FontLM16!
    @IBOutlet weak var subContext1: FontLL15!
    @IBOutlet weak var title2: FontLM16!
    @IBOutlet weak var subContext2: FontLL15!
    @IBOutlet weak var title3: FontLM16!
    @IBOutlet weak var subContext3: FontLL15!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
