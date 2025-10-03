//
//  UserMedicationsViewController.swift
//  MainTabBarApp
//
//  Created by KA on 13/03/24.
//

import UIKit
import FSCalendar

enum TimeSlot {
    case morning
    case afternoon
    case evening
}

@available(iOS 16.0, *)
class UserMedicationsViewController: ViewController, NCalendarToViewDelegate, CustomTableViewCellDelegate {    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var networkHandler:NetworkAPIRequest = NetworkAPIRequest()
    @IBOutlet weak var calendar: NewCalender!
    @IBOutlet weak var addMedicationsButton: UIButton!
    @IBOutlet weak var saveButton: LinearGradientButton!
    @IBOutlet weak var medicationsTableView: UITableView!
    
    @IBOutlet weak var infoLabel: FontLL12!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    var medicationData:[MedicineDetails] = []
    var medicationToDelete: MedicalDetails?
    
    private var selectedNewDate: Date = {
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(identifier: "UTC")! // Force UTC time zone
        return utcCalendar.startOfDay(for: Date())
    }()

    @IBOutlet weak var tabBarButton: UISegmentedControl!
    var selectedTimeSlot: TimeSlot = .morning
    
    var nomedications = UILabel()
    var combinedDateTime = [String]()
    
    @IBOutlet weak var takeAllButton: UIButton!
    
    var isMedicineTaken = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.calendarToViewDelegate = self
        addMedicationsButton.imageView?.contentMode = .scaleAspectFill
        medicationsTableView.register(UINib(nibName: "UserMedicationsTableCell", bundle: nil), forCellReuseIdentifier: "UserMedicationsTableCell")
        medicationsTableView.dataSource = self
        medicationsTableView.delegate = self
        
        infoLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Please select the medication you are currently taking." : "Selecciona el medicamento de la lista si lo has tomado hoy"
        
        nomedications.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "No Records" : "No hay registros"
        nomedications.textAlignment = .center
        nomedications.font = UIFont(name: Fonts().lexendMedium, size: 18)

                // Add the label to the view
        view.addSubview(nomedications)

                // Disable autoresizing mask translation
        nomedications.translatesAutoresizingMaskIntoConstraints = false

