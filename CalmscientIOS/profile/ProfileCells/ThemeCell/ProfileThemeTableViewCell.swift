//
//  ProfileThemeTableViewCell.swift
//  CalmscientIOS
//
//  Created by KA on NA.
//

import UIKit

class ProfileThemeTableViewCell: UITableViewCell {
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    
    @IBOutlet weak var darkmodeLbl: UILabel!
    
    @IBOutlet weak var profileIconSwitch: UIImageView!
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellIconView: UIImageView!
    
    @IBOutlet weak var darkModeChangeButton: UIButton!
//    var switchValueChanged: ((Bool) -> Void)?
    var darkModeChangeButtonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
//            darkModeSwitch.isOn = isDarkMode
//       
//        darkModeSwitch.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        
        darkModeChangeButton.addTarget(self, action: #selector(darkModeChangeButtonActionClicked), for: .touchUpInside)


    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
//    @objc private func switchChanged(_ sender: UISwitch) {
//        switchValueChanged?(sender.isOn)
//        
//        UserDefaults.standard.set(sender.isOn, forKey: "isDarkMode")
//       // setAppDarkMode(sender.isOn)
//    }

    @objc func darkModeChangeButtonActionClicked() {
        darkModeChangeButtonAction?()
       }
}


