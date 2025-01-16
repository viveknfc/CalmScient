//
//  ProfileLanguageCollectionCell.swift
//  CalmscientIOS
//
//  Created by KA on NA.
//

import UIKit

class ProfileLanguageCollectionCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var languageTextField: UILabel!
    @IBOutlet weak var languageIconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       // prepareCollectionCell()
        // Initialization code
    }
    
    fileprivate func prepareCollectionCell() {
        circleView.layer.cornerRadius = circleView.frame.width / 2
        circleView.layer.masksToBounds = true
    }
    
}

