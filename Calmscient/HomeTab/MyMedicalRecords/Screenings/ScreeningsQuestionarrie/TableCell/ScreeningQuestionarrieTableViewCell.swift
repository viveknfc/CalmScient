//
//  ScreeningQuestionarrieTableViewCell.swift
//  CalmscientIOS
//
//  Created by NFC on 27/04/24.
//

import UIKit

class ScreeningQuestionarrieTableViewCell: UITableViewCell {
    
    var selectedCellColor:UIColor? =  UIColor(named: "medicationscelldefaulttextcolor")
    var defaultCellColor:UIColor? = UIColor(named: "AppViewContentColor")
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cellTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        addShadowAndBorder()
        // Configure the view for the selected state
    }
    
    public func applyFill(isSelected:Bool) {
        if isSelected {
            borderView.backgroundColor = selectedCellColor
            cellTextLabel.textColor = UIColor.white
        } else {
            borderView.backgroundColor = defaultCellColor
            cellTextLabel.textColor = UIColor(named: "424242Color")
        }
    }
    
    fileprivate func addShadowAndBorder() {
        shadowView.layer.backgroundColor = UIColor.clear.cgColor
        shadowView.layer.shadowColor = UIColor(named: "AppViewShadowColor")?.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2.0
        
        borderView.layer.cornerRadius = 8
        borderView.layer.masksToBounds = true
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = UIColor(named: "AppViewBorderColor")?.cgColor
    }
    
}
