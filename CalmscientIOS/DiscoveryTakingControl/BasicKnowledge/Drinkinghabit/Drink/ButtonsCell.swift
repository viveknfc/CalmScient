//
//  ButtonCell.swift
//  CalmscientIOS
//
//  Created by mac on 07/06/24.
//

import Foundation
import UIKit

class ButtonsCell: UITableViewCell {
    @IBOutlet weak var labl_name: UILabel!
    @IBOutlet weak var main_view: UIView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        main_view.layer.borderWidth = 0.5
//            button.layer.borderColor = UIColor.black.cgColor
        main_view.layer.cornerRadius = 10
        main_view.layer.borderColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1).cgColor
        main_view.layer.shadowColor = UIColor.black.cgColor
        main_view.layer.shadowOffset = CGSize(width: 0, height: 1)
        main_view.layer.shadowOpacity = 0.1
        main_view.layer.shadowRadius = 1.0
        main_view.layer.masksToBounds = false
        // Initialization code
    }

    
}
