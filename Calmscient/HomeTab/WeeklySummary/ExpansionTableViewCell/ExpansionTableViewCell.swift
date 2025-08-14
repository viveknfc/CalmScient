//
//  ExpansionTableViewCell.swift
//  CalmscientIOS
//
//  Created by NFC on 28/04/24.
//

import UIKit

class ExpansionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var borderView: UIView!
    
    
    var dataItem:ExpansionTableData! {
        didSet {
            titleLabel.text = dataItem.title
            leftSubtitle.text = dataItem.leftSubTitle
            rightSubTitle.text = dataItem.rightSubTitle
        }
    }
    @IBOutlet weak var expansionButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rightSubTitle: UILabel!
    @IBOutlet weak var leftSubtitle: UILabel!
    
    var cellExpansionClosure:((Bool)->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowAndBorder()
        // Initialization code
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
        leftSubtitle.text = ""
        rightSubTitle.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didClickOnExpansionOrCollapse(_ sender: UIButton) {
        cellExpansionClosure?(false)
    }
    
    
}
