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
    
    var isAMActive = false
    var isPMActive = false
    var isEVActive = false
    
    var isAMTaken: Bool = false
    var isPMTaken: Bool = false
    var isEVTaken: Bool = false
    
    var isExpired: Bool = false
    
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
    
    //MARK: - Update Cell Function
    
    func updateCellWith(MedicalDetails record: MedicineDetails, for timeSlot: TimeSlot) {
        titleLabel.text = record.medicationDetailsByDate[0].medicineName
        subTitleLabel.text = record.medicationDetailsByDate[0].medicalDetails.directions
        expiredLabel.text = isSpanish == 1 ? "Expired" : "Caducado"

        let alarmList = record.medicationDetailsByDate[0].medicalDetails.scheduledTimeList
        let enabledAlarms = alarmList.flatMap { obj in
            obj.scheduledTimes.filter { $0.isDefault == 0 }
        }

        // Date logic
        let calendar = Calendar.current
        let now = Date()
        let fourDaysAgo = calendar.date(byAdding: .day, value: -5, to: now)!
        let medicationDate = record.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let medicationDateParsed = dateFormatter.date(from: medicationDate) else {
            return
        }
        let isWithinAllowedRange = (medicationDateParsed >= fourDaysAgo) && (medicationDateParsed <= now)
        let today = calendar.startOfDay(for: now)
        let fourDaysAgoFromToday = calendar.date(byAdding: .day, value: -5, to: today)!
        let isInAllowedWindow = medicationDateParsed >= fourDaysAgoFromToday && medicationDateParsed <= today

        // Hide all by default
        AMImage.isHidden = true
        amTaken.isHidden = true
        amButton.isHidden = true
        timeLabel.text = ""

        AFImage.isHidden = true
        afTaken.isHidden = true
        afButton.isHidden = true
        afTimeLabel.text = ""

        PMImage.isHidden = true
        pmTaken.isHidden = true
        pmButton.isHidden = true
        pmTimeLabel.text = ""

        switch timeSlot {
        case .morning:
            if let morningAlarm = enabledAlarms.first(where: { $0.medicineTime.isDayTimeAM() }) {
                let timeText = morningAlarm.medicineTime.getDayTimeFromDate(formatter: "HH:mm:ss", includeTimeZone: true) ?? ""
                let isTaken = morningAlarm.medicineTaken == "1"
//                let isFuture = checkIsFutureSlot(for: .morning, now: now, calendar: calendar)
                let isFuture = checkIsFuture(medicationDate: medicationDate, medicineTime: morningAlarm.medicineTime, now: now, calendar: calendar)
                let isDisabled = !isInAllowedWindow || !isWithinAllowedRange || isFuture
                configureButton(isTaken: isTaken, isDisabled: isDisabled, button: amButton, label: amTaken, imageView: AMImage, timeText: timeText, slotType: .morning)
            }

        case .afternoon:
            if let afternoonAlarm = enabledAlarms.first(where: { $0.medicineTime.isDayTimePM() }) {
                let timeText = afternoonAlarm.medicineTime.getDayTimeFromDate(formatter: "HH:mm:ss", includeTimeZone: true) ?? ""
                let isTaken = afternoonAlarm.medicineTaken == "1"
//                let isFuture = checkIsFutureSlot(for: .morning, now: now, calendar: calendar)
                let isFuture = checkIsFuture(medicationDate: medicationDate, medicineTime: afternoonAlarm.medicineTime, now: now, calendar: calendar)
                let isDisabled = !isInAllowedWindow || !isWithinAllowedRange || isFuture
                configureButton(isTaken: isTaken, isDisabled: isDisabled, button: afButton, label: afTaken, imageView: AFImage, timeText: timeText, slotType: .afternoon)
            }

        case .evening:
            if let eveningAlarm = enabledAlarms.first(where: { $0.medicineTime.isDayTimeEvening() }) {
                let timeText = eveningAlarm.medicineTime.getDayTimeFromDate(formatter: "HH:mm:ss", includeTimeZone: true) ?? ""
                let isTaken = eveningAlarm.medicineTaken == "1"
//                let isFuture = checkIsFutureSlot(for: .morning, now: now, calendar: calendar)
                let isFuture = checkIsFuture(medicationDate: medicationDate, medicineTime: eveningAlarm.medicineTime, now: now, calendar: calendar)
                let isDisabled = !isInAllowedWindow || !isWithinAllowedRange || isFuture
                configureButton(isTaken: isTaken, isDisabled: isDisabled, button: pmButton, label: pmTaken, imageView: PMImage, timeText: timeText, slotType: .evening)
            }
        }
    }
    
    //MARK: - Configure Button
    
    func configureButton(isTaken: Bool, isDisabled: Bool, button: UIButton, label: UILabel, imageView: UIImageView, timeText: String, slotType: TimeSlot) {

        imageView.isHidden = false
        label.isHidden = false
        button.isHidden = false
        label.text = timeText
        
        button.isUserInteractionEnabled = !isDisabled
        button.accessibilityValue = isDisabled ? "disabled" : "enabled"
        
        let isActive = !isDisabled
        let takenStatus = isTaken
        
        switch slotType {
        case .morning: isAMActive = isActive; isAMTaken = takenStatus
        case .afternoon: isPMActive = isActive; isPMTaken = takenStatus
        case .evening: isEVActive = isActive; isEVTaken = takenStatus
        }

        if isDisabled {
            button.layer.borderColor = UIColor.gray.cgColor
            button.backgroundColor = UIColor.lightGray
            label.textColor = UIColor.gray
        } else {
            button.layer.borderColor = isTaken ? #colorLiteral(red: 0.9636, green: 0.574, blue: 0.575, alpha: 1) : #colorLiteral(red: 0.432, green: 0.415, blue: 0.706, alpha: 1)
            button.backgroundColor = .clear
            label.textColor = isTaken ? #colorLiteral(red: 0.9636, green: 0.574, blue: 0.575, alpha: 1) : #colorLiteral(red: 0.432, green: 0.415, blue: 0.706, alpha: 1)
        }
    }
    
    func isButtonActive(_ button: UIButton) -> Bool {
        return button.isUserInteractionEnabled && button.accessibilityValue == "enabled"
    }

    
    //MARK: - Check future
    
    func checkIsFutureSlot(for slot: TimeSlot, now: Date, calendar: Calendar) -> Bool {
        let hour = calendar.component(.hour, from: now)

        switch slot {
        case .morning:
            // Morning is future if current time is still before noon
            return hour < 12
        case .afternoon:
            // Afternoon is future if current time is still before evening
            return hour < 18
        case .evening:
            // Evening is future if current time is still before night
            return hour < 24
        }
    }
    
    func checkIsFuture(medicationDate: String, medicineTime: String, now: Date, calendar: Calendar) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let dateOnly = dateFormatter.date(from: medicationDate),
              let hour = Int(medicineTime.prefix(2)) else {
            return false
        }
        
        // ✅ If it's today, always allow
        if calendar.isDateInToday(dateOnly) {
            return false
        }
        
        // If it's the same date but in future compared to now → mark as future
        if let scheduled = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: dateOnly),
           now < scheduled {
            return true
        }
        
        return false
    }

    
    func getSlotInfo(for timeSlot: TimeSlot) -> (isActive: Bool, isTaken: Bool)? {
        switch timeSlot {
        case .morning:
            guard !amButton.isHidden else { return nil }
            return (isAMActive, isAMTaken)
        case .afternoon:
            guard !afButton.isHidden else { return nil }
            return (isPMActive, isPMTaken)
        case .evening:
            guard !pmButton.isHidden else { return nil }
            return (isEVActive, isEVTaken)
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



