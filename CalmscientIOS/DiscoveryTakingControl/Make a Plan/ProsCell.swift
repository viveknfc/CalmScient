//
//  ProsCell.swift
//  CalmscientIOS
//
//  Created by mac on 24/06/24.
//

import Foundation
import UIKit

class ProsCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var main_view: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        main_view.layer.borderWidth = 1
        main_view.layer.cornerRadius = 10
        main_view.layer.borderColor = UIColor(red: 232/255, green: 231/255, blue: 244/255, alpha: 1).cgColor
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
