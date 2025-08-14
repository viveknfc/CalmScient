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
    @IBOutlet weak var bulletinLabel: FontLL14!
    
    // Constraints
    private var journalToBulletinConstraint: NSLayoutConstraint!
    private var journalToSuperviewConstraint: NSLayoutConstraint!
    private var bulletinToSuperviewConstraint: NSLayoutConstraint!
 
    @IBOutlet weak var editCellButton: UIButton!
    var cellExpansionClosure:((Bool)->Void)?
    weak var editActionDelegate:EditActionProtocol?
    var cellIndexPath:IndexPath = IndexPath(row: 0, section: 0)
    
    var dataItem:JournalEntryDataItem! {
        didSet {
            titleLabel.text = dataItem.entry.createdAt
            journalTextLabel.text = dataItem.entry.entry
            
            // Fetch bullet points from DrinkingData
            if let details = DrinkingData.shared[dataItem.entry.entry]?.1 {
                print("bullet points are not empty")
                let bulletPointText = details.map { "• \($0)" }.joined(separator: "\n\n")
                bulletinLabel.text = bulletPointText
                bulletinLabel.isHidden = false // Ensure it’s visible
                
                // Activate journal -> bulletin, bulletin -> superview
//                journalToBulletinConstraint.isActive = true
//                journalToSuperviewConstraint.isActive = false
//                bulletinToSuperviewConstraint.isActive = true
                
            } else {
                bulletinLabel.text = ""
                bulletinLabel.isHidden = true // Hide if no bullets
                
                // Activate journal -> superview
//                journalToBulletinConstraint.isActive = false
//                journalToSuperviewConstraint.isActive = true
//                bulletinToSuperviewConstraint.isActive = false

            }
            
            layoutIfNeeded() // Refresh UI
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        setupConstraints()
        addShadowAndBorder()
        editCellButton.isHidden = true
 
        // Initialization code
    }
    
    private func setupConstraints() {
        // Enable Auto Layout
        journalTextLabel.translatesAutoresizingMaskIntoConstraints = false
        bulletinLabel.translatesAutoresizingMaskIntoConstraints = false

        // Common Constraints
        NSLayoutConstraint.activate([
            journalTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            journalTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            bulletinLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bulletinLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])

        // Dynamic Constraints
        journalToBulletinConstraint = journalTextLabel.bottomAnchor.constraint(equalTo: bulletinLabel.topAnchor, constant: -8)
        journalToSuperviewConstraint = journalTextLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        bulletinToSuperviewConstraint = bulletinLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)

        // Default Active Constraints
        journalToSuperviewConstraint.isActive = true
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didClickOnExpandAndCollapseAction(_ sender: Any) {
        print("+ button in daily journal table clciked")

        bulletinLabel.isHidden.toggle() // Show/hide bullets
        
        cellExpansionClosure?(bulletinLabel.isHidden == false) // Notify expansion

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
