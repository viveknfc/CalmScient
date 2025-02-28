//
//  AddUserMedicationsViewController.swift
//  CalmscientIOS
//
//  Created by NFC on 26/04/24.
//

import UIKit


fileprivate enum AddUserMedicationsCellDef:String {
    case textFieldUserEntry = "AddNewMedicationUserEntryTableCell"
    case switchAndTableCell = "AddNewMedicationSwitchTableCell"
    case MedicationsDetailCell = "MedicationsDetailTableCell"
    
    fileprivate func getRowHeight() -> CGFloat {
        switch self {
        case .MedicationsDetailCell : return 96
        case .switchAndTableCell : return 200
        case .textFieldUserEntry : return 80
        }
    }
    
}

class AddUserMedicationsViewController: ViewController, UIAdaptivePresentationControllerDelegate, UISheetPresentationControllerDelegate, MedicationsDetailTableCellDelegate, NewPickerViewDelegate {
    func didChangeSwitchState(for cell: MedicationsDetailTableCell, isSelected: Bool, at index: Int) {
                // Capture the state change and send it to the backend
                let status = isSelected ? "1" : "0"
        print("-----alarm delegate status-----")
        print(status)
        print("the preset alarm count value is",presetAlarm?.count ?? 0)
        
        if EditVc ?? false {
            
            if let presetAlarm = presetAlarm, presetAlarm.indices.contains(index) {
                let alarmData = presetAlarm[index]
                
                alarmData.alarmEnabled = status
                if alarmData.alarmEnabled == "1" {
                    alarmData.isDefault = 1
                }
            }
            
        }
        
        else {
          medicationTimeData[index].alarmEnabled = status
                        if status == "1" {
                            medicationTimeData[index].isDefault = 1
                        }
        }
        
    }
    
    
    var dimmingView: UIView?
    @IBOutlet weak var cancelButton: BorderShadowButton!
    @IBOutlet weak var saveButton: LinearGradientButton!
    @IBOutlet weak var userAddMedicationsTableView: UITableView!
    
    @IBOutlet weak var tableFooter: UIView!
    fileprivate let cellData:[AddUserMedicationsCellDef] = [.textFieldUserEntry,.textFieldUserEntry,.textFieldUserEntry,.textFieldUserEntry,.switchAndTableCell,.MedicationsDetailCell,.MedicationsDetailCell,.MedicationsDetailCell]
    
    let imageNames:[String] = ["Isolation_Mode","afternoonSun","moon"]
    var refreshControlClosure:((Bool)->Void)?
    private var isMedicineWithMeals:Bool = false
    private var userEnteredDetails:[String] = Array(repeating: "", count: 4)
    
    private var medicationTimeData:[MedicationAlarm] = [
        MedicationAlarm.init(alarmTime2: .Morning)!,
        MedicationAlarm.init(alarmTime2: .Afternoon)!,
        MedicationAlarm.init(alarmTime2: .Evening)!
    ]
    private let alarmCellStartIndex = 5
    var saveStr = "Save"
    
    var medicationData:MedicineDetails?
    var EditVc: Bool?
    var medication: String?
    var providerName: String?
    var dosage: String?
    var direction: String?
    var prescriptionId: Int?
    var expiryDate: String?
    var meal: Int?

    var presetAlarm:[MedicationAlarm]?
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.setAttributedTitleWithGradientDefaults(title: "Save")
        cancelButton.setAttributedTitleWithGradientDefaults(title: "Cancel")
        
