//
//  CustomCollectionViewCell.swift
//  CalmscientIOS
//
//  Created by mac on 06/06/24.
//

import UIKit

class CustomCollectioncell: UICollectionViewCell {

    @IBOutlet var plus_buttin: UIButton!
    @IBOutlet var minus_button: UIButton!
    @IBOutlet var alchol_imge: UIImageView!
    @IBOutlet var alchol_text: UILabel!
    @IBOutlet var main_view: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        main_view.layer.borderWidth = 1
//            button.layer.borderColor = UIColor.black.cgColor
        main_view.layer.cornerRadius = 9
        main_view.layer.borderColor = UIColor(red: 232/255, green: 231/255, blue: 244/255, alpha: 1).cgColor
        
        
        
        plus_buttin.layer.borderWidth = 1
//            button.layer.borderColor = UIColor.black.cgColor
        plus_buttin.layer.cornerRadius = 5
        plus_buttin.layer.borderColor = UIColor(red: 232/255, green: 231/255, blue: 244/255, alpha: 1).cgColor
        
        minus_button.layer.borderWidth = 0.5
//            button.layer.borderColor = UIColor.black.cgColor
        minus_button.layer.cornerRadius = 10
        minus_button.layer.borderColor = UIColor(red: 232/255, green: 231/255, blue: 244/255, alpha: 1).cgColor
        
        
        minus_button.layer.cornerRadius = 5
        minus_button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        minus_button.layer.borderWidth = 1
        minus_button.layer.borderColor =  UIColor(red: 232/255, green: 231/255, blue: 244/255, alpha: 1).cgColor
               
               // Customize right button
        plus_buttin.layer.cornerRadius = 5
        plus_buttin.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        plus_buttin.layer.borderWidth = 1
        plus_buttin.layer.borderColor =  UIColor(red: 232/255, green: 231/255, blue: 244/255, alpha: 1).cgColor
    }

    func configure(withText text: String) {
        alchol_text.text = text
    }
}
