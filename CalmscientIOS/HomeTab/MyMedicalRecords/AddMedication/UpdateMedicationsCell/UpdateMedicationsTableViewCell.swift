//
//  UpdateMedicationsTableViewCell.swift
//  CalmscientIOS
//
//  Created by NFC on 27/04/24.
//

import UIKit


fileprivate enum collectionCellType {
    case alarmCell
    case weekCell
    
    func getCellData() -> [String] {
        switch self {
        case .alarmCell:
            return ["05","10","15","20","25","30"]
        case .weekCell:
            return ["S","M","T","W","T","F","S"]
        }
    }
    
    func getCellValues() -> [String] {
        switch self {
        case .alarmCell:
            return ["05","10","15","20","25","30"]
        case .weekCell:
            
            return UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?   ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"] : ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]
        }
    }
    
    //[content,border,text]
    func getCellColors() -> [UIColor?] {
        switch self {
        case .alarmCell:
            return [UIColor(named: "medicationsWeekCellColor"),UIColor(named: "medicationsWeekCellColor"),UIColor(named: "medicationscelldefaulttextcolor"),UIColor(named: "medicationsSelectedColor"),UIColor(named: "medicationsSelectedColor"),UIColor.white]
        case .weekCell:
            return [UIColor(named: "medicationsWeekCellColor"),UIColor(named: "medicationsWeekCellColor"),UIColor(named: "medicationscelldefaulttextcolor"),UIColor(named: "medicationsSelectedColor"),UIColor(named: "medicationsSelectedColor"),UIColor.white]
        }
    }
}

class UpdateMedicationsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var subTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var subTitleBottompadding: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    fileprivate var cellType : collectionCellType = .alarmCell
    
    var isNewMedicationCreation = false

    weak var scheduledTime:ScheduledTimes?
    weak var medicationAlarm:MedicationAlarm?
    
    let customOrder: [String: Int] = [
        "Sun": 0,
        "Mon": 1,
        "Tue": 2,
        "Wed": 3,
        "Thu": 4,
        "Fri": 5,
        "Sat": 6,
        
        "Dom": 0,
        "Lun": 1,
        "Mar": 2,
        "Mié": 3,
        "Jue": 4,
        "Vie": 5,
        "Sáb": 6
    ]
    
    var cellIndex:Int = 0 {
        didSet {
            if cellIndex == 1 {
                titleLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Repeat" : "Repetir"
                subTitleHeight.constant = 15
                subTitleBottompadding.constant = 4
                cellType = .weekCell
            } else {
                titleLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "Alarm" : "Alarma"
                subTitleHeight.constant = 0
                subTitleBottompadding.constant = 0
                cellType = .alarmCell
            }
            collectionView.reloadData()
        }
    }
    
    private var selectedIndexes:[Int] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "CustomCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        collectionView.contentInset = .zero
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func prepareWithCellData(scheduledTime:ScheduledTimes) {
        self.scheduledTime = scheduledTime
        let selectedOnes = cellType.getCellValues()
        
        if cellType == .alarmCell {
            if let indexOfSelection = selectedOnes.firstIndex(of: scheduledTime.alarmInterval) {
                selectedIndexes.removeAll()
                selectedIndexes.append(indexOfSelection)
            }
        } else {
            selectedIndexes.removeAll()
            for obj in scheduledTime.repeatDay {
                if let indexOfSelection = selectedOnes.firstIndex(of: obj) {
                    selectedIndexes.append(indexOfSelection)
                }
            }
            guard let currentInstance = self.scheduledTime else {
                return
            }
            if currentInstance.repeatDay.count == 7 {
                subTitleLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "EveryDay" : "todos los días."
            } else {
                subTitleLabel.text = currentInstance.repeatDay.joined(separator: ",")
            }
        }
        selectedIndexes.sort()
        collectionView.reloadData()
    }
    
    public func prepareForNewMedicationTiming(medicationAlarm:MedicationAlarm) {
        self.medicationAlarm = medicationAlarm
        let selectedOnes = cellType.getCellValues()

        if cellType == .alarmCell {
            if let indexOfSelection = selectedOnes.firstIndex(of: medicationAlarm.getAlarmIntervalStringValue()) {
                selectedIndexes.removeAll()
                selectedIndexes.append(indexOfSelection)
            }
        } else {
            selectedIndexes.removeAll()
            for obj in medicationAlarm.repeat {
                if let indexOfSelection = selectedOnes.firstIndex(of: obj) {
                    selectedIndexes.append(indexOfSelection)
                }
            }
            guard let currentInstance = self.medicationAlarm else {
                return
            }
            if currentInstance.repeat.count == 7 {
                subTitleLabel.text =  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "EveryDay" : "todos los días."
            } else {
                subTitleLabel.text = currentInstance.repeat.joined(separator: ",")
            }
        }
        selectedIndexes.sort()
        collectionView.reloadData()
    }
    
}

