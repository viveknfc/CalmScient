//
//  BottomSheetTimeAndAlarmVC.swift
//  HealthApp
//
//  Created by NFC on 13/03/24.
//

import UIKit
import AVFoundation
import AVFAudio

class BottomSheetTimeAndAlarmVC: UIViewController {
    @IBOutlet weak var headingLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var timeLbl: UILabel!
    
    
    weak var instanceObj:ScheduledTimeList?
    weak var newMedicationInstance:MedicationAlarm?
    var isNewMedicationCreation = false
    
    
    var selectedDays = [Int]()
    var onScheetClosed:(()->Void)?

    var headingLabelString : String = ""
    var medicineName : String = ""
    var medicineDose : String = ""
    var hourTime : Int?
    var minTime : Int?
    var repeatDays : [Int] = []
    var timeIdentifier : String? = ""
    var tempDateTime = ""
    
    
    @IBAction func onDateValueChanged(_ sender: UIDatePicker) {
        tempDateTime = sender.date.dateToString(format: "HH:mm:ss")
    }
    
    
    func convertDaysToNumbers(days: [String]) -> [Int] {
        let dayMapping: [String: Int] = [
            "Sun": 1,
            "Mon": 2,
            "Tue": 3,
            "Wed": 4,
            "Thu": 5,
            "Fri": 6,
            "Sat": 7,
            
            "Dom": 1,
            "Lun": 2,
            "Mar": 3,
            "Mié": 4,
            "Jue": 5,
            "Vie": 6,
            "Sáb" : 7
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
        
        content.sound = UNNotificationSound.criticalSoundNamed(UNNotificationSoundName(rawValue: "bell.mp3"))
        
        if repeatDays.isEmpty {
              let calendar = Calendar.current
              var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date()) // Get today's date
              dateComponents.hour = hour
              dateComponents.minute = minute
              
              let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false) // No repeat
              
              let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
              UNUserNotificationCenter.current().add(request) { error in
                  if let error = error {
                      print("Error scheduling notification: \(error)")
                  }
              }
        } else {
            
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
    
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.headingLabel.text = headingLabelString
        timePicker.timeZone = Calendar.current.timeZone
        timePicker.layer.cornerRadius = 5
        timePicker.layer.masksToBounds = true
        timePicker.backgroundColor = UIColor(named: "AppViewContentColor")
        timePicker.layer.borderColor = UIColor(named: "AppViewBorderColor")?.cgColor
        tableView.layer.cornerRadius = 5
        tableView.layer.masksToBounds = true
        tableView.register(UINib(nibName: "UpdateMedicationsTableViewCell", bundle: nil), forCellReuseIdentifier: "UpdateMedicationsTableViewCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        if isNewMedicationCreation {
            updateWithNewMedicationAlarmInstance()
        } else {
            updateWithUserSelectedDefaults()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        onScheetClosed?()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        timeLbl.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "Time" : "Tiempo"
    }
    
    private func updateWithNewMedicationAlarmInstance() {
        guard let scheduledAlarmObj = self.newMedicationInstance else {
            
            return
        }
        let now = scheduledAlarmObj.medicineTime.createDateFromTimeString()
        print("Current date with time \(now)")
        timePicker.setDate(now, animated: true)
        let dateRestrictions = scheduledAlarmObj.getTimeRestrictionsFromDate()
        print("Date Restricitions are \(dateRestrictions)")
        timePicker.minimumDate = dateRestrictions[0]
        timePicker.maximumDate = dateRestrictions[1]
    }
    
    private func updateWithUserSelectedDefaults() {
        guard let scheduledObj = self.instanceObj?.scheduledTimes.first else {
            return
        }
        guard let medicineDayType = scheduledObj.medicineTime.getDayTimeFromDate(formatter: "HH:mm:ss") else {
            return
        }
        guard let dayTimeValue = DayTimeValue(rawValue: medicineDayType) else {
            return
        }
        var restrictedTimings: [Date] = []
        switch dayTimeValue {
        case .Morning:
            let startTime = "06:00:00".createDateFromTimeString()
            let endTime = "11:59:00".createDateFromTimeString()
            restrictedTimings = [startTime, endTime]
        case .Afternoon:
            let startTime = "12:00:00".createDateFromTimeString()
            let endTime = "16:59:00".createDateFromTimeString()
            restrictedTimings = [startTime, endTime]
        case .Evening:
            let startTime = "17:00:00".createDateFromTimeString()
            let endTime = "23:59:00".createDateFromTimeString()
            restrictedTimings = [startTime, endTime]
        }
        timePicker.minimumDate = restrictedTimings[0]
        timePicker.maximumDate = restrictedTimings[1]
        let alarmDate = scheduledObj.medicineTime.createDateFromTimeString()
        timePicker.setDate(alarmDate, animated: true)
        //        let calendar = Calendar.current
        //        if dayTimeValue == .Morning {
        //            let midnight = calendar.startOfDay(for: alarmDate)
        //            let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: alarmDate)!
        //            timePicker.minimumDate = midnight
        //            timePicker.maximumDate = noon
        //        } else {
        //            let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        //            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        //            timePicker.minimumDate = noon
        //            timePicker.maximumDate = endOfDay
        //
        //        }
        //
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        newMedicationInstance?.isDefault = 0 //1
        if !tempDateTime.isEmpty {
            let newDateTime = tempDateTime
            if isNewMedicationCreation {
                newMedicationInstance?.medicineTime = newDateTime
//                newMedicationInstance?.alarmEnabled = "1"
                timeIdentifier = newMedicationInstance?.getAlarmTime()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm:ss"
                repeatDays = convertDaysToNumbers(days: newMedicationInstance?.repeat ?? [])
                // Convert the string back to a Date object
                if let date = dateFormatter.date(from: (newMedicationInstance?.getAlarmTime())!) {
                    // Extract hour and minute using Calendar
                    let calendar = Calendar.current
                    let hour = calendar.component(.hour, from: date)
                    let minute = calendar.component(.minute, from: date)
                    
                    print("Hour: \(hour), Minute: \(minute)")
                    hourTime = hour
                    minTime = minute
                } else {
                    print("Invalid date format")
                }
            } else {
                guard let scheduledObj = self.instanceObj?.scheduledTimes.first else {
                    return
                }
                scheduledObj.medicineTime = newDateTime
                let alarmTime = Calendar.current.date(byAdding: .minute, value: -(Int(scheduledObj.alarmInterval) ?? 0 ), to: newDateTime.getDate(formatString: "HH:mm:ss"))
                guard var newAlarmDateAndTime = scheduledObj.alarmTime.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespaces).first else {
                    fatalError("Get SPlit Date Failed")
                }
                guard let newAlarmTime = alarmTime?.dateToString(format: "HH:mm:ss") else {
                    fatalError("Get alarm Date Failed")
                }
                
                newAlarmDateAndTime = "\(newAlarmDateAndTime) \(newAlarmTime)"
                scheduledObj.alarmTime = newAlarmDateAndTime
                scheduledObj.alarmEnabled = "1"
                timeIdentifier = scheduledObj.alarmTime
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm:ss"
                // Convert the string back to a Date object
                if let date = dateFormatter.date(from: newAlarmTime) {
                    // Extract hour and minute using Calendar
                    let calendar = Calendar.current
                    let hour = calendar.component(.hour, from: date)
                    let minute = calendar.component(.minute, from: date)
                    
                    print("VIV Hour: \(hour), Minute: \(minute)")
                    print("the time identifier is", timeIdentifier ?? "")
                    hourTime = hour
                    minTime = minute
                    repeatDays = convertDaysToNumbers(days: scheduledObj.repeat )
                } else {
                    print("Invalid date format")
                }
            }
            if let hour = self.hourTime{
                if let minutes = self.minTime{
                    if let timeId = timeIdentifier{
                        
                        scheduleAlarmNotification(hour: hour, minute: minutes, identifier: timeId ,repeatDays: repeatDays )
//                        self.dismiss(animated: true)
                    }
                }
                
            }
        }
        self.dismiss(animated: true)
        
    }
    
    
    
}

