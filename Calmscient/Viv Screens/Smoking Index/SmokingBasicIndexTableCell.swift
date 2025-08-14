//
//  SmokingBasicIndexTableCell.swift
//  CalmscientIOS
//
//  Created by NFC User on 26/12/24.
//

import UIKit

class SmokingBasicIndexTableCell: UITableViewCell {

    @IBOutlet weak var cellContentText: FontLR16!
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
            self.cellContentText.textColor = #colorLiteral(red: 0.429181397, green: 0.4192816615, blue: 0.7016126513, alpha: 1)
            self.outlineView.setBorderColor(#colorLiteral(red: 0.429181397, green: 0.4192816615, blue: 0.7016126513, alpha: 1))
        } else {
            self.cellContentText.textColor = .lightGray
            self.outlineView.setBorderColor(.lightGray)
        }
    }

}
