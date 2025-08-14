//
//  MindCell.swift
//  CalmscientIOS
//
//  Created by mac on 25/06/24.
//

import Foundation
import UIKit

class MindCell: UITableViewCell {
    @IBOutlet weak var track_btn: UIButton!
    @IBOutlet weak var quit_btn: UIButton!
    @IBOutlet weak var questionCell: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        track_btn.layer.borderWidth = 2
        track_btn.layer.cornerRadius = 20
        track_btn.layer.borderColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1).cgColor
        
        quit_btn.layer.borderWidth = 2
        quit_btn.layer.cornerRadius = 20
        quit_btn.layer.borderColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1).cgColor
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setupLanguage()
        // Configure the view for the selected state
    }
    
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
                
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
                
            }
        questionCell.text = AppHelper.getLocalizeString(str: "With this in mind, tell us what you would like to do."
        )
      //  quit_btn.titleLabel?.text = AppHelper.getLocalizeString(str: "Quit")
        quit_btn.setTitle( UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Quit" : "Abandonar", for: .normal)
        track_btn.setTitle( UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Cut down" : "Reducir", for: .normal)
       
       // track_btn.titleLabel?.text = AppHelper.getLocalizeString(str: "Cut down"
        
        
        
        
        
        }
}
