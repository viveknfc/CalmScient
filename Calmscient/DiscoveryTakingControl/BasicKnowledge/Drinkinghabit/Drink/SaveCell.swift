//
//  SaveCell.swift
//  CalmscientIOS
//
//  Created by mac on 07/06/24.
//

import Foundation
import UIKit

class SaveCell: UITableViewCell {
    @IBOutlet weak var save_btn: UIButton!
    @IBOutlet weak var msgLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        msgLabel.text = AppHelper.getLocalizeString(str: "Save it to weekly summary journal entry")
        save_btn.setTitle(AppHelper.getLocalizeString(str: "Yes"), for: .normal)

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)
           // Configure the view for the selected state if needed
       }
}
