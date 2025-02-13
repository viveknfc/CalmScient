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
    var medicationData:[MedicineDetails] = [] //{
//        didSet {
//            self.medicationsTableView.reloadData()
//        }
//    }
    private var selectedNewDate:Date = Date()
    var nomedications = UILabel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.calendarToViewDelegate = self
        addMedicationsButton.imageView?.contentMode = .scaleAspectFill
        medicationsTableView.register(UINib(nibName: "UserMedicationsTableCell", bundle: nil), forCellReuseIdentifier: "UserMedicationsTableCell")
        medicationsTableView.dataSource = self
        medicationsTableView.delegate = self
        getMedicationsData(forDate: Date())
        
        infoLabel.text = "Please select the medication you are currently taking."
        
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
        backButton.widthAnchor.constraint(equalToConstant: 26).isActive = true // Set desired width
        backButton.heightAnchor.constraint(equalToConstant: 26).isActive = true // Set desired height

        // Create a UIBarButtonItem using the UIButton
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        //end
        saveButton.isHidden = true
        
        medicationsTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)

    }
    
    func didChangeSelectionState(for cell: UITableViewCell, isSelected: Bool) {
        if let indexPath = self.medicationsTableView.indexPath(for: cell) {
            medicationData[indexPath.row].isSelected = isSelected
            print("isSelected", isSelected)
            
            if let pmtId = medicationData[indexPath.row].medicationDetailsByDate.first?.medicalDetails.scheduledTimeList.first?.scheduledTimes.first?.pmtId,
               let _ = medicationData[indexPath.row].medicationDetailsByDate.first?.medicalDetails.scheduledTimeList.first?.scheduledTimes.first?.medicineTaken {
                
                let medicineTakenValue = isSelected ? "1" : "0"
//                let medicineTakenValue = medicineTakenString == "null" ? "0" : medicineTakenString
                // Your code here
                if let medicineTakenInt = Int(medicineTakenValue), let pmtIdInt = Int(pmtId) {
                    let params: [String: Int] = ["pmtId": pmtIdInt, "medicineTaken": medicineTakenInt]
                    print("Params:", params)
                    self.view.showToastActivity()
                    APIService.MarkMedicationAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") {  [self] response in
                        // Your closure code here
                        getresponseforMarkMedicationAPI(response: response)
                    }
                } else {
                    print("Error: Unable to convert pmtId or medicineTaken to Int.")
                }
                
            }

                }
    }
    
    //MARK: - Mark Medication API Response
    
    func getresponseforMarkMedicationAPI(response:AnyObject)->() {
        self.view.hideToastActivity()
        if let responseString = response as? String {
            print("Response received from Mark Medication API calling is", responseString)
        } else if let responseDict = response as? [String: Any] {
            
            if let responseMessage = responseDict["responseMessage"] as? String {
                print("Response Message:", responseMessage)

//                let point = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
//                self.view.showToast(message: responseMessage, point: point)

            }
            
        }
        else {
            print("Unsupported response type:", type(of: response))
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
        if let navigationController = self.navigationController, navigationController.viewControllers.count > 1 {
            // If there's a back page, pop to the previous view controller
            navigationController.popViewController(animated: true)
        } else {
            // If there's no back page, navigate to the home tab
            print("Navigating to Home Tab Dashboard")
            
            if let tabBarController = self.tabBarController {
                let storyboard = UIStoryboard(name: "DashboardHomeTab", bundle: nil)
                if let homeTabVC = storyboard.instantiateViewController(withIdentifier: "HomeTabDashboardViewController") as? HomeTabDashboardViewController {
                    self.navigationController?.pushViewController(homeTabVC, animated: true)
                }
                tabBarController.tabBar.selectedItem?.title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Home" : "Inicio"
                   } else {
                       print("Tab bar controller not found")
                   }
        }
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
        title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Medications" : "Medicación"
        self.tabBarController?.tabBar.isHidden = false;
        self.tabBarController?.tabBar.selectedItem?.title = "Home"
        getMedicationsData(forDate: Date())
        saveButton.setAttributedTitleWithGradientDefaults(title: AppHelper.getLocalizeString(str:"Save"))
    }
    
    func NcalendardidChangeBounds(newBounds: CGRect) {
        calendarHeightConstraint.constant = newBounds.height
    }

    func NuserSelectedNewDate(selectedDate: Date) {
        self.medicationData = []
        selectedNewDate = selectedDate
        getMedicationsData(forDate: selectedDate)
    }

    func getMedicationsData(forDate:Date) {
        self.view.showToastActivity()
        var prepareRequestBodyParams:[String:Any] = [:]
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            self.view.hideToastActivity()
            return
        }
        prepareRequestBodyParams["patientLocationId"] = loginResponse.patientLocationID
        prepareRequestBodyParams["patientId"] = loginResponse.patientID
        prepareRequestBodyParams["clientId"] = loginResponse.clientID
        
        let tomorrowDate = selectedNewDate.getTomorrowDate()

        prepareRequestBodyParams["fromDate"] = selectedNewDate.dateInMMDDYYYYFormat()
        prepareRequestBodyParams["toDate"] = tomorrowDate.dateInMMDDYYYYFormat()
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
                        self.medicationData = response.medicineDetails.filter { obj in
                            let dateString = self.selectedNewDate.dateToString(format: "MM/dd/yyyy")
                            return obj.date == dateString
                        }
                        print("the medication data count is",self.medicationData.count)
                        self.nomedications.isHidden = true
                        self.medicationsTableView.isHidden = false
                        self.medicationsTableView.reloadData()
                    }
                    else if response.response.responseCode == 400 {
                            print("Total Records: \(response.totalRecords)")
                            self.medicationsTableView.isHidden = true
                            self.nomedications.isHidden = false
                        }
                    else {
                        print("the response message is ",response.response.responseMessage)
                        self.medicationsTableView.isHidden = true
                        self.nomedications.isHidden = false
                        self.medicationsTableView.reloadData()
                        self.view.showToast(message: response.response.responseMessage)
                        }

                } else if let failureResponse = failureResponse {
                    self.view.showToast(message: failureResponse.statusResponse.responseMessage)
                }

                    self.view.hideToastActivity()
            
            }
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
   
        if let medicineTakenValue = Int(medicineTaken), medicineTakenValue == 1 {
            print("medicine taken value is",medicineTakenValue)
            cell.cellSelectionImage.image = UIImage(named: "CellSelectionImage")
            cell.buttonState = .selected
            cell.cellStatusLabel.isHidden = false
            cell.expiredLeadingValue.constant = 65
        } else {
            print("medicine taken value is",Int(medicineTaken) ?? 444)
            cell.cellSelectionImage.image = UIImage(named: "cellUnselectedImage")
            cell.cellStatusLabel.isHidden = true
            cell.expiredLeadingValue.constant = 5
        }
        
        if expiry == 1 {
            cell.cellSelectionImage.alpha = 0.5
            cell.cellStatusLabel.alpha = 0.5
            cell.expiredLabel.alpha = 0.5
            cell.subTitleLabel.alpha = 0.5
            cell.titleLabel.alpha = 0.5
            cell.cellSelectionImage.isUserInteractionEnabled = false
            cell.expiredLabel.isHidden = false
            cell.borderView.backgroundColor = #colorLiteral(red: 0.8557285666, green: 0.8665012121, blue: 0.866311729, alpha: 1)
            cell.timeLabel.alpha = 0.5
            cell.AMImage.alpha = 0.5
            cell.pmTimeLabel.alpha = 0.5
            cell.PMImage.alpha = 0.5
            cell.AFImage.alpha = 0.5
            cell.afTimeLabel.alpha = 0.5
            
            cell.dropDownButton.isUserInteractionEnabled = true
            cell.dropDownButton.alpha = 1.0
        } else {
            cell.cellSelectionImage.alpha = 1
            cell.cellStatusLabel.alpha = 1
            cell.expiredLabel.alpha = 1
            cell.subTitleLabel.alpha = 1
            cell.titleLabel.alpha = 1
            cell.borderView.backgroundColor = .white
            cell.cellSelectionImage.isUserInteractionEnabled = true
           cell.expiredLabel.isHidden = true
           cell.cellStatusLabel.textColor = .black
            cell.dropDownButton.isUserInteractionEnabled = true
            cell.timeLabel.alpha = 1
            cell.AMImage.alpha = 1
            cell.pmTimeLabel.alpha = 1
            cell.PMImage.alpha = 1
            cell.AFImage.alpha = 1
            cell.afTimeLabel.alpha = 1
            cell.dropDownButton.alpha = 1.0
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 116
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




