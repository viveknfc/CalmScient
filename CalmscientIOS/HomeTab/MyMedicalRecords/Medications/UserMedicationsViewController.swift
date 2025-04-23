//
//  UserMedicationsViewController.swift
//  MainTabBarApp
//
//  Created by KA on 13/03/24.
//

import UIKit
import FSCalendar

@available(iOS 16.0, *)
class UserMedicationsViewController: ViewController, NCalendarToViewDelegate, CustomTableViewCellDelegate {    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var networkHandler:NetworkAPIRequest = NetworkAPIRequest()
    @IBOutlet weak var calendar: NewCalender!
    @IBOutlet weak var addMedicationsButton: UIButton!
    @IBOutlet weak var saveButton: LinearGradientButton!
    @IBOutlet weak var medicationsTableView: UITableView!
    
    @IBOutlet weak var infoLabel: FontLR15!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    var medicationData:[MedicineDetails] = []
    
    private var selectedNewDate: Date = {
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(identifier: "UTC")! // Force UTC time zone
        return utcCalendar.startOfDay(for: Date())
    }()

    
//    private var selectedNewDate:Date = Calendar.current.startOfDay(for: Date())//Date()
    var nomedications = UILabel()
    var combinedDateTime = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.calendarToViewDelegate = self
        addMedicationsButton.imageView?.contentMode = .scaleAspectFill
        medicationsTableView.register(UINib(nibName: "UserMedicationsTableCell", bundle: nil), forCellReuseIdentifier: "UserMedicationsTableCell")
        medicationsTableView.dataSource = self
        medicationsTableView.delegate = self
        
        infoLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Please select the medication below if you took it today." : "Selecciona el medicamento de la lista si lo has tomado hoy"
        
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
        
        medicationsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)

    }
    
    //MARK: - MARK Medication API Call
    
    func didTapTakenButton(in cell: UITableViewCell, buttonType: ButtonType) {
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let selectedDay = calendar.startOfDay(for: selectedNewDate)

        if let daysDifference = calendar.dateComponents([.day], from: selectedDay, to: today).day,
           daysDifference >= 0 && daysDifference <= 4 {
            
            // 🕓 For today, apply future time restriction
            if selectedDay == today {
                
                //viv start
                
                if selectedDay == today {
                    // Get local hour (not in UTC)
                    let localHour = Calendar.current.component(.hour, from: Date())

                    switch buttonType {
                    case .first:
                        // Morning: allowed anytime today — no restriction
                        break

                    case .second:
                        // Afternoon: only allowed if local time is 12 PM or later
                        if localHour < 12 {
                            print("⏰ Too early to mark afternoon dose. Local hour: \(localHour)")
                            return
                        }

                    case .third:
                        // Evening: only allowed if local time is 6 PM or later
                        if localHour < 18 {
                            print("⏰ Too early to mark evening dose. Local hour: \(localHour)")
                            return
                        }
                    }
                }

                
                //end

            }

            print("✅ Date is allowed for marking")

            guard let indexPath = self.medicationsTableView.indexPath(for: cell) else { return }

            let medicationDetails = medicationData[indexPath.row].medicationDetailsByDate.first?.medicalDetails
            let scheduledIndex = buttonType.scheduledIndex

            let responseDate = medicationData[indexPath.row].date

            if let scheduledTimes = medicationDetails?.scheduledTimeList[scheduledIndex].scheduledTimes.first {
                
                let pmtId = scheduledTimes.pmtId
                let medicineTaken = (scheduledTimes.medicineTaken == "1") ? "0" : "1"
                let responseTime = scheduledTimes.medicineTime

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                if let date = dateFormatter.date(from: responseDate) {
                    let outputFormatter = DateFormatter()
                    outputFormatter.dateFormat = "yyyy-MM-dd"
                    let formattedDate = outputFormatter.string(from: date)
                    combinedDateTime = "\(formattedDate) \(responseTime)"
                }

                callForMarkMedication(pmtId: pmtId, medicineTaken: medicineTaken, medicationdatetime: combinedDateTime)
            } else {
                print("No scheduledTimes found for button: \(buttonType)")
            }
            
        } else {
            print("❌ Selected date is more than 5 days ago or in the future")
        }
    }
    
    func callForMarkMedication(pmtId: String, medicineTaken: String, medicationdatetime: String) {
        
        if let medicineTakenInt = Int(medicineTaken), let pmtIdInt = Int(pmtId) {
            let params: [String: Any] = ["pmtId": pmtIdInt, "medicineTaken": medicineTakenInt, "medicationdatetime": medicationdatetime]
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

        getMedicationsData(forDate: selectedNewDate) //Date()
        
        if let responseDict = response as? [String: Any],
           let responseCode = responseDict["responseCode"] as? Int,
           responseCode == 200 {
            print("medine updation success")
        } else {
            print("Failed to mark medication. Response: \(response)")
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
            
            let alertController = UIAlertController(title: "Confirm Deletion",
                                                            message: "Are you sure you want to delete this medication?",
                                                            preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            cancelAction.setValue(#colorLiteral(red: 0.431, green: 0.420, blue: 0.702, alpha: 1), forKey: "titleTextColor") // Hex: #6e6bb3
                    let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { _ in
                        self.deleteMedication(at: indexPath)
                    }
                    
                    alertController.addAction(cancelAction)
                    alertController.addAction(deleteAction)
                    
                    self.present(alertController, animated: true, completion: nil)

        }
    }
    
    private func deleteMedication(at indexPath: IndexPath) {
        
        if let iD = medicationData[indexPath.row].medicationDetailsByDate.first?.medicalDetails.prescriptionID {
            print("The ID is", iD)
            
            let params: [String: Int] = ["prescriptionID": iD]
            
            self.view.showToastActivity()
            APIService.deletMedicationAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
                self.getresponsefordeleteMedicationAPI(response: response)
            }
        }
    }
    
    func getresponsefordeleteMedicationAPI(response:AnyObject)->() {
        if let responseString = response as? String {
            print("Response received from delete Medication API calling is", responseString)
        } else if let responseDict = response as? [String: Any] {

                if let responseMessage = responseDict["responseMessage"] as? String {
                    
                    print("Response Message:", responseMessage)
                    self.view.showToast(message: responseMessage)
                    
                    getMedicationsData(forDate: selectedNewDate)
                       } else {
                           print("Response Message not found or is not a string.")
                       }

        } else {
            print("Unsupported response type:", type(of: response))
        }

    }
    
    //End
    
    
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
        
        title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Medications" : "Medicación"
        self.tabBarController?.tabBar.isHidden = false;
        self.tabBarController?.tabBar.selectedItem?.title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Home" : "Inicio"//"Home"
        saveButton.setAttributedTitleWithGradientDefaults(title: AppHelper.getLocalizeString(str:"Save"))
        
        let date = Calendar.current.startOfDay(for: Date())
        getMedicationsData(forDate: convertToLocalTimeZone(date: date))
        print("the date we are passing is", convertToLocalTimeZone(date: date))


//        getMedicationsData(forDate: Date())
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
        
//        let tomorrowDate = selectedNewDate.getTomorrowDate()
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
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                if let err = error {
                    self.view.hideToastActivity()
                    self.view.showToast(message: err.localizedDescription)
                    
                } else if let response = response {
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

                        
                        print("the medication data count is",self.medicationData.count)
                        self.nomedications.isHidden = true
                        self.medicationsTableView.isHidden = false
//                        self.medicationsTableView.reloadData()

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
        cell.updateCellWith(MedicalDetails: medicationData[indexPath.row])
        cell.delegate = self
        cell.indexPath = indexPath
        
        let medicineTaken = medicationData[indexPath.row].medicationDetailsByDate.first?.medicalDetails.scheduledTimeList.first?.scheduledTimes.first?.medicineTaken ?? "0"
        
        print("medicine taken value is",medicineTaken)
        
        let expiry = medicationData[indexPath.row].medicationDetailsByDate.first?.medicalDetails.expired ?? 0
        
        if expiry == 1 {
            cell.expiredLabel.alpha = 0.5
            cell.subTitleLabel.alpha = 0.5
            cell.titleLabel.alpha = 0.5
            cell.expiredLabel.isHidden = false
            cell.borderView.backgroundColor = #colorLiteral(red: 0.8557285666, green: 0.8665012121, blue: 0.866311729, alpha: 1)
            cell.timeLabel.alpha = 0.5
            cell.AMImage.alpha = 0.5
            cell.pmTimeLabel.alpha = 0.5
            cell.PMImage.alpha = 0.5
            cell.AFImage.alpha = 0.5
            cell.afTimeLabel.alpha = 0.5

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
            cell.AMImage.alpha = 1
            cell.pmTimeLabel.alpha = 1
            cell.PMImage.alpha = 1
            cell.AFImage.alpha = 1
            cell.afTimeLabel.alpha = 1
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




