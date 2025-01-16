//
//  CapsuleTableViewCell.swift
//  CalmscientIOS
//
//  Created by NFC User on 30/12/24.
//

import UIKit

class CapsuleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var roundedView: UIView!
    @IBOutlet weak var tableText: FontLL14!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundedView.layer.cornerRadius = 20
        roundedView.clipsToBounds = true
        roundedView.layer.borderColor = #colorLiteral(red: 0.4308217764, green: 0.4193654656, blue: 0.7016245723, alpha: 1)
        roundedView.layer.borderWidth = 2.0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("RoundedView Frame: \(roundedView.frame)")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
