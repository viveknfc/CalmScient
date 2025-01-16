//
//  ProgressOnCourseWorkMainViewTableCell.swift
//  CalmscientIOS
//
//  Created by NFC on 29/04/24.
//

import UIKit

class ProgressOnCourseWorkMainViewTableCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    var dataItem:ProgressOfWorkMainTableData! {
        didSet {
            titleLabel.font = UIFont(name: Fonts().lexendRegular, size: 15)
            subTitleLabel.font = UIFont(name: Fonts().lexendRegular, size: 15)
            titleLabel.text = dataItem.title
            subTitleLabel.text = dataItem.subTitle
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowAndBorder()
        // Initialization code
    }
    @IBAction func didClickOnForwardButton(_ sender: UIButton) {
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    fileprivate func addShadowAndBorder() {
        shadowView.layer.backgroundColor = UIColor.clear.cgColor
        shadowView.layer.shadowColor = UIColor(named: "AppViewShadowColor")?.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2.0
        
//        borderView.layer.cornerRadius = 8
//        borderView.layer.masksToBounds = true
//        borderView.layer.borderWidth = 1
//        borderView.layer.borderColor = UIColor(named: "AppViewBorderColor")?.cgColor
        borderView.applyShadow()
    }
    
}
