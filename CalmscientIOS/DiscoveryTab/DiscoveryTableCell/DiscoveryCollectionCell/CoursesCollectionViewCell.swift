//
//  CoursesCollectionViewCell.swift
//  CalmscientIOS
//
//  Created by KA on NA.
//

import UIKit

class CoursesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tickMarkImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var courseImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.isHidden = true
        tickMarkImage.isHidden = true
    }
    

}