                // Center the label horizontally and vertically
                NSLayoutConstraint.activate([
                    nomedications.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    nomedications.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
        self.nomedications.isHidden = true
        // Do any additional setup after loading the view.

        //start

        self.navigationController?.navigationBar.isHidden = false
        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)

        // Create a UIButton
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonOverrideAction), for: .touchUpInside)

        // Set constraints to adjust the size
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true // Set desired width
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true // Set desired height

        // Create a UIBarButtonItem using the UIButton
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        //end
        saveButton.isHidden = true
        
        // Rounded capsule look for entire control
        tabBarButton.layer.cornerRadius = tabBarButton.frame.height / 2
        tabBarButton.layer.masksToBounds = false
        
        tabBarButton.layer.borderWidth = 1
        tabBarButton.layer.borderColor = #colorLiteral(red: 0.9607843757, green: 0.9607843757, blue: 0.9607843757, alpha: 1)
        
        tabBarButton.backgroundColor = .clear
        tabBarButton.selectedSegmentTintColor = #colorLiteral(red: 0.432, green: 0.415, blue: 0.706, alpha: 1)
        
        let normalTextAttributes = [NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.432, green: 0.415, blue: 0.706, alpha: 1)]
        let selectedTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        tabBarButton.setTitleTextAttributes(normalTextAttributes, for: .normal)
        tabBarButton.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        tabBarButton.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        takeAllButton.layer.borderColor = #colorLiteral(red: 0.432, green: 0.415, blue: 0.706, alpha: 1).cgColor
        takeAllButton.layer.borderWidth = 1
        takeAllButton.layer.cornerRadius = 13
        
        medicationsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)
    }
    
    //MARK: - Segment Change
    
    @objc func segmentChanged() {
        switch tabBarButton.selectedSegmentIndex {
        case 0:
            selectedTimeSlot = .morning
        case 1:
            selectedTimeSlot = .afternoon
        case 2:
            selectedTimeSlot = .evening
        default:
            break
        }
        
        medicationsTableView.reloadData()
        
        DispatchQueue.main.async {
            self.updateTakeAllButtonFromCells(for: self.selectedTimeSlot)
        }
    }
    
    //MARK: - Take All Button Pressed
    
    @IBAction func takeAllButtonPressed(_ sender: Any) {

        print("take all button pressed")
        
        let status = slotStatus(for: selectedTimeSlot)
        let currentlyAllTaken = status.allTaken
        let newTakenState = !currentlyAllTaken   // toggle
        
        var allPmtIds: [String] = []
        var allmedicineTakenID: [Int] = []
        var medicationdatetime: [String] = []
        
        for medication in medicationData {
            if let medicalDetails = medication.medicationDetailsByDate.first?.medicalDetails {
                
                if medicalDetails.expired == 1 {
                    continue
                }
                
                for scheduled in medicalDetails.scheduledTimeList {
                    for time in scheduled.scheduledTimes {
                        
                        var shouldInclude = false
                        
                        // 🔑 Filter based on selected slot
                        switch selectedTimeSlot {
                        case .morning:
                            shouldInclude = time.medicineTime.isDayTimeAM()
                        case .afternoon:
                            shouldInclude = time.medicineTime.isDayTimePM()
                        case .evening:
                            shouldInclude = time.medicineTime.isDayTimeEvening()
                        }
                        
                        if shouldInclude {
                                
                                allPmtIds.append(time.pmtId)
                                
                                allmedicineTakenID.append(time.medicineTakenID ?? 0)
                                
                                // Format date properly for each pmtId
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "MM/dd/yyyy"
                                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                
                                if let date = dateFormatter.date(from: medication.date) {
                                    let outputFormatter = DateFormatter()
                                    outputFormatter.dateFormat = "yyyy-MM-dd"
                                    let formattedDate = outputFormatter.string(from: date)
                                    
                                    let combined = "\(formattedDate) \(time.medicineTime)"
                                    medicationdatetime.append(combined) // ✅ add per record
                                }
                            
                        }
                    }
                }
            }
        }

//        let isMedicineTaken = takeAllButton.titleLabel?.text == "Taken"
//        let medicineTaken = isMedicineTaken ? "0" : "1"
        
        let medicineTaken = newTakenState ? "1" : "0"

        callForMarkMedication(
            pmtId: allPmtIds,
            medicineTaken: medicineTaken,
            medicationdatetime: medicationdatetime,
            medicineTakenId: allmedicineTakenID
        )
        
    }

    
    
    //MARK: - MARK Medication API Call
    
    func didTapTakenButton(in cell: UITableViewCell, buttonType: ButtonType) {
        guard let customCell = cell as? UserMedicationsTableCell else { return }
        
        let tappedButton: UIButton
        switch buttonType {
        case .first: tappedButton = customCell.amButton
        case .second: tappedButton = customCell.afButton
        case .third: tappedButton = customCell.pmButton
        }
        
        // ✅ Instead of recalculating, just trust cell’s state
        guard customCell.isButtonActive(tappedButton) else {
            print("⏰ Cannot mark this dose yet. Disabled state (from cell)")
            return
        }
        
        // --- proceed with your API call using cell/record data ---
        guard let indexPath = medicationsTableView.indexPath(for: cell) else { return }
        let medicationRecord = medicationData[indexPath.row]
        guard let medicalDetails = medicationRecord.medicationDetailsByDate.first?.medicalDetails else { return }

        let scheduledIndex = buttonType.scheduledIndex
        guard let scheduledTimes = medicalDetails.scheduledTimeList[scheduledIndex].scheduledTimes.first else { return }

        let medicineTaken = (scheduledTimes.medicineTaken == "1") ? "0" : "1"
        let pmtId = scheduledTimes.pmtId
        let takenId = scheduledTimes.medicineTakenID ?? 0
        let responseTime = scheduledTimes.medicineTime
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        guard let medicationDateParsed = dateFormatter.date(from: medicationRecord.date) else { return }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        let formattedDate = outputFormatter.string(from: medicationDateParsed)
        let combinedDateTime = ["\(formattedDate) \(responseTime)"]
        
        callForMarkMedication(
            pmtId: [pmtId],
            medicineTaken: medicineTaken,
            medicationdatetime: combinedDateTime,
            medicineTakenId: [takenId]
        )
        
        print("✅ Marked medication (trusted cell state). PMT ID: \(pmtId), Taken: \(medicineTaken), Time: \(combinedDateTime)")
    }
    
    func checkIsFuture(medicationDate: String, medicineTime: String) -> Bool {
        let dateTimeString = "\(medicationDate) \(medicineTime)"
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        // Use local time zone (system default)
        formatter.timeZone = TimeZone.current

        guard let scheduledDate = formatter.date(from: dateTimeString) else { return false }
        return scheduledDate > Date()
    }
    
    func callForMarkMedication(pmtId: [String], medicineTaken: String, medicationdatetime: [String], medicineTakenId: [Int]) {
        
        let pmtIdInt = pmtId.compactMap { Int($0) }
        
        if let medicineTakenInt = Int(medicineTaken)  {
            let params: [String: Any] = ["pmtId": pmtIdInt, "medicineTaken": medicineTakenInt, "medicationdatetime": medicationdatetime, "medicineTakenId": medicineTakenId]
            print("Params of mark medeication is :", params)
            self.view.showToastActivity()
            APIService.MarkMedicationAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") {  [self] response in
                // Your closure code here
                getresponseforMarkMedicationAPI(response: response)
            }
        } else {
            print("Error: Unable to convert pmtId or medicineTaken to Int.")
        }
        
    }
    
    //MARK: - Mark Medication API Response
    
    func getresponseforMarkMedicationAPI(response:AnyObject)->() {
        
        if let responseDict = response as? [String: Any],
           let responseCode = responseDict["responseCode"] as? Int,
           responseCode == 200 {
            print("medine updation success")
            print("response is ", responseDict)
            
            self.showSuccessAlert(successContent: responseDict["responseMessage"] as? String, centreImage: nil) { [self] in
                getMedicationsData(forDate: selectedNewDate)
            }
            
        } else {
            print("Failed to mark medication. Response: \(response)")
            getMedicationsData(forDate: selectedNewDate)
            self.view.hideToastActivity()
        }
    }
    
    //END
    
    //MARK: - Edit Button Tapped
    
    func didTapEditButton(in cell: UITableViewCell) {
        if let indexPath = self.medicationsTableView.indexPath(for: cell) {
            print("Edit button tapped for row \(indexPath.row)")
            let next = UIStoryboard(name: "AddUserMedications", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "AddUserMedicationsViewController") as? AddUserMedicationsViewController
            vc?.title = "Edit medications"
            vc?.EditVc = true
            vc?.medicationData = medicationData[indexPath.row]
            vc?.refreshControlClosure = {[weak self] flag in
                print("the selected new date is ",self?.selectedNewDate as Any)
                self?.getMedicationsData(forDate: self?.selectedNewDate ?? Date())
            }
            self.navigationController?.pushViewController(vc!, animated: true)
            // Handle edit action
        }
    }
    
    //END
    
    //MARK: - Delete Button API

    func didTapDeleteButton(in cell: UITableViewCell) {
        if let indexPath = self.medicationsTableView.indexPath(for: cell) {
            
            let alertController = UIAlertController(title: AppHelper.getLocalizeString(str: "Confirm Deletion"),
                                                            message: AppHelper.getLocalizeString(str: "Are you sure you want to delete this medication?"),
                                                            preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: AppHelper.getLocalizeString(str: "No"), style: .cancel, handler: nil)
            cancelAction.setValue(#colorLiteral(red: 0.431, green: 0.420, blue: 0.702, alpha: 1), forKey: "titleTextColor") // Hex: #6e6bb3
                    let deleteAction = UIAlertAction(title: AppHelper.getLocalizeString(str: "Yes"), style: .destructive) { _ in
                        self.deleteMedication(at: indexPath)
                    }
                    
                    alertController.addAction(cancelAction)
                    alertController.addAction(deleteAction)
                    
                    self.present(alertController, animated: true, completion: nil)

        }
    }
    
    private func deleteMedication(at indexPath: IndexPath) {
        // Store the full medication object
        if let medicationDetails = medicationData[indexPath.row].medicationDetailsByDate.first {
            self.medicationToDelete = medicationDetails.medicalDetails

             let iD = medicationDetails.medicalDetails.prescriptionID
                print("The ID is", iD)
                
                let params: [String: Int] = ["prescriptionID": iD]
                
                self.view.showToastActivity()
                APIService.deletMedicationAPICalling(
                    self,
                    params: params,
                    method: "POST",
                    accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken,
                    acces: false,
                    parameterPlacement: "body"
                ) { response in
                    self.getresponsefordeleteMedicationAPI(response: response)
                }
            
        }
    }

    func getresponsefordeleteMedicationAPI(response: AnyObject) {
        DispatchQueue.main.async {
            self.view.hideToastActivity()
        }

        if let responseString = response as? String {
            print("Response received from delete Medication API calling is", responseString)
        } else if let responseDict = response as? [String: Any] {
            if let responseMessage = responseDict["responseMessage"] as? String,
               let responseCode = responseDict["responseCode"] as? Int,
               responseCode == 200 {

                print("Response Message:", responseMessage)
                self.view.showToast(message: responseMessage)

                if let deletedMedication = self.medicationToDelete {
                    for timeGroup in deletedMedication.scheduledTimeList {
                        for alarmD in timeGroup.scheduledTimes {
                            if alarmD.alarmEnabled == "1" {
                                let alarmTime = alarmD.alarmTime
                                let repeatStrings = alarmD.repeat

                                let identifier = alarmTime.replacingOccurrences(of: " ", with: "_")

                                let weekdayMap: [String: Int] = [
                                    "Sun": 1, "Mon": 2, "Tue": 3, "Wed": 4, "Thu": 5, "Fri": 6, "Sat": 7,
                                    "Dom": 1, "Lun": 2, "Mar": 3, "Mié": 4, "Jue": 5, "Vie": 6, "Sáb": 7
                                ]
                                let repeatDays = repeatStrings.compactMap { weekdayMap[$0] }

                                deleteAlarmNotification(identifier: identifier, repeatDays: repeatDays)
                            }
                        }
                    }
                }

                getMedicationsData(forDate: selectedNewDate)
            } else {
                print("Response Message not found or is not a string.")
            }
        } else {
            print("Unsupported response type:", type(of: response))
        }
    }

    
    //End
    
    //MARK: - Delete Alarm
    
    func deleteAlarmNotification(identifier: String, repeatDays: [Int]) {
        let center = UNUserNotificationCenter.current()
        
        if repeatDays.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: [identifier])
        } else {
            let ids = repeatDays.map { "\(identifier)_\($0)" }
            center.removePendingNotificationRequests(withIdentifiers: ids)
        }
        
        print("Deleted alarm with identifier(s):", repeatDays.isEmpty ? identifier : repeatDays.map { "\(identifier)_\($0)" })
    }
    
    //END
    
    
    @objc func backButtonOverrideAction() {
        
        let next = UIStoryboard(name: "UserMedicalRecords", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "UserMedicalRecordsViewController") as? UserMedicalRecordsViewController
        self.navigationController?.pushViewController(vc!, animated: true)

    }

    
    
    @IBAction func didClickOnAddMedications(_ sender: Any) {
        let next = UIStoryboard(name: "AddUserMedications", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "AddUserMedicationsViewController") as? AddUserMedicationsViewController
        vc?.refreshControlClosure = {[weak self] flag in
            self?.getMedicationsData(forDate: self?.selectedNewDate ?? Date())
        }
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {//kiran diagnostics
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Medications" : "Medicamento"
        self.tabBarController?.tabBar.isHidden = false;
        self.tabBarController?.tabBar.selectedItem?.title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Home" : "Inicio"//"Home"
        saveButton.setAttributedTitleWithGradientDefaults(title: AppHelper.getLocalizeString(str:"Save"))
        
        let date = Calendar.current.startOfDay(for: Date())
        getMedicationsData(forDate: convertToLocalTimeZone(date: date))
        print("the date we are passing is", convertToLocalTimeZone(date: date))
    }
    
    func convertToLocalTimeZone(date: Date) -> Date {
        let timeZone = TimeZone.current
        let calendar = Calendar.current
        let localDate = calendar.date(byAdding: .second, value: timeZone.secondsFromGMT(for: date), to: date)!
        return localDate
    }

    
    func NcalendardidChangeBounds(newBounds: CGRect) {
        calendarHeightConstraint.constant = newBounds.height
    }

    func NuserSelectedNewDate(selectedDate: Date) {
        self.medicationData = []
        selectedNewDate = selectedDate
        print("the selected from calender selection is", selectedNewDate)
        print("Formatted date is:", selectedNewDate.dateInMMDDYYYYFormat1())
        getMedicationsData(forDate: selectedDate)
    }

    func getMedicationsData(forDate:Date) {
        view.showToastActivity()
        
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(identifier: "UTC")!

        let utcDate = utcCalendar.startOfDay(for: forDate) // Midnight in UTC
        print("UTC date is getting as ", utcDate)
        
        var prepareRequestBodyParams:[String:Any] = [:]
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            self.view.hideToastActivity()
            return
        }
        prepareRequestBodyParams["patientLocationId"] = loginResponse.patientLocationID
        prepareRequestBodyParams["patientId"] = loginResponse.patientID
        prepareRequestBodyParams["clientId"] = loginResponse.clientID

        let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: utcDate)!

        prepareRequestBodyParams["fromDate"] = utcDate.dateInMMDDYYYYFormat1()
        prepareRequestBodyParams["toDate"] = tomorrowDate.dateInMMDDYYYYFormat1()
        let questonariesRequest = GetMedicationsRequestForm(prepareRequestBodyParams)
        guard let requestURL = questonariesRequest.getURLRequest() else {
            self.view.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }
        NetworkAPIRequest.sendRequest(request: requestURL) { [weak self](response: MedicationDetailsResponse?, failureResponse: FailureResponse?, error: Error?) in
            
            print("vivek here", response as Any)
            print("failureResponse here", failureResponse as Any)
            print("error here", error?.localizedDescription ?? "nil")
            
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                if let err = error {
                    self.view.hideToastActivity()

                    if (err as NSError).code == NSURLErrorTimedOut {
                        self.view.showToast(message: "Request timed out. Please try again.")
                    } else {
                        self.view.showToast(message: err.localizedDescription)
                    }
                }
                else if let response = response {
                    print("the response code is ", response.response.responseCode)
                    if response.response.responseCode == 200 {
                        // Update medicationData and reload the table
                        
                        self.medicationData = response.medicineDetails
                            .filter { $0.date == utcDate.dateToString1(format: "MM/dd/yyyy") }
                            .sorted {
                                ($0.medicationDetailsByDate.first?.medicalDetails.medicationId ?? Int.max) >
                                ($1.medicationDetailsByDate.first?.medicalDetails.medicationId ?? Int.max)
                            }

                            let afterSorting = self.medicationData.flatMap { $0.medicationDetailsByDate }.map { $0.medicalDetails.medicationId }
                            print("After Sorting: \(afterSorting)")
                        
                        self.reloadTableView {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                print("spinner stops")
                                self.updateTakeAllButtonFromCells(for: self.selectedTimeSlot)
                                self.view.hideToastActivity()
                            }
                        }

                        self.scheduleAlarm()
                        
                        print("the medication data count is",self.medicationData.count)
                        self.nomedications.isHidden = true
                        self.medicationsTableView.isHidden = false

                        self.reloadTableView {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Slight delay to allow rendering completion
                                print("spinner stops")
                                self.view.hideToastActivity() // Now hide the spinner
                            }
                        }
                        
                        
                    }
                    else if response.response.responseCode == 400 {
                            print("Total Records: \(response.totalRecords)")
                            self.medicationsTableView.isHidden = true
                            self.nomedications.isHidden = false
                        self.view.hideToastActivity()
                        }
                    else {
                        print("the response message is ",response.response.responseMessage)
                        self.medicationsTableView.isHidden = true
                        self.nomedications.isHidden = false
                        self.medicationsTableView.reloadData()
                        self.view.showToast(message: response.response.responseMessage)
                        self.view.hideToastActivity()
                        }

                } else if let failureResponse = failureResponse {
                    self.view.showToast(message: failureResponse.statusResponse.responseMessage)
                    self.view.hideToastActivity()
                }

            }
        }
    }
    
    //MARK: - Take All Button Status Update
    
    func slotStatus(for timeSlot: TimeSlot) -> (hasActive: Bool, allTaken: Bool) {
        var hasActiveSlot = false
        var allActiveTaken = true
        
        for case let cell as UserMedicationsTableCell in medicationsTableView.visibleCells {
            if cell.isExpired { continue }
            
            if let slotInfo = cell.getSlotInfo(for: timeSlot) {
                if slotInfo.isActive {
                    hasActiveSlot = true
                    if !slotInfo.isTaken {
                        allActiveTaken = false
                    }
                }
            }
        }
        return (hasActiveSlot, hasActiveSlot && allActiveTaken)
    }

    
    func updateTakeAllButtonFromCells(for timeSlot: TimeSlot) {
//        var hasActiveSlot = false
//        var allActiveTaken = true
//        
//        for case let cell as UserMedicationsTableCell in medicationsTableView.visibleCells {
//            
//            if cell.isExpired {
//                continue  // ✅ skip expired cells
//            }
//            
//            if let slotInfo = cell.getSlotInfo(for: timeSlot) {
//                if slotInfo.isActive {
//                    hasActiveSlot = true
//                    if !slotInfo.isTaken {
//                        allActiveTaken = false
//                    }
//                }
//            }
//        }
//        
//        print("the all active taken is \(allActiveTaken) and the has active slot is \(hasActiveSlot)")
//        
//        let isTaken = allActiveTaken && hasActiveSlot
//        let titleKey = isTaken ? "taken" : "take_all"
        
        let status = slotStatus(for: timeSlot)
        let isTaken = status.allTaken
        let titleKey = isTaken ? "taken" : "take_all"
        
        let newTitle = NSLocalizedString(titleKey, comment: "")
//        let newTitle = isTaken ? "Taken" : "Take All"
        
        // Update title
        takeAllButton.setTitle(newTitle, for: .normal)
        takeAllButton.setTitle(newTitle, for: .disabled)
        takeAllButton.setTitle(newTitle, for: .highlighted)
        
        // Update colors based on isTaken state
        let borderColor = isTaken ? #colorLiteral(red: 0.9636, green: 0.574, blue: 0.575, alpha: 1) : #colorLiteral(red: 0.432, green: 0.415, blue: 0.706, alpha: 1)
        
        takeAllButton.layer.borderColor = borderColor.cgColor
        takeAllButton.backgroundColor = .clear
        takeAllButton.setTitleColor(borderColor, for: .normal)
        
        // Update enabled state and alpha
//        takeAllButton.isEnabled = hasActiveSlot
//        takeAllButton.alpha = hasActiveSlot ? 1.0 : 0.5
        
        takeAllButton.isEnabled = status.hasActive
        takeAllButton.alpha = status.hasActive ? 1.0 : 0.5
        
//        takeAllButton.layoutIfNeeded()
    }



    
    //MARK: - Call to schedule alarm
    
    func scheduleAlarm() {
        
        for medication in self.medicationData {
            for detail in medication.medicationDetailsByDate {
                let medicalDetails = detail.medicalDetails
                
                for timeGroup in medicalDetails.scheduledTimeList {
                    for alarm in timeGroup.scheduledTimes {
                        // Check if alarm is enabled
                        if alarm.alarmEnabled == "1" {
                            let alarmTime = alarm.alarmTime // e.g., "2025-05-20 09:09:00"
                            
                            // Split into date and time
                            let parts = alarmTime.split(separator: " ")
                            guard parts.count == 2 else { continue }
                            let datePart = String(parts[0])  // "2025-05-20"
                            let timePart = String(parts[1])  // "09:09:00"
                            
                            let identifier = "\(datePart)_\(timePart)"
                            
                            // Extract hour and minute
                            let timeComponents = timePart.split(separator: ":")
                            guard timeComponents.count >= 2,
                                  let hour = Int(timeComponents[0]),
                                  let minute = Int(timeComponents[1]) else { continue }
                            
                            // Convert repeat string array to weekday integers
                            let repeatStrings = alarm.repeat
                            let weekdayMap: [String: Int] = [
                                "Sun": 1, "Mon": 2, "Tue": 3, "Wed": 4,
                                "Thu": 5, "Fri": 6, "Sat": 7,
                                "Dom": 1, "Lun": 2, "Mar": 3, "Mié": 4, "Jue": 5, "Vie": 6, "Sáb": 7
                            ]
                            let repeatDays = repeatStrings.compactMap { weekdayMap[$0] }
                            
                            //Delete previous one
                            deleteAlarmNotification(identifier: identifier, repeatDays: repeatDays)

                            // Schedule alarm
                            scheduleAlarmNotification(hour: hour, minute: minute, identifier: identifier, repeatDays: repeatDays)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Schedule Alarm Functioon
    
    func scheduleAlarmNotification(hour: Int, minute: Int, identifier: String, repeatDays: [Int]) {
        print("alarm schedule function called")
        let content = UNMutableNotificationContent()
        content.title = "Medication Alert"
        content.body = "Please take your medication to stay healthy"
        content.categoryIdentifier = "ALARM_CATEGORY"
        content.interruptionLevel = .critical

        content.sound = UNNotificationSound.criticalSoundNamed(
            UNNotificationSoundName(rawValue: "bell.mp3")
        )
        
        // Step 1: Get prior time from UserDefaults (in minutes)
        let priorMinutes = UserDefaults.standard.integer(forKey: "alarmPriorMinutes") // default is 0 if not set
        print("the prior min is", priorMinutes)
        // Step 2: Create a DateComponents with the original hour and minute
        var originalComponents = DateComponents()
        originalComponents.hour = hour
        originalComponents.minute = minute
        
        // Step 3: Use Calendar to subtract priorMinutes
        let calendar = Calendar.current
        if let originalDate = calendar.date(from: originalComponents),
           let adjustedDate = calendar.date(byAdding: .minute, value: -priorMinutes, to: originalDate) {
            
            let adjustedComponents = calendar.dateComponents([.hour, .minute], from: adjustedDate)
            let adjustedHour = adjustedComponents.hour ?? hour
            let adjustedMinute = adjustedComponents.minute ?? minute
            
            if repeatDays.isEmpty {
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
                dateComponents.hour = adjustedHour
                dateComponents.minute = adjustedMinute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    }
                }
            } else {
                for day in repeatDays {
                    var dateComponents = DateComponents()
                    dateComponents.hour = adjustedHour
                    dateComponents.minute = adjustedMinute
                    dateComponents.weekday = day
                    
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
    }
    
    
    //MARK: - Table Reload Smooth UI
    
    func reloadTableView(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.medicationsTableView.reloadData()
            
            // Force table view to fully layout its cells before continuing
            self.medicationsTableView.layoutIfNeeded()
            
            // Hide spinner once layout and rendering are done
            completion()
        }
    }
   
}

@available(iOS 16.0, *)
extension UserMedicationsViewController : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medicationData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserMedicationsTableCell", for: indexPath) as! UserMedicationsTableCell
        cell.selectionStyle = .none
        cell.updateCellWith(MedicalDetails: medicationData[indexPath.row], for: selectedTimeSlot)
        cell.delegate = self
        cell.indexPath = indexPath
        
        let medicineTaken = medicationData[indexPath.row].medicationDetailsByDate.first?.medicalDetails.scheduledTimeList.first?.scheduledTimes.first?.medicineTaken ?? "0"
        
        print("medicine taken value is",medicineTaken)
        
        let expiry = medicationData[indexPath.row].medicationDetailsByDate.first?.medicalDetails.expired ?? 0
        
        cell.isExpired = (expiry == 1)
        
        if expiry == 1 {
            cell.expiredLabel.alpha = 0.5
            cell.subTitleLabel.alpha = 0.5
            cell.titleLabel.alpha = 0.5
            cell.expiredLabel.isHidden = false
            cell.borderView.backgroundColor = #colorLiteral(red: 0.9607843757, green: 0.9607843757, blue: 0.9607843757, alpha: 1)
            cell.timeLabel.alpha = 0.5
            cell.amTaken.alpha = 0.5
            cell.AMImage.alpha = 0.5
            cell.pmTimeLabel.alpha = 0.5
            cell.pmTaken.alpha = 0.5
            cell.PMImage.alpha = 0.5
            cell.AFImage.alpha = 0.5
            cell.afTimeLabel.alpha = 0.5
            cell.afTaken.alpha = 0.5

            cell.amButton.isUserInteractionEnabled = false
            cell.pmButton.isUserInteractionEnabled = false
            cell.afButton.isUserInteractionEnabled = false
            
            cell.dropDownButton.isUserInteractionEnabled = true
            
            cell.dropDownButton.alpha = 1.0
        } else {
            cell.expiredLabel.alpha = 1
            cell.subTitleLabel.alpha = 1
            cell.titleLabel.alpha = 1
            cell.borderView.backgroundColor = .white
            cell.expiredLabel.isHidden = true
            cell.dropDownButton.isUserInteractionEnabled = true
            cell.timeLabel.alpha = 1
            cell.amTaken.alpha = 1
            cell.AMImage.alpha = 1
            cell.pmTimeLabel.alpha = 1
            cell.PMImage.alpha = 1
            cell.pmTaken.alpha = 1
            cell.AFImage.alpha = 1
            cell.afTimeLabel.alpha = 1
            cell.afTaken.alpha = 1
            cell.dropDownButton.alpha = 1.0
            
            cell.amButton.isUserInteractionEnabled = true
            cell.pmButton.isUserInteractionEnabled = true
            cell.afButton.isUserInteractionEnabled = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 142
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let expiry = medicationData[indexPath.row].medicationDetailsByDate.first?.medicalDetails.expired ?? 0
        
        if expiry == 1 {
            
        } else {
            let next = UIStoryboard(name: "MedicationDetail", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "MedicationsDetailViewController") as? MedicationsDetailViewController
            vc?.title = AppHelper.getLocalizeString(str: "Medications detail")
            vc?.medicineDetails = medicationData[indexPath.row]
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
        
    }
    
}

@available(iOS 16.0, *)
extension UserMedicationsViewController: CustomTableViewCellDelegate {
    func didTapMoreButton(in cell: UITableViewCell, at indexPath: IndexPath, buttonFrame: CGRect) {

        let buttonFrameInView = medicationsTableView.convert(buttonFrame, to: self.view)
        dismissDropdown()

        // Create and position the dropdown
        let dropdown = DropdownView()
        dropdown.configure(with: cell)

        // Adjust dropdown position relative to the cell
        let dropdownWidth: CGFloat = 120
        let dropdownHeight: CGFloat = 100
        var dropdownX = buttonFrameInView.maxX - dropdownWidth 
        let dropdownY = buttonFrameInView.maxY + 8

            if dropdownX < 0 {
                dropdownX = 8 // Adjust to fit within screen, adding a small margin
            }

        dropdown.frame = CGRect(x: dropdownX, y: dropdownY, width: dropdownWidth, height: dropdownHeight)
        dropdown.tag = 999 // To identify the dropdown later
        self.view.addSubview(dropdown)

        // Add tap gesture to dismiss dropdown
        let overlay = UIView(frame: self.view.bounds)
        overlay.backgroundColor = UIColor.clear
        overlay.tag = 998
        overlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissDropdown)))
        self.view.insertSubview(overlay, belowSubview: dropdown)
    }

    @objc func dismissDropdown() {
        self.view.viewWithTag(999)?.removeFromSuperview()
        self.view.viewWithTag(998)?.removeFromSuperview()
    }

}




