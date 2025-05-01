//
//  MedicationsDetailViewController.swift
//  MainTabBarApp
//
//  Created by KA on 14/03/24.
//

import UIKit



class MedicationsDetailViewController: ViewController, UISheetPresentationControllerDelegate {
    var dimmingView: UIView?
    @IBOutlet weak var scrennTitleView: UIView!
    @IBOutlet weak var dosageView: UIView!
    @IBOutlet weak var tableTitleLabel: UILabel!
    @IBOutlet weak var medicationsDetailsTableView: UITableView!
    
    @IBOutlet weak var directionLabel: UILabel!
    @IBOutlet weak var dosageLabel: UILabel!
    @IBOutlet weak var doctorTitle: UILabel!
    @IBOutlet weak var medicineTitle: UILabel!
    @IBOutlet weak var directionsValue: UILabel!
    @IBOutlet weak var dosageValue: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    weak var medicineDetails:MedicineDetails? = nil {
        didSet {
            guard let details = medicineDetails?.medicationDetailsByDate.first?.medicalDetails else {
                return
            }
            
            // Filter for isDefault == 1
            let filteredData = details.scheduledTimeList.filter { schedule in
                schedule.scheduledTimes.contains { $0.isDefault == 0 }
            }
            
            // Sort the filtered data by medicineTime
            tableData = filteredData.sorted {
                $0.scheduledTimes.first?.medicineTime ?? "" < $1.scheduledTimes.first?.medicineTime ?? ""
            }
            
//            tableData = details.scheduledTimeList.sorted(by: {
//                $0.scheduledTimes.first?.medicineTime ?? "" < $1.scheduledTimes.first?.medicineTime ?? ""
//            })
//            medicineDetails?.medicationDetailsByDate.first?.medicalDetails.scheduledTimeList = tableData
        }
    }
    
    @IBOutlet weak var cancelButton: BorderShadowButton!
    @IBOutlet weak var saveButton: LinearGradientButton!
    var tableData:[ScheduledTimeList] = []
    let imageNames:[String] = ["sunset","afternoonSun","moon"]
    var headingLabelString = ""
    var saveStr = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        medicationsDetailsTableView.register(UINib(nibName: "MedicationsDetailTableCell", bundle: nil), forCellReuseIdentifier: "MedicationsDetailTableCell")
        medicationsDetailsTableView.dataSource = self
        medicationsDetailsTableView.delegate = self
        medicationsDetailsTableView.reloadData()
        
        dosageView.layer.cornerRadius = 8
        dosageView.layer.masksToBounds = true
        dosageView.layer.borderWidth = 1
        dosageView.layer.borderColor = UIColor(named: "AppViewBorderColor")?.cgColor
     //   saveButton.setAttributedTitleWithGradientDefaults(title:saveStr)
     //   cancelButton.setAttributedTitleWithGradientDefaults(title:AppHelper.getLocalizeString(str: "Cancel"))
        
        dosageLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Dosage" : "Dosificación"
        directionLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Direction" : "Dirección"
        
        guard let details = medicineDetails?.medicationDetailsByDate.first?.medicalDetails else {
            return
        }
        doctorTitle.text = details.providerName
        medicineTitle.text = details.medicineName
        dosageValue.text = details.medicineDosage
        directionsValue.text = details.directions
        
        setupButtonShadows()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = AppHelper.getLocalizeString(str:"Medications detail")
        if let presentingVC = presentingViewController as? AddUserMedicationsViewController {
            // Hide or remove the dimming view
            presentingVC.dimmingView?.removeFromSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableTitleLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Schedule Time & Alarm" : "Programar Hora y Alarma"
    }
    
    private func setupButtonShadows() {
        addShadow(to: editButton)
        addShadow(to: deleteButton)
    }

    private func addShadow(to button: UIButton) {
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        button.layer.masksToBounds = false
    }
    
    //MARK: - Edit Button Action
    
    @IBAction func editButtonPressed(_ sender: Any) {
        
        let next = UIStoryboard(name: "AddUserMedications", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "AddUserMedicationsViewController") as? AddUserMedicationsViewController
        vc?.title = "Edit medications"
        vc?.EditVc = true
        vc?.medicationData = medicineDetails
        print("the medicine details coming to add user VC via medication detail Edit",medicineDetails?.medicationDetailsByDate.first?.medicalDetails.scheduledTimeList.first?.scheduledTimes.first?.alarmId ?? "666")
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    
    
    
    //MARK: - Delete Button Action
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Confirm Deletion",
                                                        message: "Are you sure you want to delete this medication?",
                                                        preferredStyle: .alert)
                
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
cancelAction.setValue(#colorLiteral(red: 0.431, green: 0.420, blue: 0.702, alpha: 1), forKey: "titleTextColor")
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                    self.deleteMedication()
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(deleteAction)
                
                self.present(alertController, animated: true, completion: nil)
    }
    
