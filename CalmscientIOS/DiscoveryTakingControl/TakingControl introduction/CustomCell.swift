//
//  CustomCell.swift
//  CalmscientIOS
//
//  Created by mac on 25/05/24.
//

import UIKit

class CustomCell: UITableViewCell {
    @IBOutlet var action_button: UIButton!
    @IBOutlet var name_label: UILabel!
    @IBOutlet var main_view: UIView!

    var onButtonTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        main_view.layer.cornerRadius = 10
        main_view.layer.masksToBounds = false
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        onButtonTap?()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

