//
//  UserMedicationsTableCell.swift
//  MainTabBarApp
//
//  Created by KA on 14/03/24.
//

import UIKit

protocol EditableCell: AnyObject {
    var delegate: CustomTableViewCellDelegate? { get }
}

protocol CustomTableViewCellDelegate: AnyObject {
    func didTapEditButton(in cell: UITableViewCell)
    func didTapDeleteButton(in cell: UITableViewCell)
    
    func didTapMoreButton(in cell: UITableViewCell, at indexPath: IndexPath, buttonFrame: CGRect)
    func dismissDropdown()
    
    func didTapTakenButton(in cell: UITableViewCell, buttonType: ButtonType)
}

enum ButtonType {
    case first
    case second
    case third
    
    var scheduledIndex: Int {
            switch self {
            case .first: return 0
            case .second: return 1
            case .third: return 2
            }
        }
}

class UserMedicationsTableCell: UITableViewCell, EditableCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pmTimeLabel: UILabel!
    @IBOutlet weak var afTimeLabel: UILabel!
    @IBOutlet weak var expiredLabel: UILabel!
    
    @IBOutlet weak var dropDownButton: UIButton!
    
    @IBOutlet weak var PMImage: UIImageView!
    @IBOutlet weak var AMImage: UIImageView!
    @IBOutlet weak var AFImage: UIImageView!
    
    @IBOutlet weak var amButton: UIButton!
    @IBOutlet weak var afButton: UIButton!
    @IBOutlet weak var pmButton: UIButton!
    
    @IBOutlet weak var amTaken: UILabel!
    @IBOutlet weak var afTaken: UILabel!
    @IBOutlet weak var pmTaken: UILabel!
    
    weak var delegate: CustomTableViewCellDelegate?
    var indexPath: IndexPath?
    
    let isSpanish = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
   
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowAndBorder()

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
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
    
    //MARK: - AM Button Tapped
    
    @IBAction func amTakenButtonTapped(_ sender: Any) {
        delegate?.didTapTakenButton(in: self, buttonType: .first)
    }
    
    //MARK: - AF Button Tapped
    
    @IBAction func afTakenButtonTapped(_ sender: Any) {
        delegate?.didTapTakenButton(in: self, buttonType: .second)
    }
    
    //MARK: - PM Button Tapped
    
    @IBAction func pmTakenButtonTapped(_ sender: Any) {
        delegate?.didTapTakenButton(in: self, buttonType: .third)
    }
    
    
    func updateCellWith(MedicalDetails record:MedicineDetails) {
        titleLabel.text = record.medicationDetailsByDate[0].medicineName
        subTitleLabel.text = record.medicationDetailsByDate[0].medicalDetails.directions
        
        expiredLabel.text = isSpanish == 1 ? "Expired" : "Caducado"
        
        let alarmList = record.medicationDetailsByDate[0].medicalDetails.scheduledTimeList
        
        //viv start
        
        // Get current date and the date 5 days ago
        let calendar = Calendar.current
        let now = Date() // Current date and time
        let fourDaysAgo = calendar.date(byAdding: .day, value: -5, to: now)!
        
        // Get the medication date from MedicineDetails (example: "04/10/2025")
        let medicationDate = record.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let medicationDateParsed = dateFormatter.date(from: medicationDate) else {
            return
        }

        // Check if the medication date is within the past 5 days including today
        let isWithinAllowedRange = (medicationDateParsed >= fourDaysAgo) && (medicationDateParsed <= now)
        
        //end
        
        let enabledAlarms = alarmList.flatMap { obj in
            obj.scheduledTimes.filter { $0.isDefault == 0 } // 1
        }
        
        if let morningAlarm = enabledAlarms.first(where: { $0.medicineTime.isDayTimeAM() }) {
            AMImage.isHidden = false
            amTaken.isHidden = false
            amButton.isHidden = false
            timeLabel.text = morningAlarm.medicineTime.getDayTimeFromDate(formatter: "HH:mm:ss", includeTimeZone: true) //alarmTime
            print("Morning alarm is", timeLabel.text ?? "")
            let isTaken = morningAlarm.medicineTaken == "1"
            amButton.layer.borderColor = isTaken ? #colorLiteral(red: 0.9636033177, green: 0.5739583373, blue: 0.5747298598, alpha: 1) : #colorLiteral(red: 0.4356096983, green: 0.419034481, blue: 0.7057439685, alpha: 1)
            timeLabel.textColor = isTaken ? #colorLiteral(red: 0.9636033177, green: 0.5739583373, blue: 0.5747298598, alpha: 1) : #colorLiteral(red: 0.4356096983, green: 0.419034481, blue: 0.7057439685, alpha: 1)
            print("is spanish value is",isSpanish)
            let actionText = (isSpanish == 2) ? (isTaken ? "Tomado" : "Tomar") : (isTaken ? "Taken" : "Take")
            amTaken.text = actionText
            amTaken.textColor = isTaken ? #colorLiteral(red: 0.9636033177, green: 0.5739583373, blue: 0.5747298598, alpha: 1) : #colorLiteral(red: 0.4356096983, green: 0.419034481, blue: 0.7057439685, alpha: 1)
            
            //viv start
            
            let today = Calendar.current.startOfDay(for: Date())
            let fourDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: today)! // today + 4 previous days
            let isInAllowedWindow = medicationDateParsed >= fourDaysAgo && medicationDateParsed <= today


            if !isInAllowedWindow || !isWithinAllowedRange {
                amButton.isUserInteractionEnabled = false
                amButton.layer.borderColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1) // Gray border
                amButton.backgroundColor = #colorLiteral(red: 0.9, green: 0.9, blue: 0.9, alpha: 1) // Light gray background
            } else {
                let medicineTime = morningAlarm.medicineTime

                if let medicineDateOnly = dateFormatter.date(from: medicationDate),
                   let hour = Int(medicineTime.prefix(2)) {
                    let medicineDateTime = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: medicineDateOnly)

                        amButton.isUserInteractionEnabled = true
                        amButton.layer.borderColor = isTaken ? #colorLiteral(red: 0.9636033177, green: 0.5739583373, blue: 0.5747298598, alpha: 1) : #colorLiteral(red: 0.4356096983, green: 0.419034481, blue: 0.7057439685, alpha: 1)
                        amButton.backgroundColor = .clear
                    
                }

            }
            
            //end
            
        } else {
            AMImage.isHidden = true
            amTaken.isHidden = true
            amButton.isHidden = true
            timeLabel.text = ""
        }
        
        if let afternoonAlarm = enabledAlarms.first(where: { $0.medicineTime.isDayTimePM() }) {
            AFImage.isHidden = false
            afTaken.isHidden = false
            afButton.isHidden = false
            afTimeLabel.text = afternoonAlarm.medicineTime.getDayTimeFromDate(formatter: "HH:mm:ss", includeTimeZone: true)
            print("Afternoon alarm is", afTimeLabel.text ?? "")
            let isTaken = afternoonAlarm.medicineTaken == "1"
            afButton.layer.borderColor = isTaken ? #colorLiteral(red: 0.9636033177, green: 0.5739583373, blue: 0.5747298598, alpha: 1) : #colorLiteral(red: 0.4318677187, green: 0.4149213433, blue: 0.7059496045, alpha: 1)
            afTimeLabel.textColor = isTaken ? #colorLiteral(red: 0.9636033177, green: 0.5739583373, blue: 0.5747298598, alpha: 1) : #colorLiteral(red: 0.4356096983, green: 0.419034481, blue: 0.7057439685, alpha: 1)
            
            let actionText = (isSpanish == 2) ? (isTaken ? "Tomado" : "Tomar") : (isTaken ? "Taken" : "Take")
            afTaken.text = actionText
            
            afTaken.textColor = isTaken ? #colorLiteral(red: 0.9636033177, green: 0.5739583373, blue: 0.5747298598, alpha: 1) : #colorLiteral(red: 0.4356096983, green: 0.419034481, blue: 0.7057439685, alpha: 1)
            
        //VIV start
            
            let today = Calendar.current.startOfDay(for: Date())
            let now = Date()
            let fourDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: today)!
            let isInAllowedWindow = medicationDateParsed >= fourDaysAgo && medicationDateParsed <= today

            if !isInAllowedWindow || !isWithinAllowedRange {
                afButton.isUserInteractionEnabled = false
                afButton.layer.borderColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
                afButton.backgroundColor = #colorLiteral(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
            } else {
                var isFuture = false

                // Only restrict future times if date is today
                if Calendar.current.isDate(medicationDateParsed, inSameDayAs: today) {
                    if let medicineDateOnly = dateFormatter.date(from: medicationDate),
                       let hour = Int(afternoonAlarm.medicineTime.prefix(2)) {
                        let scheduledTime = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: medicineDateOnly)
                        if let scheduled = scheduledTime, now < scheduled {
                            isFuture = true
                        }
                    }
                }

                if isFuture {
                    afButton.isUserInteractionEnabled = false
                    afButton.layer.borderColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
                    afButton.backgroundColor = #colorLiteral(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
                } else {
                    afButton.isUserInteractionEnabled = true
                    afButton.layer.borderColor = isTaken ? #colorLiteral(red: 0.9636033177, green: 0.5739583373, blue: 0.5747298598, alpha: 1) : #colorLiteral(red: 0.4318677187, green: 0.4149213433, blue: 0.7059496045, alpha: 1)
                    afButton.backgroundColor = .clear
                }
            }
            
            //END
            
        } else {
            AFImage.isHidden = true
            afTaken.isHidden = true
            afButton.isHidden = true
            afTimeLabel.text = ""
        }
        
        if let eveningAlarm = enabledAlarms.first(where: { $0.medicineTime.isDayTimeEvening() }) {
            PMImage.isHidden = false
            pmTaken.isHidden = false
            pmButton.isHidden = false
            pmTimeLabel.text = eveningAlarm.medicineTime.getDayTimeFromDate(formatter: "HH:mm:ss", includeTimeZone: true)
            print("Afternoon alarm is", afTimeLabel.text ?? "")
            let isTaken = eveningAlarm.medicineTaken == "1"
            pmButton.layer.borderColor = isTaken ? #colorLiteral(red: 0.9636033177, green: 0.5739583373, blue: 0.5747298598, alpha: 1) : #colorLiteral(red: 0.4318677187, green: 0.4149213433, blue: 0.7059496045, alpha: 1)
            pmTimeLabel.textColor = isTaken ? #colorLiteral(red: 0.9636033177, green: 0.5739583373, blue: 0.5747298598, alpha: 1) : #colorLiteral(red: 0.4356096983, green: 0.419034481, blue: 0.7057439685, alpha: 1)
            
            let actionText = (isSpanish == 2) ? (isTaken ? "Tomado" : "Tomar") : (isTaken ? "Taken" : "Take")
            pmTaken.text = actionText
            
            pmTaken.textColor = isTaken ? #colorLiteral(red: 0.9636033177, green: 0.5739583373, blue: 0.5747298598, alpha: 1) : #colorLiteral(red: 0.4356096983, green: 0.419034481, blue: 0.7057439685, alpha: 1)
            
        //VIV start
            
            let today = Calendar.current.startOfDay(for: Date())
            let now = Date()
            let fourDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: today)!
            let isInAllowedWindow = medicationDateParsed >= fourDaysAgo && medicationDateParsed <= today

            if !isInAllowedWindow || !isWithinAllowedRange {
                pmButton.isUserInteractionEnabled = false
                pmButton.layer.borderColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
                pmButton.backgroundColor = #colorLiteral(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
            } else {
                var isFuture = false

                // Restrict future times if date is today
                if Calendar.current.isDate(medicationDateParsed, inSameDayAs: today) {
                    if let medicineDateOnly = dateFormatter.date(from: medicationDate),
                       let hour = Int(eveningAlarm.medicineTime.prefix(2)) {
                        let scheduledTime = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: medicineDateOnly)
                        if let scheduled = scheduledTime, now < scheduled {
                            isFuture = true
                        }
                    }
                }

                if isFuture {
                    pmButton.isUserInteractionEnabled = false
                    pmButton.layer.borderColor = #colorLiteral(red: 0.7843137255, green: 0.7843137255, blue: 0.7843137255, alpha: 1)
                    pmButton.backgroundColor = #colorLiteral(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
                } else {
                    pmButton.isUserInteractionEnabled = true
                    pmButton.layer.borderColor = isTaken ? #colorLiteral(red: 0.9636033177, green: 0.5739583373, blue: 0.5747298598, alpha: 1) : #colorLiteral(red: 0.4318677187, green: 0.4149213433, blue: 0.7059496045, alpha: 1)
                    pmButton.backgroundColor = .clear
                }
            }
            
            //END
            
        } else {
            PMImage.isHidden = true
            pmTaken.isHidden = true
            pmButton.isHidden = true
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

extension Date {
    func toString(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(identifier: Calendar.current.timeZone.identifier)
        return formatter.string(from: self)
    }
}



