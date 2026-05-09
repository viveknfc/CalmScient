//
//  Consequences.swift
//  CalmscientIOS
//
//  Created by mac on 05/06/24.
//

import UIKit

@available(iOS 16.0, *)
class Consequences:  ViewController {
    @IBOutlet weak var selection_view: UIImageView!

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var normalTextLabel: UILabel!
    @IBOutlet weak var hyperTextLabel: UITextView!
    var sectionID5: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        //self.navigationController?.isNavigationBarHidden = true
       // self.navigationController?.navigationBar.isHidden = false
        
     //   let backButton = UIBarButtonItem(image: UIImage(named: "backward"), style: .plain, target: self, action: #selector(backButtonOverrideAction))

      //  backButton.tintColor = UIColor.clear

           // Assign it to the navigation item's leftBarButtonItem
        
        //   self.navigationItem.leftBarButtonItem = backButton
        
        
        //nav bar back button start
        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)

        // Create a UIButton
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonOverrideAction), for: .touchUpInside)

        // Set constraints to adjust the size
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true // Set desired width
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true // Set desired height

        // Create a UIBarButtonItem using the UIButton
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        //end

    }
    @objc func backButtonOverrideAction() {
        print("Back button tapped")
        // Perform the action you want here
        let next = UIStoryboard(name: "Basicknowledge", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "Basicknowledge") as? Basicknowledge
        vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @IBAction func forward_action(_ sender: UIButton) {
        let next = UIStoryboard(name: "Consequences", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "Consequences_two") as? Consequences_two
                   vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        vc?.sectionID55 = sectionID5
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
    }
    
    
    func setupLanguage() {
        
self.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        
        headerLabel.text = AppHelper.getLocalizeString(str: "What are the consequence?")
        normalTextLabel.text = AppHelper.getLocalizeString(str:"typesOfconsequence" )
        normalTextLabel.textColor = UIColor(named: "424242Color")
        
        }
}

