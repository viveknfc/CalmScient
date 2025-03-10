//
//  Consequences_two.swift
//  CalmscientIOS
//
//  Created by mac on 05/06/24.
//

import Foundation
import UIKit

@available(iOS 16.0, *)
class Consequences_two:  ViewController {
    @IBOutlet weak var selection_view: UIImageView!
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var normalTextLabel: UILabel!
    @IBOutlet weak var hyperTextLabel: UITextView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var pointsTxt: UILabel!
    var sectionID55: Int?
    
    let arrayString = [AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Thirty_percent_Of_Suicides"),
                       AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Forty_Of_Fatal_Burn_Injuries"),
                       AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Fifty_Of_Fatal_Drownings_And_Of_Homicides_And_About_Message"),
                       AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Thirtyone_Percent_Fatal_Crashes"),
                       AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Significant_Number_Of_Sexual_Assaults")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
    }
    
    func setupLanguage() {
        
        let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        
        if languageId == 1 {
            UserDefaults.standard.set("en", forKey: "Language")
            
            
        } else if languageId == 2 {
            UserDefaults.standard.set("es", forKey: "Language")
            
            
        }
        self.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        
        headerLabel.text = AppHelper.getLocalizeString(str: "What are the consequence?")
        titleLbl.text = AppHelper.getLocalizeString(str: "Fatalities and injuries")
        normalTextLabel.text = AppHelper.getLocalizeString(str:
                                                            "Alcohol-related deaths are increasing in the United States.\n\nAlcohol is a factor in:"
        )
        normalTextLabel.textColor = UIColor(named:"424242Color" )
        
        pointsTxt.attributedText = add(stringList: arrayString, font: pointsTxt.font, bullet: "•")
        
    }
    
    func add(stringList: [String],
             font: UIFont,
             bullet: String = "\u{2022}",
             indentation: CGFloat = 20,
             lineSpacing: CGFloat = 2,
             paragraphSpacing: CGFloat = 12,
             textColor: UIColor = UIColor(named:"424242Color")!,
             bulletColor: UIColor = .black) -> NSAttributedString {
        
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
        let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: bulletColor]
        
        let paragraphStyle = NSMutableParagraphStyle()
        let nonOptions = [NSTextTab.OptionKey: Any]()
        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
        paragraphStyle.defaultTabInterval = indentation
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        paragraphStyle.headIndent = indentation
        
        let bulletList = NSMutableAttributedString()
        for (index,string) in stringList.enumerated() {
            let formattedString = "\(bullet)\t\(string)\n"
            let attributedString = NSMutableAttributedString(string: formattedString)
            
            attributedString.addAttributes(
                [NSAttributedString.Key.paragraphStyle : paragraphStyle],
                range: NSMakeRange(0, attributedString.length))
            
            attributedString.addAttributes(
                textAttributes,
                range: NSMakeRange(0, attributedString.length))
            
            let string:NSString = NSString(string: formattedString)
            let rangeForBullet:NSRange = string.range(of: bullet)
            attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
            bulletList.append(attributedString)
        }
        
        return bulletList
    }
    
    @objc func backButtonOverrideAction() {
        print("Back button tapped")
        // Perform the action you want here
        let next = UIStoryboard(name: "Basicknowledge", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "Basicknowledge") as? Basicknowledge
        vc?.title = "Basic Knowledge"
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @IBAction func forward_action(_ sender: UIButton) {
        let next = UIStoryboard(name: "Consequences", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "Consequences_three") as? Consequences_three
        vc?.title = "Basic knowledge"
        vc?.sectionID555 = sectionID55
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func backward_action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
