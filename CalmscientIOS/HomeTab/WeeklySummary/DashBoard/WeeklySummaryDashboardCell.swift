//
//  WeeklySummaryDashboardCell.swift
//  CalmscientIOS
//
//  Created by NFC on 28/04/24.
//

import UIKit

class WeeklySummaryDashboardCell: UICollectionViewCell {

    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 5
        contentView.layer.masksToBounds = true
        cellImageView.layer.cornerRadius = 5
        cellImageView.layer.masksToBounds = true
        // Initialization code
    }

}