extension UpdateMedicationsTableViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellType.getCellData().count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as? CustomCollectionViewCell else {
            return UICollectionViewCell()
        }
        let colors = cellType.getCellColors()
        if selectedIndexes.contains(indexPath.row) {
            cell.circleFillColor = colors[3]
            cell.circleStrokeColor = colors[4]
            cell.contentTextColor = colors[5]
        } else {
            cell.circleFillColor = colors[0]
            cell.circleStrokeColor = colors[1]
            cell.contentTextColor = colors[2]
        }
        cell.setCircleText(text: cellType.getCellData()[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the size of each item in your collection view
        let height = collectionView.frame.height - 10
        return CGSize(width: height, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isNewMedicationCreation {
            guard let currentInstance = self.medicationAlarm else {
                return
            }
            if cellType == .alarmCell {
                selectedIndexes.removeAll()
                selectedIndexes.append(indexPath.row)
                currentInstance.alarmInterval = Int(cellType.getCellData()[indexPath.row]) ?? 5
            } else {
                if selectedIndexes.contains(indexPath.row) {
                    let selectedIdx = selectedIndexes.firstIndex(of: indexPath.row)
                    selectedIndexes.remove(at: selectedIdx!)
                } else {
                    selectedIndexes.append(indexPath.row)
                }
                currentInstance.repeat = getRepeatValues()
                if currentInstance.repeat.count == 7 {
                    subTitleLabel.text =  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "EveryDay" : "todos los días."
                } else {
                    subTitleLabel.text = currentInstance.repeat.joined(separator: ",")
                }
            }
            print("ADD MED Alarm Interval: \(currentInstance.alarmInterval)")
            print("ADD MED Alarm Day: \(currentInstance.repeat)")
            selectedIndexes.sort()
            collectionView.reloadData()
        } else {
            guard let currentInstance = self.scheduledTime else {
                return
            }
            currentInstance.alarmEnabled = "1"
            if cellType == .alarmCell {
                selectedIndexes.removeAll()
                selectedIndexes.append(indexPath.row)
                currentInstance.alarmInterval = cellType.getCellData()[indexPath.row]
               guard let scheduledObj = self.scheduledTime else {
                    return
                }
                let alarmTime = Calendar.current.date(byAdding: .minute, value: -(Int(scheduledObj.alarmInterval) ?? 0), to: scheduledObj.medicineTime.getDate(formatString: "HH:mm:ss"))
                guard var newAlarmDateAndTime = scheduledObj.alarmTime.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespaces).first else {
                    fatalError("Get SPlit Date Failed")
                }
                guard let newAlarmTime = alarmTime?.dateToString(format: "HH:mm:ss") else {
                    fatalError("Get alarm Date Failed")
                }
                newAlarmDateAndTime = "\(newAlarmDateAndTime) \(newAlarmTime)"
                scheduledObj.alarmTime = newAlarmDateAndTime
            } else {
                if selectedIndexes.contains(indexPath.row) {
                    let selectedIdx = selectedIndexes.firstIndex(of: indexPath.row)
                    selectedIndexes.remove(at: selectedIdx!)
                } else {
                    selectedIndexes.append(indexPath.row)
                }
                currentInstance.repeatDay = getRepeatValues()
                if currentInstance.repeatDay.count == 7 {
                    subTitleLabel.text =  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "EveryDay" : "todos los días."
                } else {
                    subTitleLabel.text = currentInstance.repeatDay.joined(separator: ",")
                }
            }
            selectedIndexes.sort()
            collectionView.reloadData()
        }
    }
    
    private func getRepeatValues() -> [String]{
        let obj = cellType.getCellValues()
        var selectedDate:[String] = []
        if cellType == .weekCell {
            for idxObj in selectedIndexes {
                selectedDate.append(obj[idxObj])
            }
        }
        return selectedDate.sorted(by: {customOrder[$0]! < customOrder[$1]!})
    }
    
}
