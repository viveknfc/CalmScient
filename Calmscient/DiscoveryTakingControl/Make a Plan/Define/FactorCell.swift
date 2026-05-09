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
        
        label1.text = "Also you need to consider the following factors to determine what to do.".localized
        label2.text = "A family history of alcohol problems.".localized
        label3.text = "Your age.".localized
        label4.text = "A history of drinking-related injuries.".localized
        label5.text = "Symptoms such as a sleep, pain, or anxiety disorder and sexual dysfunction.".localized
      
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
