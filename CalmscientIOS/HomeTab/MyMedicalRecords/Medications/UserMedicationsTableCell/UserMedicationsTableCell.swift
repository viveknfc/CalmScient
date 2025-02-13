//
//  UserMedicationsTableCell.swift
//  MainTabBarApp
//
//  Created by KA on 14/03/24.
//

import UIKit

protocol CustomTableViewCellDelegate: AnyObject {
    func didChangeSelectionState(for cell: UITableViewCell, isSelected: Bool)
    func didTapEditButton(in cell: UITableViewCell)
    func didTapDeleteButton(in cell: UITableViewCell)
    
    func didTapMoreButton(in cell: UITableViewCell, at indexPath: IndexPath, buttonFrame: CGRect)
    func dismissDropdown()
}

class UserMedicationsTableCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var cellSelectionImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pmTimeLabel: UILabel!
    @IBOutlet weak var afTimeLabel: UILabel!
    @IBOutlet weak var cellStatusLabel: UILabel!
    @IBOutlet weak var expiredLabel: UILabel!
    
    @IBOutlet weak var expiredLeadingValue: NSLayoutConstraint!
    
    @IBOutlet weak var dropDownButton: UIButton!
    
    @IBOutlet weak var PMImage: UIImageView!
    @IBOutlet weak var AMImage: UIImageView!
    @IBOutlet weak var AFImage: UIImageView!
    
    
    public var isCellSelected = Bool()
    public var buttonState: SelectionButtonState = .dafault {
        didSet {
            if buttonState == .selected {
                       isCellSelected = true
                   } else {
                       isCellSelected = false
                   }
            delegate?.didChangeSelectionState(for: self, isSelected: isCellSelected) // Pass the cell itself
            
        }
    }
    
    weak var delegate: CustomTableViewCellDelegate?
    var indexPath: IndexPath?

    @IBAction func didTapOnSelectionButton(_ sender: UITapGestureRecognizer) {
        if buttonState == .dafault {
            buttonState = .selected
        } else {
            buttonState = .dafault
        }
        UIView.transition(with: cellSelectionImage, duration: 0.3, options: .transitionCrossDissolve) {
            self.cellSelectionImage.image = self.buttonState.getAssetImageForState()
        }
    }
   
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowAndBorder()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnSelectionButton(_:)))
        self.cellSelectionImage.isUserInteractionEnabled = true
        self.cellSelectionImage.addGestureRecognizer(tapGestureRecognizer)
        isCellSelected = false
        buttonState = .dafault
        self.cellSelectionImage.image = self.buttonState.getAssetImageForState()
        // Initialization code

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        buttonState = .dafault  // Reset to default state
        cellSelectionImage.image = buttonState.getAssetImageForState()  // Update UI accordingly
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func dropDownButtonTapped(_ sender: UIButton) {
        guard let tableView = self.superview as? UITableView,
                      let indexPath = indexPath else { return }

                // Convert the button's frame to the table view's coordinate system
                let buttonFrame = sender.convert(sender.bounds, to: tableView)
                delegate?.didTapMoreButton(in: self, at: indexPath, buttonFrame: buttonFrame)
    }
    
    
    func updateCellWith(MedicalDetails record:MedicineDetails) {
        titleLabel.text = record.medicationDetailsByDate[0].medicineName
        subTitleLabel.text = record.medicationDetailsByDate[0].medicalDetails.directions
        
        let alarmList = record.medicationDetailsByDate[0].medicalDetails.scheduledTimeList
        
        //viv start
        
        let enabledAlarms = alarmList.flatMap { obj in
            obj.scheduledTimes.filter { $0.isDefault == 1 }
        }
        
        if let morningAlarm = enabledAlarms.first(where: { $0.alarmTime.isDayTimeAM() }) {
            AMImage.isHidden = false
            timeLabel.text = morningAlarm.alarmTime.getDayTimeFromDate(includeTimeZone: true)
            print("Morning alarm is", timeLabel.text ?? "")
        } else {
            AMImage.isHidden = true
            timeLabel.text = ""
        }
        
        if let afternoonAlarm = enabledAlarms.first(where: { $0.alarmTime.isDayTimePM() }) {
            AFImage.isHidden = false
            afTimeLabel.text = afternoonAlarm.alarmTime.getDayTimeFromDate(includeTimeZone: true)
            print("Afternoon alarm is", afTimeLabel.text ?? "")
        } else {
            AFImage.isHidden = true
            afTimeLabel.text = ""
        }
        
        if let eveningAlarm = enabledAlarms.first(where: { $0.alarmTime.isDayTimeEvening() }) {
            PMImage.isHidden = false
            pmTimeLabel.text = eveningAlarm.alarmTime.getDayTimeFromDate(includeTimeZone: true)
            print("Afternoon alarm is", afTimeLabel.text ?? "")
        } else {
            PMImage.isHidden = true
            pmTimeLabel.text = ""
        }

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


