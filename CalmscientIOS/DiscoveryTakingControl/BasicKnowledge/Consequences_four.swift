//
//  Consequences_three.swift
//  CalmscientIOS
//
//  Created by mac on 05/06/24.
//

import Foundation
import UIKit

@available(iOS 16.0, *)
class Consequences_four:  ViewController {
    @IBOutlet weak var selection_view: UIImageView!

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var normalTextLabel: UILabel!
    @IBOutlet weak var hyperTextLabel: UITextView!
    @IBOutlet weak var subtitleLabel: UILabel!
    var sectionID5555: Int?
    
    @IBOutlet weak var bodyTxtView: UITextView!
    
    let englishArr = [
        AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Consequence_Four_Message_One"),
        AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Consequence_Four_Message_Two"),
        AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Consequence_Four_Message_Three"),
        AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Consequence_Four_Message_Four"),
        AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Consequence_Four_Message_Five"),
        AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Consequence_Four_Message_Six"),
    ]
    
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
        
        let attrTxt = add(stringList: englishArr, font: UIFont(name: Fonts().lexendLight, size: 15)!
                          , bullet: "  •",textColor: (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as! Bool ? .white : UIColor(hex: "#424242"),bulletColor: (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as! Bool ? .white : UIColor(hex: "#424242"))
        
        bodyTxtView.attributedText = attrTxt
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
        subtitleLabel.text = AppHelper.getLocalizeString(str: "Health problems") 
        subtitleLabel.font = UIFont(name: Fonts().lexendMedium, size: 15)!
        
        
        subtitleLabel.textColor = UIColor(named: "424242Color")
        normalTextLabel.textColor = UIColor(named: "424242Color")
      //  hyperTextLabel.text = AppHelper.getLocalizeString(str:"consequences4" )
        
        }
    @objc func backButtonOverrideAction() {
        print("Back button tapped")
        // Perform the action you want here
        let next = UIStoryboard(name: "Basicknowledge", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "Basicknowledge") as? Basicknowledge
        vc?.title = "Basic knowledge"
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @IBAction func forward_action(_ sender: UIButton) {
        let next = UIStoryboard(name: "Consequences", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "Consequences_five") as? Consequences_five
        vc?.title = "Basic knowledge"
        vc?.sectionID55555 = sectionID5555
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func backward_action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func add(stringList: [String],
             font: UIFont,
             bullet: String = "\u{2022}",
             indentation: CGFloat = 20,
             lineSpacing: CGFloat = 2,
             paragraphSpacing: CGFloat = 12,
             textColor: UIColor = UIColor(hex: "#424242"),
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
}
