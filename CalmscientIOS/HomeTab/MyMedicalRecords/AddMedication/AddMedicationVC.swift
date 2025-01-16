//
//  AddMedicationVC.swift
//  HealthApp
//
//  Created by NFC on 12/03/24.
//




import UIKit

class AddMedicationVC: UIViewController {

    @IBOutlet weak var nameTF: customUITextField!
    @IBOutlet weak var providerTF: customUITextField!
    @IBOutlet weak var dosageTF: customUITextField!
    @IBOutlet weak var directionTF: customUITextField!
    @IBOutlet weak var withMealSwitch: SwitchButton!
    @IBOutlet weak var alarmlistTable: UITableView!
    @IBOutlet weak var providerLbl: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dosageLabel: UILabel!
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var withMealLabel: UILabel!
    @IBOutlet weak var scheduleTimeLabel: UILabel!
    
    var alarmListData: [AlarmData] = [AlarmData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.backButtonTitle = ""
        addCustomBackbutton()
        alarmlistTable.register(UINib(nibName: "AlarmCell", bundle: nil), forCellReuseIdentifier: "AlarmCell")
        setupAlarmMockData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
    }
    
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        self.title = AppHelper.getLocalizeString(str:"Add Medications")
        nameLabel.text = AppHelper.getLocalizeString(str:"Name")
        providerLbl.text = AppHelper.getLocalizeString(str:"Provider")
        dosageLabel.text = AppHelper.getLocalizeString(str:"Dosage")
        dosageLabel.text = AppHelper.getLocalizeString(str:"Direction")
        withMealLabel.text = AppHelper.getLocalizeString(str:"With Meal")
        scheduleTimeLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Schedule Time & Alarm" : "Programar Hora y Alarma"
        }
    func setupAlarmMockData(){
        let alarmMorning = AlarmData(alarmMode: "Morning", medicationTime: "08:00AM", alarmTime: "07:50AM", alarmOnOrOFF: false)
        let alarmNoon = AlarmData(alarmMode: "Afternoon", medicationTime: "08:00AM", alarmTime: "07:50AM", alarmOnOrOFF: true)
        let alarmNight = AlarmData(alarmMode: "Night", medicationTime: "08:00AM", alarmTime: "07:50AM", alarmOnOrOFF: false)
        alarmListData = [alarmMorning, alarmNoon, alarmNight]
    }
    
    @objc func backAction () {
        view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    func addCustomBackbutton(){
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        backButton.setImage(UIImage(named: "BackArrow.png"), for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

}

class AlarmData{
    var alarmMode: String = ""
    var medicationTime: String = ""
    var alarmTime: String = ""
    var alarmOnOrOFF: Bool = false
    
    init(alarmMode: String, medicationTime: String, alarmTime: String, alarmOnOrOFF: Bool) {
        self.alarmMode = alarmMode
        self.medicationTime = medicationTime
        self.alarmTime = alarmTime
        self.alarmOnOrOFF = alarmOnOrOFF
    }
    
}

extension AddMedicationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarmListData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:AlarmCell = self.alarmlistTable.dequeueReusableCell(withIdentifier: "AlarmCell") as! AlarmCell
        //cell.alarmOnOffSwitch = SwitchButton(frame: cell.alarmOnOffSwitch.frame)
        let alarmData = alarmListData[indexPath.row]
        cell.configureCell(celldata: alarmData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presentModal()
    }
    
    private func presentModal() {
    }
    
    
}
