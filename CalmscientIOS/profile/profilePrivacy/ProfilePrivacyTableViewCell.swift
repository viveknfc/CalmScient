//
//  ProfilePrivacyTableViewCell.swift
//  CalmscientIOS
//
//  Created by KA on NA.
//

import UIKit

class ProfilePrivacyTableViewCell: UITableViewCell {

    
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var shadowView: UIView!
    var switchToggleAction: ((Bool) -> Void)?
    @IBOutlet weak var yesAndNobutton: UIButton!
    var yesAndNobuttonAction: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowAndBorder()
//        toggleSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        yesAndNobutton.addTarget(self, action: #selector(yesAndNobuttonActionClicked), for: .touchUpInside)

        // Initialization code
    }
    @objc private func switchToggled() {
        print(toggleSwitch.isOn)
            switchToggleAction?(toggleSwitch.isOn)
        }
    @objc func yesAndNobuttonActionClicked() {
        yesAndNobuttonAction?()
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
        borderView.applyShadow()
//        borderView.backgroundColor = .white
    }
    
}
