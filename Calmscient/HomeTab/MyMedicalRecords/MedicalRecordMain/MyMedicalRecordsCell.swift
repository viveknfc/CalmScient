//
//  MyMedicalRecordsCell.swift
//  MainTabBarApp
//
//  Created by KA on 13/03/24.
//

import UIKit

class MyMedicalRecordsCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var medicalCellImage: UIImageView!
    @IBOutlet weak var titleTextField: UILabel!
    
    @IBOutlet weak var arrowImage: UIImageView!
    @IBOutlet weak var cellBottomImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowAndBorder()
        titleTextField.textColor = UIColor(named: "MedicalRecordsTextColor")
        // Initialization code
    }
    
    fileprivate func addShadowAndBorder() {
        shadowView.layer.backgroundColor = UIColor.clear.cgColor
        shadowView.layer.shadowColor = UIColor(named: "AppViewShadowColor")?.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowRadius = 4.0
        
        borderView.layer.cornerRadius = 8
        borderView.layer.masksToBounds = true
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = UIColor(named: "AppViewBorderColor")?.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
