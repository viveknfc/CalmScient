//
//  DefineCell.swift
//  CalmscientIOS
//
//  Created by mac on 25/06/24.
//

import Foundation
import Foundation
import UIKit

class DefineCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var point1Label: UILabel!
    
    @IBOutlet weak var point2Label: UILabel!
    @IBOutlet weak var point3Label: UILabel!
    @IBOutlet weak var point4Label: UILabel!
    @IBOutlet weak var point5Label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
//        track_btn.layer.borderWidth = 2
//        track_btn.layer.cornerRadius = 20
//        track_btn.layer.borderColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1).cgColor
//        
//        quit_btn.layer.borderWidth = 2
//        quit_btn.layer.cornerRadius = 20
//        quit_btn.layer.borderColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1).cgColor
        // Initialization code
        setupLanguage()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        
        headerLabel.text = AppHelper.getLocalizeString(str: "Quitting is strongly advised if you:")
        point1Label.text = AppHelper.getLocalizeString(str: "Have tried cutting down but cannot stay within the limit you set." )
        point2Label.text = AppHelper.getLocalizeString(str: "Have had alcohol use disorder (AUD) or now have any symptoms." )
        point3Label.text = AppHelper.getLocalizeString(str: "Have a physical or mental health condition that is caused or being worsened by drinking." )
        point4Label.text = AppHelper.getLocalizeString(str: "Are taking medication that interacts with alcohol." )
        point5Label.text = AppHelper.getLocalizeString(str: "Are or might be pregnant." )
        
        }
}
