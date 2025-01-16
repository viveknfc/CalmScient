//
//  HomeTabFavoritesCollectionViewCell.swift
//  MainTabBarApp
//
//  Created by KA on 23/04/24.
//

import UIKit

class HomeTabFavoritesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var cellImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel.font = UIFont(name: Fonts().lexendRegular, size: 13)
        // Initialization code
        // Round corners for cellImageView
       self.cellImageView.layer.cornerRadius = 12 // Adjust this value as needed
       self.cellImageView.clipsToBounds = true
    }

}
