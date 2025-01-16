//
//  CustomCell.swift
//  CalmscientIOS
//
//  Created by mac on 25/05/24.
//

import UIKit

class CustomCell: UITableViewCell {
    @IBOutlet var action_button: UIButton!
    @IBOutlet var name_label: UILabel!
    @IBOutlet var main_view: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        main_view.layer.cornerRadius = 10
        main_view.layer.shadowColor = UIColor.black.cgColor
        main_view.layer.shadowOpacity = 0.1
        main_view.layer.shadowOffset = CGSize(width: 0, height: 0)
        main_view.layer.shadowRadius = 2
        main_view.layer.masksToBounds = false
               
               // Adding a shadow path for better performance
        main_view.layer.shadowPath = UIBezierPath(roundedRect: main_view.bounds, cornerRadius: main_view.layer.cornerRadius).cgPath
          
            
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

