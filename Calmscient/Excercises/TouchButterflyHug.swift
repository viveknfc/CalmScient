//
//  TouchButterflyHug.swift
//  sample
//
//  Created by Krishna on 8/4/24.
//

import Foundation
import UIKit

class TouchButterflyHug: ViewController {
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    
    @IBOutlet weak var circle1: UIView!
    @IBOutlet weak var circle2: UIView!
    @IBOutlet weak var circle3: UIView!
    
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var view2title: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var view1Title: UILabel!
    
    
    @IBOutlet weak var verticalBar: UIView!
    
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    override func viewDidLoad() {
        
        subTitleLabel.font = UIFont(name: Fonts().lexendRegular, size: 19)
        
        view1Title.font  = UIFont(name: Fonts().lexendLight, size: 15)
        
        view2title.font = UIFont(name: Fonts().lexendLight, size: 15)
        
        descriptionLabel.font = UIFont(name: Fonts().lexendLight, size: 15)

        view1.applyShadow()
        view2.applyShadow()
        view3.applyShadow()
        
        verticalBar.backgroundColor = UIColor(hex: "#6E6BB3")
        
        circle1.layer.cornerRadius = circle1.frame.size.width / 2
        circle1.backgroundColor = UIColor(hex: "#6E6BB3")
        circle1.layer.masksToBounds = true
        
        circle2.layer.cornerRadius = circle2.frame.size.width / 2
        circle2.backgroundColor = UIColor(hex: "#6E6BB3")
        circle2.layer.masksToBounds = true
        
        circle3.layer.cornerRadius = circle3.frame.size.width / 2
        circle3.backgroundColor = UIColor(hex: "#6E6BB3")
        circle3.layer.masksToBounds = true
        
        completeButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14)
        
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
            self.navigationController?.popViewController(animated: true)
    
        }
    
    
    @IBAction func backButtonBottom(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = "Touch and the butterfly hug".localized
        setupLanguage()
    }
    
    func setupLanguage() {
        
subTitleLabel.text = AppHelper.getLocalizeString(str: "HOW TO DO IT")
        
        view1Title.text = AppHelper.getLocalizeString(str: "Interlock your thumbs to form a butterfly shape")
        
        view2title.text = AppHelper.getLocalizeString(str: "Place both hands over your chest, and alternate tapping your middle finger just below your collarbone")
        
        descriptionLabel.text = AppHelper.getLocalizeString(str: "Breathe slowly and deeply (abdominal breathing) while you mentally observe what is going through your mind and body thoughts, images, sounds, odors, feelings, and physical sensation.")
        
        }
    
    
    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
//        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func leftAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        let destinationVC = UIStoryboard(name: "Excercises", bundle: nil).instantiateViewController(withIdentifier: "Excercises") as! Excercises
                
                // Push to the destination view controller
                self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
}
