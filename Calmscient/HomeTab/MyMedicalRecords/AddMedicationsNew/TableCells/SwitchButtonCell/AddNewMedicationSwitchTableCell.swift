//
//  AddNewMedicationSwitchTableCell.swift
//  CalmscientIOS
//
//  Created by NFC on 26/04/24.
//

import UIKit

class AddNewMedicationSwitchTableCell: UITableViewCell, UITextFieldDelegate {
    let FontReqular = UIFont(name: Fonts().lexendRegular, size: 18)

    @IBOutlet weak var switchButton: SwitchButton!
    @IBOutlet weak var cellTitleLabel: UILabel!
    
    @IBOutlet weak var expiryTextfield: TextFieldWithPadding!
    var didTapExpiryTextField: (() -> Void)?
    @IBOutlet weak var expiryLabel: FontLR16!
    
    
    @IBOutlet weak var scheduleTimeLbl: UILabel!
    var isMedicationIncluded:((Bool) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        switchButton.onImage = UIImage(named: "ToggleSwitch_Yes".localized)
        switchButton.offImage = UIImage(named: "ToggleSwitch_No")
        switchButton.changeResponseClosure = {[weak self] in self?.isMedicationIncluded?($0)}
        // Initialization code
        
        expiryTextfield.layer.borderWidth = 1
        expiryTextfield.layer.borderColor = UIColor(named: "light6E6BB3Color")?.cgColor
        expiryTextfield.backgroundColor = UIColor(named: "lightF2F2F2Color")
        expiryTextfield.layer.cornerRadius = 2
        expiryTextfield.layer.masksToBounds = true
        expiryTextfield.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension AddNewMedicationSwitchTableCell {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == expiryTextfield {
            didTapExpiryTextField?()
            return false // Prevent the keyboard from appearing
        }
        return true
    }
}

