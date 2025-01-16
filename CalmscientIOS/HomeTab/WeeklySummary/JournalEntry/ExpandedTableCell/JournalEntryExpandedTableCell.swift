//
//  JournalEntryExpandedTableCell.swift
//  CalmscientIOS
//
//  Created by NFC on 29/04/24.
//

import UIKit

protocol EditActionProtocol:AnyObject {
    func didClickOnEditAction(forCellIndex:IndexPath)
}

class JournalEntryExpandedTableCell: UITableViewCell {

    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var journalTextLabel: UILabel!
    
    @IBOutlet weak var editCellButton: UIButton!
    var cellExpansionClosure:((Bool)->Void)?
    weak var editActionDelegate:EditActionProtocol?
    var cellIndexPath:IndexPath = IndexPath(row: 0, section: 0)
    var dataItem:JournalEntryDataItem! {
        didSet {
            titleLabel.text = dataItem.entry.createdAt
            journalTextLabel.text = dataItem.entry.entry
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowAndBorder()
        editCellButton.isHidden = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didClickOnExpandAndCollapseAction(_ sender: Any) {
        print("+ button in daily journal table clciked")
        cellExpansionClosure?(true)
    }
    
    
    @IBAction func didClickOnEditAction(_ sender: Any) {
        print("edit cell button in daily journal table clciked")
        editActionDelegate?.didClickOnEditAction(forCellIndex: cellIndexPath)
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
