//
//  FactorCell.swift
//  CalmscientIOS
//
//  Created by mac on 25/06/24.
//

import Foundation
//
//  DefineCell.swift
//  CalmscientIOS
//
//  Created by mac on 25/06/24.
//

import Foundation
import Foundation
import UIKit

class FactorCell: UITableViewCell {
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    
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
        
        label1.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Also you need to consider the following factors to determine what to do." : "También debe considerar los siguientes factores para determinar qué hacer."
        label2.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "A family history of alcohol problems." : "Antecedentes familiares de problemas con el alcohol."
        label3.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Your age." : "Su edad."
        label4.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "A history of drinking-related injuries." : "Antecedentes de lesiones relacionadas con el consumo de alcohol."
        label5.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Symptoms such as a sleep, pain, or anxiety disorder and sexual dysfunction." : "Síntomas como trastorno del sueño, dolor o ansiedad y disfunción sexual."
      
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
