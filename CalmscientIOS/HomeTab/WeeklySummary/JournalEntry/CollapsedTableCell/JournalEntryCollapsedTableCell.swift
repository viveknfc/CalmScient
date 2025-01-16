//
//  JournalEntryCollapsedTableCell.swift
//  CalmscientIOS
//
//  Created by NFC on 29/04/24.
//

import UIKit

public class JournalEntryDataItem {
    var entry:JournalEntry
    var exapansionState:Bool = false
    
    func updateExpansionState(isExpanded:Bool) {
        self.exapansionState = isExpanded
    }
    
    init(entry:JournalEntry) {
        self.entry = entry
    }
    
}

class JournalEntryCollapsedTableCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var cellExpansionClosure:((Bool)->Void)?

    
    var dataItem:JournalEntryDataItem! {
        didSet {
            let originalDateString =  dataItem.entry.createdAt
    print("originalDateString,\(originalDateString)")
            // Define the date formatter for the original date string
            let originalDateFormatter = DateFormatter()
            // Set the format of the original date string according to its current format
            originalDateFormatter.dateFormat = "yyyy-MM-dd "

            // Parse the original date string into a Date object
            if let date = originalDateFormatter.date(from: originalDateString) {
                // Define the date formatter for the desired output format
                let outputDateFormatter = DateFormatter()
                // Set the desired output format
                outputDateFormatter.dateFormat = "MM/dd/yyyy"
                
                // Convert the Date object to the desired output format
                let formattedDateString = outputDateFormatter.string(from: date)
                print("formattedDateString,\(formattedDateString)")
                // Assign the formatted date string to the label
                titleLabel.text = formattedDateString
            } else {
                // Handle the case where the date string could not be parsed
                titleLabel.text = "Invalid Date"
            }
        }
    }
 
    @IBAction func didClickOnExpandOrCollapseButton(_ sender: UIButton) {
        print("")
        cellExpansionClosure?(true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowAndBorder()
        // Initialization code
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
        
        borderView.layer.cornerRadius = 8
        borderView.layer.masksToBounds = true
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = UIColor(named: "AppViewBorderColor")?.cgColor
    }
    
}
