//
//  MedicationsDetailTableCell.swift
//  MainTabBarApp
//
//  Created by KA on 14/03/24.
//

import UIKit

protocol MedicationsDetailTableCellDelegate: AnyObject {
    func didChangeSwitchState(for cell: MedicationsDetailTableCell, isSelected: Bool, at index: Int)
    
    func deleteSaveSwitch(for cell: MedicationsDetailTableCell, isSelected: Bool, at index: Int)
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
    
    @IBOutlet weak var timeSelectionButton: UIButton!
    var isAlarmSelected = false
    
    private var defaultImage = UIImage(named: "ToggleSwitch_No")
    private var selectedImage = UIImage(named: "ToggleSwitch_Yes".localized)

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
    
    //MARK: - Alarm Delete / Select Button
    
    @IBAction func alarmSelectionButtonClicked(_ sender: Any) {
        
        print("alarm delete select button pressed")
        isAlarmSelected.toggle() // flip true <-> false
        
        let imageName = isAlarmSelected ? "CellSelectionImage" : "cellUnselectedImage"
        timeSelectionButton.setImage(UIImage(named: imageName), for: .normal)
        
        
        guard let scheduleAlarm = medicationAlarmInstance?.scheduledTimes.first else {
            //for newly created medication
            
            if let index = cellIndex{
                delegate?.deleteSaveSwitch(for: self, isSelected: isAlarmSelected, at: index)
            }
     
            return
        }
        if isAlarmSelected {
            scheduleAlarm.isDefault = 0
        } else {
            scheduleAlarm.isDefault = 1
        }
    
    }
    
    //END
    
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
            self.cellSwitchImageView.image = self.selectedImage
        } else {
            self.cellSwitchImageView.image = self.currentImage
        }

        guard let alarmDayType = scheduledTime.medicineTime.getDayTimeFromDate(formatter: "HH:mm:ss"), let _ = scheduledTime.alarmTime.getDayTimeFromDate(includeTimeZone:true) else {
                return
            }
            guard let dayTypeMatch = DayTimeValue(rawValue: alarmDayType) else {
                return
            }
            guard let medicineTimeShortForm = scheduledTime.medicineTime.getDayTimeFromDate(formatter: "HH:mm:ss", includeTimeZone: true) else {
                return
            }

            leftTitleLabel.text = getTimeStr(timeStr: dayTypeMatch.rawValue)
            rightTitleLabel.text = "Alarm".localized
            leftContentLabel.text = medicineTimeShortForm

        }
    
    func getTimeStr(timeStr:String) -> String{
        
        if(timeStr == "Morning"){
            return "Morning".localized
        }else if(timeStr == "Afternoon"){
            return "Afternoon".localized
        }else{
            return "Evening".localized
        }
    }
        
        func updateCellData(medicationAlarm:MedicationAlarm) {
            if medicationAlarm.alarmEnabled == "1" {
                print("Alarm is enabled for this medication", medicationAlarm.alarmId)
                buttonState = .selected
                medicationAlarm.isDefault = 0
            } else {
                print("Alarm is not enabled for this medication", medicationAlarm.alarmId)
                buttonState = .dafault
            }
            
            let imageName = medicationAlarm.isDefault == 0 ? "CellSelectionImage" : "cellUnselectedImage"
            isAlarmSelected = medicationAlarm.isDefault == 0 ? true : false
            if let image = UIImage(named: imageName) {
                timeSelectionButton.setImage(image, for: .normal)
            } else {
                print("⚠️ Image not found: \(imageName)")
            }
            
            self.cellSwitchImageView.image = self.currentImage
//            self.dayTimeImageView.image = medicationAlarm.getDayTime().getIconImage()
            leftTitleLabel.text = getTimeStr(timeStr:medicationAlarm.getDayTime().rawValue)
            rightTitleLabel.text =  "Alarm".localized
            leftContentLabel.text = medicationAlarm.getMedicineTimeWithAMorPM()
//            rightContentLabel.text =  medicationAlarm.getAlarmTimeWithAMOrPM()
        }
    
}
