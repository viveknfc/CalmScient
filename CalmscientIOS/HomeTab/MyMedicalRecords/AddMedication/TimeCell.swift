//
//  TimeCell.swift
//  HealthApp
//
//  Created by NFC on 14/03/24.
//

import UIKit

class TimeCell: UICollectionViewCell {

    @IBOutlet weak var imageIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    class var reuseIdentifier: String {
        return "TimeCell"
    }
    class var nibName: String {
        return "TimeCell"
    }

}
