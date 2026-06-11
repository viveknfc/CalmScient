//
//  BreathingTechnique.swift
//  sample
//
//  Created by Krishna on 8/6/24.
//

import Foundation
import UIKit

class BreathingTechnique: ViewController {
        
    @IBOutlet weak var breathingExcercise478: UIView!
    @IBOutlet weak var mindfulBreathingExcercise478: UIView!
    @IBOutlet weak var diaphragmaticBreathing: UIView!
    
    
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var excersice1Label: UILabel!
    
    @IBOutlet weak var excersice2Label: UILabel!
    
    @IBOutlet weak var excersice3Label: UILabel!
    
    
    override func viewDidLoad() {
        
        let breathe = UITapGestureRecognizer(target: self, action: #selector(bottomBackTapped(tapGestureRecognizer:)))
        
        let mindfulBreathe = UITapGestureRecognizer(target: self, action: #selector(mindfulTapped(tapGestureRecognizer:)))
        
        let diagraphicBreathe = UITapGestureRecognizer(target: self, action: #selector(diaphragmaticTapped(tapGestureRecognizer:)))
        
        breathingExcercise478.isUserInteractionEnabled = true
        breathingExcercise478.addGestureRecognizer(breathe)
        
        mindfulBreathingExcercise478.isUserInteractionEnabled = true
        mindfulBreathingExcercise478.addGestureRecognizer(mindfulBreathe)
        
        
        diaphragmaticBreathing.isUserInteractionEnabled = true
        diaphragmaticBreathing.addGestureRecognizer(diagraphicBreathe)

        setFonts()
        setupLanguage()
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        title = "Breathing technique".localized
        setupLanguage()
        breathingExcercise478.applyShadow(shadowColor: (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as! Bool ? .white : .black,shadowOpacity: (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as! Bool ? 0.4 : 0.2)
        mindfulBreathingExcercise478.applyShadow(shadowColor: (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as! Bool ? .white : .black,shadowOpacity: (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as! Bool ? 0.4 : 0.2)
        diaphragmaticBreathing.applyShadow(shadowColor: (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as! Bool ? .white : .black,shadowOpacity: (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as! Bool ? 0.4 : 0.2)
    }
    
    
    func setupLanguage() {
        
subTitleLabel.text = AppHelper.getLocalizeString(str:"Breathing exercises")
        excersice1Label.text = AppHelper.getLocalizeString(str: "4-7-8 Breathing exercise")
        excersice2Label.text = AppHelper.getLocalizeString(str: "Mindful breathing exercise")
        excersice3Label.text = AppHelper.getLocalizeString(str: "Diaphragmatic breathing exercise")
        
        
        }
    
    func setFonts(){
        self.subTitleLabel.font = UIFont(name: Fonts().lexendMedium, size: 18)
        self.excersice1Label.font = UIFont(name: Fonts().lexendLight, size: 15)
        self.excersice2Label.font = UIFont(name: Fonts().lexendLight, size: 15)
        self.excersice3Label.font = UIFont(name: Fonts().lexendLight, size: 15)
    }
    
    @objc func bottomBackTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if #available(iOS 16.0, *) {
            BreathingTechniqueType1Navigation.push(from: self)
        } else {
            let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "BreathingTechniqueType1") as! BreathingTechniqueType1
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    
    @objc func mindfulTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if #available(iOS 16.0, *) {
            MindfulBreathingNavigation.push(from: self)
        } else {
            let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "MindfulBreathing") as! MindfulBreathing
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
    
    @objc func diaphragmaticTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if #available(iOS 16.0, *) {
            DiaphragmaticBreathingNavigation.push(from: self)
        } else {
            let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
            let destinationVC = storyboard.instantiateViewController(withIdentifier: "DiagraphicBreathe") as! DiagraphicBreathe
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
}
