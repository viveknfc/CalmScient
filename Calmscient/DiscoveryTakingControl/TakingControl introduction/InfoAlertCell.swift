//
//  InfoAlertCell.swift
//  CalmscientIOS
//
//  Created by mac on 27/05/24.
//
import UIKit

class InfoAlertCell: UITableViewCell {
    @IBOutlet var caption_label: UILabel!
    @IBOutlet var name_label: UILabel!
    @IBOutlet var description_label: UILabel!

    @IBOutlet var main_view: UIView!
    @IBOutlet var info_view: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        info_view.layer.cornerRadius = 10
        info_view.layer.borderWidth = 0.5
        info_view.layer.borderColor = UIColor.lightGray.cgColor
//        info_view.backgroundColor = UIColor.gray
          
            
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

