//
//  SmokingIndexResourceTableViewCell.swift
//  CalmscientIOS
//
//  Created by NFC User on 26/12/24.
//

import UIKit

class SmokingIndexResourceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rightImage: UIImageView!
    @IBOutlet weak var headLabel: FontLR15!
    @IBOutlet weak var desc: FontLL12!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure the desc label
        desc.textAlignment = .left
        desc.numberOfLines = 0 // Allow multiline if needed

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