        userAddMedicationsTableView.tableFooterView = tableFooter
        tableFooter.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 80)
        userAddMedicationsTableView.register(UINib(nibName: "MedicationsDetailTableCell", bundle: nil), forCellReuseIdentifier: "MedicationsDetailTableCell")
        userAddMedicationsTableView.register(UINib(nibName: "AddNewMedicationSwitchTableCell", bundle: nil), forCellReuseIdentifier: "AddNewMedicationSwitchTableCell")
        userAddMedicationsTableView.register(UINib(nibName: "AddNewMedicationUserEntryTableCell", bundle: nil), forCellReuseIdentifier: "AddNewMedicationUserEntryTableCell")
        userAddMedicationsTableView.dataSource = self
        userAddMedicationsTableView.delegate = self
        userAddMedicationsTableView.separatorStyle = .none
        
        if let medicationData = medicationData {
            medication = medicationData.medicationDetailsByDate.first?.medicalDetails.medicineName
            providerName = medicationData.medicationDetailsByDate.first?.medicalDetails.providerName ?? ""
            dosage = medicationData.medicationDetailsByDate.first?.medicalDetails.medicineDosage
            direction = medicationData.medicationDetailsByDate.first?.medicalDetails.directions
            prescriptionId = medicationData.medicationDetailsByDate.first?.medicalDetails.prescriptionID ?? 0
         
            expiryDate = medicationData.medicationDetailsByDate.first?.medicalDetails.endDate ?? ""
            meal = medicationData.medicationDetailsByDate.first?.medicalDetails.withMeal
            
            //viv start
            
            if let firstDetail = medicationData.medicationDetailsByDate.first?.medicalDetails {
                presetAlarm = []
                for schedule in firstDetail.scheduledTimeList {
                    presetAlarm?.append(contentsOf: schedule.scheduledTimes)
//                    medicationTimeData.append(contentsOf: schedule.scheduledTimes) //newly added
                }
            }

            if let alarms = presetAlarm {
                for alarm in alarms {
                    print("Alarm ID: \(alarm.alarmId)")
                }
            }
            //end
            } else {
                print("Medication Data is empty")
            }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Allow table view cell selection
        view.addGestureRecognizer(tapGesture)

    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // Dismiss the keyboard
            return true
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let presentingVC = presentingViewController as? AddUserMedicationsViewController {
            // Hide or remove the dimming view
            presentingVC.dimmingView?.removeFromSuperview()
        }
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.scrollTableViewToBottom()
    }
    func setupLanguage() {
        
        if self.title == nil {
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        self.title = AppHelper.getLocalizeString(str:"Add Medications")
        saveStr = AppHelper.getLocalizeString(str: "Save")
        saveButton.setAttributedTitleWithGradientDefaults(title:AppHelper.getLocalizeString(str:saveStr))
        cancelButton.setAttributedTitleWithGradientDefaults(title:AppHelper.getLocalizeString(str: "Cancel"))
        }

        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLanguage()
    }
    
    
    @IBAction func didClickOnCancelButton(_ sender: Any) {
        let alertController = UIAlertController(title: AppHelper.getLocalizeString(str:"Medications"), message: AppHelper.getLocalizeString(str:"Are you sure you want to cancel?"), preferredStyle: .alert)
        let okAction = UIAlertAction(title: AppHelper.getLocalizeString(str:"YES"), style: .default) { _ in
            // Handle OK button action if needed
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction =  UIAlertAction(title: AppHelper.getLocalizeString(str:"NO"), style: .default)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        // Present the alert
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func DidClickOnSaveButton(_ sender: Any) {
        userAddMedicationsTableView.delegate = self
        view.endEditing(true)
        if doValidation() {
            let medicationData = AddMedication()
            
            for alarm in medicationTimeData {
                print("-----alarm isenabled-----", alarm.alarmEnabled ?? "NA")
                print("-----alarm ID-----", alarm.alarmId)
            }

            medicationData.direction = userEnteredDetails[3]
            medicationData.dosage = userEnteredDetails[2]
            medicationData.provider = userEnteredDetails[1]
            medicationData.medicationName = userEnteredDetails[0]
            medicationData.prescriptionId = prescriptionId ?? 0
            medicationData.providerId = ApplicationSharedInfo.shared.loginResponse?.providerID ?? 0
            medicationData.alarms = self.medicationTimeData
            medicationData.quantity = medicationTimeData.count
            medicationData.withMeal = (isMedicineWithMeals ? 1 : 0)
            medicationData.medicineTime = medicationTimeData.first?.medicineTime ?? "13:30:00"
            
            if let expiryDate = expiryDate {
                medicationData.endDate = expiryDate
            }
            
            var pvcFlag: String {
                return EditVc ?? false ? "U" : "I"
            }
            var iValue: String {
                return EditVc ?? false ? "U" : "I"
            }

            medicationData.pvcFlag = pvcFlag
            
            if let presetAlarms = presetAlarm {
                for index in medicationData.alarms.indices {
                    if index < presetAlarms.count {
                        let alarmData = presetAlarms[index]
                        
                        medicationData.alarms[index].flag = iValue
                        medicationData.alarms[index].isEnabled = Int(presetAlarm?[index].alarmEnabled ?? "0")
                        medicationData.alarms[index].alarmDate = Date().dateToString(format: "MM/dd/yyyy")
                        
                        medicationData.alarms[index].alarmId = alarmData.alarmId
                        medicationData.alarms[index].medicationId = alarmData.medicationId ?? 0
                        medicationData.alarms[index].pmtId = alarmData.pmtId
                        medicationData.alarms[index].medicineTime = presetAlarm?[index].medicineTime ?? "13:30:00"
                        medicationData.alarms[index].isDefault = alarmData.isDefault

                    } else {
                        medicationData.alarms[index].flag = iValue
                        medicationData.alarms[index].isEnabled = Int(medicationTimeData[index].alarmEnabled ?? "0")
                        medicationData.alarms[index].alarmDate = Date().dateToString(format: "MM/dd/yyyy")
                        medicationData.alarms[index].medicationId = 0
                        medicationData.alarms[index].medicineTime = medicationTimeData[index].medicineTime
                    }
                }
            } else {
                
                for index in medicationData.alarms.indices {
                        medicationData.alarms[index].flag = iValue
                        medicationData.alarms[index].isEnabled = Int(medicationTimeData[index].alarmEnabled ?? "0")
                        medicationData.alarms[index].alarmDate = Date().dateToString(format: "MM/dd/yyyy")
                        medicationData.alarms[index].medicationId = 0
                        medicationData.alarms[index].medicineTime = medicationTimeData[index].medicineTime
                }
 
            }
           
            guard let jsonData = try? JSONEncoder().encode(medicationData) else {
                return
            }
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON String: \(jsonString)")
            }
       
            let requestForm = AddMedicationsRequestForm(jsonData)
            guard let requestURL = requestForm.getURLRequest() else {
                self.view.showToast(message:  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "An Unknown error occured. Please check with Admin" : "Se produjo un error desconocido. Consulte con el administrador")
                return
            }
            self.view.showToastActivity()
            NetworkAPIRequest.sendRequest(request: requestURL) { [weak self](response: AddMedicationSavedResponse?, failureResponse: FailureResponse?, error: Error?) in
                DispatchQueue.main.async {
                    guard let self = self else {
                        return
                    }
                    self.view.hideToastActivity()
                    if let err = error {
                        self.view.showToast(message: err.localizedDescription)
                    } else if let response = response {
                        
                        //viv start
                        let title = response.response.responseMessage
                        
                        self.showSuccessAlert(successContent: title, okButtonAction: {

                                print("OK button tapped!")
//                                self.navigationController?.popViewController(animated: true)
                            
                            let next = UIStoryboard(name: "UserMedications", bundle: nil)
                            if #available(iOS 16.0, *) {
                                let vc = next.instantiateViewController(withIdentifier: "UserMedicationsViewController") as? UserMedicationsViewController
                                self.navigationController?.pushViewController(vc!, animated: true)
                            } else {
                                // Fallback on earlier versions
                            }
                            
                            
                                self.refreshControlClosure?(true)
                            
                            
                        })

                    } else if let failureResponse = failureResponse {
                        self.view.showToast(message: failureResponse.statusResponse.responseMessage)
                    }
                }
            }
            
        } else {
            print("enter all details")
//            self.userAddMedicationsTableView.showToast(
//                message: "Please enter all details",
//                point: CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 - 50)
//            )
        }
    }
    
    public func doValidation() -> Bool {
        
        let name = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Medication" : "Medicamentos"
        let provider = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Provider" : "Proveedora"
        let dosage = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Dosage" : "Dosificación"
        let direction = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Direction" : "Dirección"
        let pleaseEnter = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Please enter" : "Por favor ingresa"
        
        
        let detailsMatch:[Int:String] = [0:name,1:provider,2:dosage,3:direction]
        for (idx,detailEntered) in userEnteredDetails.enumerated() {
            if detailEntered.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                self.userAddMedicationsTableView.showToast(message: "\(pleaseEnter) \(detailsMatch[idx]!)!", point: CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2 - 50))
                return false
            }
        }
        return true
    }
    
    private func scrollTableViewToBottom() {
        guard let footerView = userAddMedicationsTableView.tableFooterView else {
            return
        }

        let footerFrameInTableView = userAddMedicationsTableView.convert(footerView.frame, from: footerView.superview)
        userAddMedicationsTableView.scrollRectToVisible(footerFrameInTableView, animated: true)
    }

}
extension AddUserMedicationsViewController : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = cellData[indexPath.row]
        switch cellType {
        case .MedicationsDetailCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MedicationsDetailTableCell", for: indexPath) as! MedicationsDetailTableCell
            cell.dayTimeImageView.image = UIImage(named: "\(imageNames[Int.random(in: 0..<imageNames.count)])")
            
            if EditVc ?? false {
                let indexNumber = indexPath.row - alarmCellStartIndex
                    print("The subset value is", indexNumber)
                if let presetAlarm = presetAlarm, presetAlarm.indices.contains(indexNumber) {
                        let alarmDetails = presetAlarm[indexNumber]
                        cell.updateCellData(medicationAlarm: alarmDetails)
                    } else {
                        print("Preset alarm is either nil or index is out of range.")
                        // Handle the fallback case here, e.g., show a default alarm or a placeholder
                        cell.updateCellData(medicationAlarm: medicationTimeData[indexPath.row - alarmCellStartIndex]) // Assuming nil is a valid input
                    }
            } else {
                cell.updateCellData(medicationAlarm: medicationTimeData[indexPath.row - alarmCellStartIndex])
            }
            
            
            cell.selectionStyle = .none
            cell.cellIndex = indexPath.row - alarmCellStartIndex
            cell.delegate = self
            return cell
            
            //viv start
            
        case .textFieldUserEntry:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddNewMedicationUserEntryTableCell", for: indexPath) as! AddNewMedicationUserEntryTableCell

            // Ensure userEnteredDetails has enough elements
            while userEnteredDetails.count <= indexPath.row {
                userEnteredDetails.append("")
            }

            switch indexPath.row % 4 {
            case 0:
                cell.titleLabel.text = AppHelper.getLocalizeString(str: "Medication")
                cell.cellType = .MedicationName
                if EditVc ?? false, userEnteredDetails[indexPath.row].isEmpty {
                    userEnteredDetails[indexPath.row] = medication ?? ""
                }
            case 1:
                cell.titleLabel.text = AppHelper.getLocalizeString(str: "Provider")
                cell.cellType = .MedicationProvider
                if EditVc ?? false, userEnteredDetails[indexPath.row].isEmpty {
                    userEnteredDetails[indexPath.row] = providerName ?? ""
                }
            case 2:
                cell.titleLabel.text = AppHelper.getLocalizeString(str: "Dosage")
                cell.cellType = .MedicationDosage
                if EditVc ?? false, userEnteredDetails[indexPath.row].isEmpty {
                    userEnteredDetails[indexPath.row] = dosage ?? ""
                }
            case 3:
                cell.titleLabel.text = AppHelper.getLocalizeString(str: "Direction")
                cell.cellType = .MedicationDirection
                if EditVc ?? false, userEnteredDetails[indexPath.row].isEmpty {
                    userEnteredDetails[indexPath.row] = direction ?? ""
                }
            default:
                break
            }

            // Assign stored text to text field
            cell.userEntryTextField.text = userEnteredDetails[indexPath.row]
            cell.selectionStyle = .none
            cell.cellRow = indexPath.row

            // Capture user input without overriding
            cell.userEntryCaptureClosure = { [weak self] (enteredText, Idx) in
                guard let self = self else { return }
                self.userEnteredDetails[Idx] = enteredText
                print("Captured userEnteredDetails: \(self.userEnteredDetails)")
            }

            return cell

            //end

        case .switchAndTableCell:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddNewMedicationSwitchTableCell", for: indexPath) as! AddNewMedicationSwitchTableCell
            cell.selectionStyle = .none
            cell.cellTitleLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "With Meal" : "Con la Comida."
            
            if EditVc ?? false {
                
                cell.expiryTextfield.text = expiryDate
                cell.switchButton.status = (meal == 1)
                cell.scheduleTimeLbl.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?   "Update Time & Alarm" :  "Programar Hora y Alarma."
            } else {
                cell.scheduleTimeLbl.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?   "Schedule Time & Alarm" :  "Programar Hora y Alarma."
            }
            
            
            cell.isMedicationIncluded = {
                [weak self] (canIncludeMedicineWithMeals) in
                print("the meals selection is",canIncludeMedicineWithMeals)
                self?.isMedicineWithMeals = canIncludeMedicineWithMeals
            }
            cell.didTapExpiryTextField = { [weak self] in
                   guard let self = self else { return }
                   print("did expiry text firld tapped")
                dismissKeyboard()
                
                guard let parentViewController = cell.findViewController() else {
                      print("No parent view controller found")
                      return
                  }
                  
                  let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
                  guard let vc = storyboard.instantiateViewController(withIdentifier: "newPickerViewVC") as? newPickerViewVC else {
                      fatalError("Could not instantiate view controller with identifier 'newPickerViewVC'")
                  }
                  
                vc.delegate = self // Assuming this conforms to `newPickerViewVCDelegate`
                vc.indexPath = indexPath
                vc.minimumDate = Date()
                
                  
                  // Add dimming view
                  if let window = UIApplication.shared.windows.first(where: \.isKeyWindow) {
                      let dimmingView = UIView(frame: window.bounds)
                      dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                      dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                      window.addSubview(dimmingView)
                      self.dimmingView = dimmingView
                  }
                  
                  // Configure bottom sheet presentation
                  if #available(iOS 15.0, *) {
                      if let sheet = vc.sheetPresentationController {
                          if #available(iOS 16.0, *) {
                              let customDetent = UISheetPresentationController.Detent.custom { _ in
                                  return 270 // Desired height
                              }
                              sheet.detents = [customDetent]
                          } else {
                              sheet.detents = [.medium()]
                          }
                          sheet.largestUndimmedDetentIdentifier = .medium
                          sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                          sheet.prefersEdgeAttachedInCompactHeight = true
                          sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                          sheet.delegate = self
                      }
                  }
                  
                  vc.isModalInPresentation = true

                  parentViewController.present(vc, animated: true, completion: nil)

               }
            return cell
        }

    }
    
    func didSelectDate(_ date: Date, indexPath: IndexPath?) {
        
        let calendar = Calendar.current
        let resetDate = calendar.startOfDay(for: date)
        
        // Format the selected date as a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        dateFormatter.locale = Locale(identifier: "en_US")  // Set the locale
        dateFormatter.timeZone = TimeZone.current

        let formattedDate = dateFormatter.string(from: resetDate)
        print("The formatted date is:", formattedDate)
        expiryDate = formattedDate
        print("The selected date is:", date)
        
        // If indexPath is provided, update the corresponding cell's text field
        if let indexPath = indexPath {
            if let cell = userAddMedicationsTableView.cellForRow(at: indexPath) as? AddNewMedicationSwitchTableCell {
                cell.expiryTextfield.text = formattedDate
            }
        } else {
            // Handle the case when indexPath is nil (if necessary)
            // For example, you could just print the date or update a different UI element
            print("No indexPath provided, date is \(formattedDate)")
        }
    }


    func didDismissPicker() {
        removeDimmingView()
    }

    private func removeDimmingView() {
        dimmingView?.removeFromSuperview()
        dimmingView = nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = cellData[indexPath.row]
        return cellType.getRowHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = cellData[indexPath.row]
        
        if cellType == .MedicationsDetailCell {

            if EditVc ?? false {
                
                let indexNumber = indexPath.row - alarmCellStartIndex

                if let presetAlarm = presetAlarm, presetAlarm.indices.contains(indexNumber) {
                    checkNotificationPermission(instance: presetAlarm[indexPath.row - alarmCellStartIndex])
                    presetAlarm[indexPath.row - alarmCellStartIndex].dayTime = medicationTimeData[indexPath.row - alarmCellStartIndex].dayTime
                } else {
                    checkNotificationPermission(instance: medicationTimeData[indexPath.row - alarmCellStartIndex])
                }

            } else {
                checkNotificationPermission(instance: medicationTimeData[indexPath.row - alarmCellStartIndex])
            }
           
        }
        
    }
    
    
    
    func requestNotificationPermission(instance:MedicationAlarm) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission granted")
                DispatchQueue.main.async {
                    // UI update code here
                    self.presentModal(instance:instance)
                }
                
            } else {
                print("Permission not granted")
                DispatchQueue.main.async {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    print("Settings opened: \(success)") // Prints true
                                })
                            }
                }
            }
        }
    }
    
    
    func checkNotificationPermission(instance:MedicationAlarm) {
        print("checkNotificationPermission function clicked")
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                // Permission not requested yet, request permission
                print("Permission not requested yet, request permission")
            case .denied:
                // Permission was denied, show an alert to guide the user to settings
                DispatchQueue.main.async {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }
                            
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    print("Settings opened: \(success)") // Prints true
                                })
                            }
                }
            case .authorized, .provisional, .ephemeral:
                // Permission granted or in provisional state
                print("Permission granted")
                DispatchQueue.main.async {
                    // UI update code here
                    self.requestNotificationPermission(instance:instance)
                }
                
            @unknown default:
                break
            }
        }
    }
    
    private func presentModal(instance:MedicationAlarm) {

        // Present the bottom sheet
        let next = UIStoryboard(name: "BottomSheetTimeAndAlarmVC", bundle: nil)
        guard let vc = next.instantiateViewController(withIdentifier: "BottomSheetTimeAndAlarmVC") as? BottomSheetTimeAndAlarmVC else {
            fatalError("Could not instantiate view controller with identifier 'BottomSheetTimeAndAlarmVC'")
        }
        vc.isNewMedicationCreation = true
        vc.newMedicationInstance = instance
        vc.onScheetClosed = { [weak self] in

//            vc.newMedicationInstance?.isDefault = 1
            print("medication time from bottom sheet close is", vc.newMedicationInstance?.medicineTime ?? "NA")
            print("medication default value is", vc.newMedicationInstance?.isDefault ?? 999)
            self?.userAddMedicationsTableView.reloadData()
            self?.dimmingView?.removeFromSuperview()
        }
        
        if EditVc ?? false {
            vc.headingLabelString = AppHelper.getLocalizeString(str:"Update Time & Alarm")
        } else {
            vc.headingLabelString = AppHelper.getLocalizeString(str:"Add Time & Alarm")
        }
        
        vc.medicineDose = userEnteredDetails[2]
        vc.medicineName = userEnteredDetails[0]
        
        // Create a dimming view and add it to the window
        if let window = UIApplication.shared.keyWindow {
            let dimmingView = UIView(frame: window.bounds)
            dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(dimmingView)
            self.dimmingView = dimmingView // Store the reference
        }


        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true

                sheet.delegate = self // To handle delegate methods and adjust dimming view
//                presentationControllerShouldDismiss(sheet)
            }
        } else {
            // Fallback on earlier versions
        }

        present(vc, animated: true, completion: nil)

    }
}

extension AddUserMedicationsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfScreenPresentationController(presentedViewController: presented, presenting: presenting)
    }

}

