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
}

class UserMedicationsTableCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var cellSelectionImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pmTimeLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var PMImage: UIImageView!
    @IBOutlet weak var AMImage: UIImageView!
    public var isCellSelected = Bool()
    public var buttonState: SelectionButtonState = .dafault {
        didSet {
            if buttonState == .selected {
                       isCellSelected = true
                   } else {
                       isCellSelected = false
                   }
//            self.isCellSelected = (buttonState == .selected)
            delegate?.didChangeSelectionState(for: self, isSelected: isCellSelected) // Pass the cell itself
        }
    }
    
    weak var delegate: CustomTableViewCellDelegate?

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
        
        editButton.addTarget(self, action: #selector(editButtonTapped(_:)), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
        
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
    
    @IBAction func editButtonTapped(_ sender: UIButton) {
          delegate?.didTapEditButton(in: self)
      }

      @IBAction func deleteButtonTapped(_ sender: UIButton) {
          delegate?.didTapDeleteButton(in: self)
      }
    
    func updateCellWith(MedicalDetails record:MedicineDetails) {
        titleLabel.text = record.medicationDetailsByDate[0].medicineName
        subTitleLabel.text = record.medicationDetailsByDate[0].medicalDetails.directions
        
        let alarmList = record.medicationDetailsByDate[0].medicalDetails.scheduledTimeList
        if let morningFilteredList = alarmList.filter({ obj in
            obj.scheduledTimes[0].alarmTime.isDayTimeAM()
        }).first {
            AMImage.isHidden = false
            timeLabel.text =  morningFilteredList.scheduledTimes[0].alarmTime.getDayTimeFromDate(includeTimeZone: true)
        } else {
            AMImage.isHidden = true

            timeLabel.text = ""
        }
        
        if let morningFilteredList = alarmList.filter({ obj in
            obj.scheduledTimes[0].alarmTime.isDayTimePM()
        }).first {
            PMImage.isHidden = false

            pmTimeLabel.text =  morningFilteredList.scheduledTimes[0].alarmTime.getDayTimeFromDate(includeTimeZone: true)
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
