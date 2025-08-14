//
//  ComingSoonVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 03/12/24.
//

import UIKit

class ComingSoonVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.isHidden = false
        if #available(iOS 16.0, *) {
            self.navigationController?.navigationItem.leftBarButtonItem?.isHidden = false
        } else {
            // Fallback on earlier versions
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    


}
