//
//  MedicationsDetailTableCell.swift
//  MainTabBarApp
//
//  Created by KA on 14/03/24.
//

import UIKit

protocol MedicationsDetailTableCellDelegate: AnyObject {
    func didChangeSwitchState(for cell: MedicationsDetailTableCell, isSelected: Bool, at index: Int)
}

class MedicationsDetailTableCell: UITableViewCell {

    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var dayTimeImageView: UIImageView!
    @IBOutlet weak var leftTitleLabel: UILabel!
    @IBOutlet weak var leftContentLabel: UILabel!
    
    @IBOutlet weak var rightContentLabel: UILabel!
    
    @IBOutlet weak var rightTitleLabel: UILabel!
    var cellIndex : Int?
    @IBOutlet weak var cellSwitchImageView: UIImageView!
    
    private var defaultImage = UIImage(named: "ToggleSwitch_No")
    private var selectedImage = UIImage(named: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "ToggleSwitch_Yes" : "ToggleSwitch_Si")

    private var currentImage:UIImage? = UIImage(named: "ToggleSwitch_No")
    private weak var medicationAlarmInstance:ScheduledTimeList?
    private weak var medicineDetails:MedicineDetails?
    public var isCellSelected = false {
        didSet {
            if isCellSelected {
                currentImage = selectedImage
            } else {
                currentImage = defaultImage
            }
        }
    }
    private var buttonState:SelectionButtonState = .dafault {
        didSet {
            self.isCellSelected = (buttonState == .selected)
        }
    }
    
    

    weak var delegate: MedicationsDetailTableCellDelegate?
        
    @IBAction func didTapOnSelectionButton(_ sender: UITapGestureRecognizer) {
        if buttonState == .dafault {
                   buttonState = .selected
               } else {
                   buttonState = .dafault
               }
               UIView.transition(with: cellSwitchImageView, duration: 0.3, options: .transitionCrossDissolve) {
                   self.cellSwitchImageView.image = self.currentImage
               }
        
               guard let scheduleAlarm = medicationAlarmInstance?.scheduledTimes.first else {
                   //for newly created medication 
                   
                   if let index = cellIndex{
                       delegate?.didChangeSwitchState(for: self, isSelected: isCellSelected, at: index)
                   }
                           
                       
                   return
               }
               if buttonState == .dafault {
                   scheduleAlarm.alarmEnabled = "0"
                   
                       //to disable alarm
                       deleteAlarmNotification(identifier: scheduleAlarm.alarmTime)
                   
                   
               } else {
                   scheduleAlarm.alarmEnabled = "1"
               }
               guard let updatedAlarm = MedicationAlarm(withScheduledTime: scheduleAlarm, medicationID: self.medicineDetails?.medicationDetailsByDate.first?.medicalDetails.medicationId ?? 0) else {
                   return
               }
               
               let medAlarmData = OnlyMedicationAlarm()
               medAlarmData.alarms = [updatedAlarm]
               guard let jsonData = try? JSONEncoder().encode(medAlarmData) else {
                   return
               }
               if let jsonString = String(data: jsonData, encoding: .utf8) {
                   print("From did tap selection JSON String: \(jsonString)")
               }
               
               let requestForm = UpdateMedicationsAlarmRequestForm(jsonData)
               guard let requestURL = requestForm.getURLRequest() else {
                   return
               }
               NetworkAPIRequest.sendRequest(request: requestURL) {(response: ResponseDetails?, failureResponse: FailureResponse?, error: Error?) in
                   print(response?.responseMessage ?? "")
               }
    }
    
    func deleteAlarmNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func convertDaysToNumbers(days: [String]) -> [Int] {
        let dayMapping: [String: Int] = [
            "Sun": 1,
            "Mon": 2,
            "Tue": 3,
            "Wed": 4,
            "Thu": 5,
            "Fri": 6,
            "Sat": 7
        ]
        
        let dayNumbers = days.compactMap { dayMapping[$0] }
        return dayNumbers
    }
    
    func scheduleAlarmNotification(hour: Int, minute: Int, identifier: String, repeatDays: [Int]) {
        let content = UNMutableNotificationContent()
        content.title = "Medication Alert"
        content.body = "Please take your medication to stay healthy"
        content.categoryIdentifier = "ALARM_CATEGORY"
        
        if #available(iOS 15.0, *) {
            content.interruptionLevel = .critical
        } else {
            // Fallback on earlier versions
        }
        
