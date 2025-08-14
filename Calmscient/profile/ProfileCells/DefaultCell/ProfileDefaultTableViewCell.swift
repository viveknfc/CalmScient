//
//  ProfileDefaultTableViewCell.swift
//  CalmscientIOS
//
//  Created by KA on NA.
//

import UIKit

class ProfileDefaultTableViewCell: UITableViewCell {

    @IBOutlet weak var cellIconView: UIImageView!
    @IBOutlet weak var cellTitleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
