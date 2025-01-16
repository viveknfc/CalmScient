//
//  ProgressExpandableTableCell.swift
//  CalmscientIOS
//
//  Created by NFC on 29/04/24.
//

import UIKit

class ProgressExpandableTableCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var borderView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titlePer: UILabel!
    
    
    var dataItem:ProgressOfWorkCellData! {
        didSet {
            if dataItem.percentage.count < 4 {
                fatalError("ProgressExpandableTableCell Data Mismatch")
            }
            titleLabel.text = dataItem.title
            titlePer.text = dataItem.titlePer
        }
    }
    
    var cellExpansionClosure:((Bool)->Void)?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowAndBorder()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didClickOnExpandOrCollapse(_ sender: UIButton) {
        cellExpansionClosure?(true)
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
