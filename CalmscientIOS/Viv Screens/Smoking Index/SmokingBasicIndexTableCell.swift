//
//  SmokingBasicIndexTableCell.swift
//  CalmscientIOS
//
//  Created by NFC User on 26/12/24.
//

import UIKit

class SmokingBasicIndexTableCell: UITableViewCell {

    @IBOutlet weak var cellContentText: FontLL14!
    @IBOutlet weak var ticckImage: UIImageView!
    @IBOutlet weak var outlineView: CurvedOutlineView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configureCell(isActive: Bool) {
        if isActive {
            
        } else {
            self.cellContentText.textColor = .gray
            self.outlineView.setBorderColor(.gray)
        }
    }

}