extension BottomSheetTimeAndAlarmVC : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isNewMedicationCreation {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateMedicationsTableViewCell", for: indexPath) as? UpdateMedicationsTableViewCell, let timeObj = self.newMedicationInstance else {
                return UITableViewCell()
            }
            cell.isNewMedicationCreation = isNewMedicationCreation
            cell.cellIndex = indexPath.row
            cell.prepareForNewMedicationTiming(medicationAlarm: timeObj)
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateMedicationsTableViewCell", for: indexPath) as? UpdateMedicationsTableViewCell, let timeObj = instanceObj?.scheduledTimes.first else {
                return UITableViewCell()
            }
            cell.isNewMedicationCreation = isNewMedicationCreation
            cell.cellIndex = indexPath.row
            cell.prepareWithCellData(scheduledTime: timeObj)
            cell.selectionStyle = .none
            return cell
        }
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 90
        } else {
            return 115
        }
    }
    
}


class CustomPresentationController: UIPresentationController {
    let presentedHeight: CGFloat

    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, height: CGFloat) {
        self.presentedHeight = height
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return CGRect.zero }
        
        let safeAreaFrame = containerView.bounds.inset(by: containerView.safeAreaInsets)
        let presentedHeight = min(self.presentedHeight, safeAreaFrame.height)
        
        let frame = CGRect(x: 0,
                           y: safeAreaFrame.maxY - presentedHeight,
                           width: safeAreaFrame.width,
                           height: presentedHeight)
        return frame
    }
}

