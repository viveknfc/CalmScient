//
//  UserIntroDayCollectionCell.swift
//  HealthApp
//
//  Created by KA on 26/02/24.
//

import UIKit

class UserIntroDayCollectionCell: UICollectionViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellTitleLabel: UILabel!
    
    @IBOutlet weak var cellWidth: NSLayoutConstraint!
    @IBOutlet weak var cellHeight: NSLayoutConstraint!
    
    @IBOutlet weak var cellTitleTopHeight: NSLayoutConstraint!
    
    var defaultImageSize: CGFloat = 0.0
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        defaultImageSize = cellWidth.constant
    }

}
