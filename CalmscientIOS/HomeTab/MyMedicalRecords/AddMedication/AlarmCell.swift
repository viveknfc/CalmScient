//
//  AlarmCell.swift
//  HealthApp
//
//  Created by NFC on 12/03/24.
//

import UIKit

class AlarmCell: UITableViewCell {

    @IBOutlet weak var alarmModeLbl: UILabel!
    @IBOutlet weak var medicationTimeLbl: UILabel!
    @IBOutlet weak var alarmTimeLbl: UILabel!
    @IBOutlet weak var alarmOnOffSwitch: SwitchButton!
    @IBOutlet weak var alarmModeImg: UIImageView!
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cornerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.addShadowAndBorder()
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
  
    fileprivate func addShadowAndBorder() {
        shadowView.layer.backgroundColor = UIColor.clear.cgColor
        shadowView.layer.shadowColor = UIColor(named: "UserIntroShadowColor")?.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowRadius = 4.0
        
        cornerView.layer.cornerRadius = 8
        cornerView.layer.masksToBounds = true
        cornerView.layer.borderWidth = 1
        cornerView.layer.borderColor = UIColor(named: "UserIntroTableCellBorderColor")?.cgColor
    }
    
    func configureCell(celldata: AlarmData){
        alarmModeLbl.text = celldata.alarmMode
        medicationTimeLbl.text = celldata.medicationTime
        //cell.alarmOnOffSwitch.isOn = celldata.alarmOnOrOFF
        alarmTimeLbl.text = celldata.alarmTime
        alarmTimeLbl.textAlignment = .left
        switch celldata.alarmMode {
        case "Morning": alarmModeImg.image = UIImage(named: "Morning_Mode")
        case "Afternoon": alarmModeImg.image = UIImage(named: "Noon_Mode")
        default:
            alarmModeImg.image = UIImage(named: "Night_Mode")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func alarmButtonSwitchClicked(_ sender: SwitchButton) {
        
    }
}