        content.sound = UNNotificationSound.criticalSoundNamed(
            UNNotificationSoundName(rawValue: "bell.mp3")
        )
        
//        content.sound = UNNotificationSound.criticalSoundNamed(UNNotificationSoundName(rawValue: "bell.mp3"))
        
        for day in repeatDays {
            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = minute
            dateComponents.weekday = day  // Sunday is 1, Monday is 2, ..., Saturday is 7
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(identifier: "\(identifier)_\(day)", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        buttonState = .dafault
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowAndBorder()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.didTapOnSelectionButton(_:)))
        self.cellSwitchImageView.isUserInteractionEnabled = true
        self.cellSwitchImageView.addGestureRecognizer(tapGestureRecognizer)
        isCellSelected = false
        buttonState = .dafault
        self.cellSwitchImageView.image = self.currentImage
        // Initialization code
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
    }

    func updateCellData(withScheduledTimeList data:ScheduledTimeList, medicineDetails:MedicineDetails?) {
            self.medicineDetails = medicineDetails
            medicationAlarmInstance = data
            guard let scheduledTime = data.scheduledTimes.first else {
                return
            }
            if scheduledTime.alarmEnabled == "1" {
                buttonState = .selected
                
                ///////////////////////////////////////////////
                // To add alarm if your tapped on swiitch to "yes" in medication configaration
                ///////////////////////////////////////////////
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                 
                // Convert the string back to a Date object
                if let date = dateFormatter.date(from: scheduledTime.alarmTime) {
                    // Extract hour and minute using Calendar
                    let calendar = Calendar.current
                    let hour = calendar.component(.hour, from: date)
                    let minute = calendar.component(.minute, from: date)
                    
                    print("Hour: \(hour), Minute: \(minute)")
                    scheduleAlarmNotification(hour: hour, minute: minute, identifier: scheduledTime.alarmTime, repeatDays: convertDaysToNumbers(days: scheduledTime.repeat ))
                } else {
                    print("Invalid date format")
                    
                }
                //////////////////////////////////////////////
                ///
                //////////////////////////////////////////////
                
            } else {
                buttonState = .dafault
                // to remove alarm if user tapped on swiitch to "No"
                deleteAlarmNotification(identifier: scheduledTime.alarmTime)
                
            }
            self.cellSwitchImageView.image = self.currentImage
            guard let alarmDayType = scheduledTime.medicineTime.getDayTimeFromDate(formatter: "HH:mm:ss"), let alarmDayTypeShortForm = scheduledTime.alarmTime.getDayTimeFromDate(includeTimeZone:true) else {
                return
            }
            guard let dayTypeMatch = DayTimeValue(rawValue: alarmDayType) else {
                return
            }
            guard let medicineTimeShortForm = scheduledTime.medicineTime.getDayTimeFromDate(formatter: "HH:mm:ss", includeTimeZone: true) else {
                return
            }
            self.dayTimeImageView.image = dayTypeMatch.getIconImage()
            leftTitleLabel.text = getTimeStr(timeStr: dayTypeMatch.rawValue)
            rightTitleLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Alarm" : "Alarma"
            leftContentLabel.text = medicineTimeShortForm
            rightContentLabel.text = alarmDayTypeShortForm
        }
    
    func getTimeStr(timeStr:String) -> String{
        
        if(timeStr == "Morning"){
            return UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Morning" : "Mañana"
        }else if(timeStr == "Afternoon"){
            return UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Afternoon" : "Tarde"
        }else{
            return UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Evening" : "Noche"
        }
    }
        
        func updateCellData(medicationAlarm:MedicationAlarm) {
            if medicationAlarm.alarmEnabled == "1" {
                buttonState = .selected
            } else {
                buttonState = .dafault
            }
            self.cellSwitchImageView.image = self.currentImage
            self.dayTimeImageView.image = medicationAlarm.getDayTime().getIconImage()
            leftTitleLabel.text = getTimeStr(timeStr:medicationAlarm.getDayTime().rawValue)
            rightTitleLabel.text =  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Alarm" : "Alarma"
            leftContentLabel.text = medicationAlarm.getMedicineTimeWithAMorPM()
            rightContentLabel.text =  medicationAlarm.getAlarmTimeWithAMOrPM()
        }
    
}
