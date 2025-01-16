//
//  NeedToTalkTableViewCell.swift
//  CalmscientIOS
//
//  Created by BVK on 21/07/24.
//

import UIKit

class NeedToTalkTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var learnMoreButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        learnMoreButton.layer.cornerRadius = 4
        learnMoreButton.titleLabel?.font = UIFont(name: Fonts().lexendSemiBold, size: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