    private func deleteMedication() {
        if let iD = medicineDetails?.medicationDetailsByDate.first?.medicalDetails.prescriptionID {
            
            let params: [String: Int] = ["prescriptionID": iD]
            
            self.view.showToastActivity()
            APIService.deletMedicationAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
                self.getresponsefordeleteMedicationAPI(response: response)
            }
            
        }
    }
    
    //MARK: - Delete API Response
    
    func getresponsefordeleteMedicationAPI(response:AnyObject)->() {
        if let responseString = response as? String {
            print("Response received from delete Medication API calling is", responseString)
        } else if let responseDict = response as? [String: Any] {

                if let responseMessage = responseDict["responseMessage"] as? String {
                    
                    print("Response Message:", responseMessage)
                    self.view.showToast(message: responseMessage)
                    
                    self.navigationController?.popViewController(animated: true)
                    
                       } else {
                           print("Response Message not found or is not a string.")
                       }

        } else {
            print("Unsupported response type:", type(of: response))
        }

    }
    
    //END
    

}
extension MedicationsDetailViewController : UITableViewDataSource,UITableViewDelegate {
    
    func updateTableViewBackground() {
        if tableData.isEmpty {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: medicationsDetailsTableView.bounds.width, height: medicationsDetailsTableView.bounds.height))
            noDataLabel.text = "No Records Found"
            noDataLabel.textAlignment = .center
            noDataLabel.textColor = .gray
            noDataLabel.font = UIFont.systemFont(ofSize: 16)
            medicationsDetailsTableView.backgroundView = noDataLabel
        } else {
            medicationsDetailsTableView.backgroundView = nil
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updateTableViewBackground()
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicationsDetailTableCell", for: indexPath) as! MedicationsDetailTableCell
        cell.selectionStyle = .none
        cell.cellSwitchImageView.isUserInteractionEnabled = false
        cell.updateCellData(withScheduledTimeList: tableData[indexPath.row], medicineDetails: medicineDetails!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 96
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        presentModal(forInstance: tableData[indexPath.row])
//        checkNotificationPermission(forInstance: tableData[indexPath.row])
    }
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        self.title = AppHelper.getLocalizeString(str:"Add Medications")
        saveStr = AppHelper.getLocalizeString(str: "Save")
        }
    
    
    func requestNotificationPermission(forInstance:ScheduledTimeList) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Permission granted")
                DispatchQueue.main.async {
                    self.presentModal(forInstance:forInstance)
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
    
    
    func checkNotificationPermission(forInstance:ScheduledTimeList) {
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
                    DispatchQueue.main.async {
                        self.requestNotificationPermission(forInstance:forInstance)
                    }
                }
            @unknown default:
                break
            }
        }
    }
    
//    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
//        // Return false to prevent the sheet from dismissing when tapping outside or swiping down
//        return false
//    }
    
    private func presentModal(forInstance:ScheduledTimeList) {
        
        
            let next = UIStoryboard(name: "BottomSheetTimeAndAlarmVC", bundle: nil)
            guard let sheetVC = (next.instantiateViewController(withIdentifier: "BottomSheetTimeAndAlarmVC") as? BottomSheetTimeAndAlarmVC) else {
                return
            }
        
            sheetVC.instanceObj = forInstance
            sheetVC.isNewMedicationCreation = false
            sheetVC.onScheetClosed = {
                [weak self]  in

                self?.dimmingView?.removeFromSuperview()
                self?.medicationsDetailsTableView.reloadData()
                guard let scheduleAlarm = forInstance.scheduledTimes.first else {
                    fatalError("Update Medications failed")
                }
                guard let updatedAlarm = MedicationAlarm(withScheduledTime: scheduleAlarm, medicationID: self?.medicineDetails?.medicationDetailsByDate.first?.medicalDetails.medicationId ?? 0) else {
                    return
                }
                let medAlarmData = OnlyMedicationAlarm()
                medAlarmData.alarms = [updatedAlarm]
                medAlarmData.alarms.first?.flag = "U"
                guard let jsonData = try? JSONEncoder().encode(medAlarmData) else {
                    return
                }
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("JSON String: \(jsonString)")
                }
                
                let requestForm = UpdateMedicationsAlarmRequestForm(jsonData)
                guard let requestURL = requestForm.getURLRequest() else {
                    self?.view.showToast(message: "An Unknown error occured. Please check with Admin")
                    return
                }
                NetworkAPIRequest.sendRequest(request: requestURL) {(response: ResponseDetails?, failureResponse: FailureResponse?, error: Error?) in
                    print(response?.responseMessage ?? "")
                }
            }
        
        
        
        // Create a dimming view and add it to the window
        if let window = UIApplication.shared.keyWindow {
            let dimmingView = UIView(frame: window.bounds)
            dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(dimmingView)
            self.dimmingView = dimmingView // Store the reference
        }


            self.navigationController?.modalPresentationStyle = .pageSheet
            
            if #available(iOS 15.0, *) {
                if let sheet = sheetVC.sheetPresentationController {
                   // sheet.detents = [.large()]
                    sheet.detents = [.medium(), .large()]
                    sheet.prefersGrabberVisible = true
                    sheet.largestUndimmedDetentIdentifier = .medium
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.prefersEdgeAttachedInCompactHeight = true
                    sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                    sheet.delegate = self
                }
            } else {
                
            }
        sheetVC.headingLabelString = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Update Time & Alarm" : "Actualizar Hora y Alarma."
        sheetVC.medicineName = medicineTitle.text ?? ""
        sheetVC.medicineDose = dosageValue.text ?? ""
        
            present(sheetVC, animated: true, completion: nil)
        }
}
