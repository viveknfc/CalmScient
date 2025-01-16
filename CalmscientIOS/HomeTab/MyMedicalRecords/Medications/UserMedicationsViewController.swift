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
    var medicationData:[MedicineDetails] = [] {
        didSet {
            self.medicationsTableView.reloadData()
        }
    }
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
    }
    
    func didChangeSelectionState(for cell: UITableViewCell, isSelected: Bool) {
        if let indexPath = self.medicationsTableView.indexPath(for: cell) {
            medicationData[indexPath.row].isSelected = isSelected
            print("isSelected", isSelected)
            if let pmtId = medicationData[indexPath.row].medicationDetailsByDate.first?.medicalDetails.scheduledTimeList.first?.scheduledTimes.first?.pmtId,
               let medicineTakenString = medicationData[indexPath.row].medicationDetailsByDate.first?.medicalDetails.scheduledTimeList.first?.scheduledTimes.first?.medicineTaken {
                
                let medicineTakenValue = isSelected ? "1" : "0"
//                let medicineTakenValue = medicineTakenString == "null" ? "0" : medicineTakenString
                // Your code here
                if let pmtIdInt = Int(pmtId), let medicineTakenInt = Int(medicineTakenValue) {
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
            print("Delete button tapped for row \(indexPath.row)")
            
            if let iD = medicationData[indexPath.row].medicationDetailsByDate.first?.medicalDetails.prescriptionID {
                print("the Id is", iD)
                
                let params:[String:Int] = ["prescriptionID": iD]
                
                self.view.showToastActivity()
                APIService.deletMedicationAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") {  [self] response in
                    // Your closure code here
                    getresponsefordeleteMedicationAPI(response: response)
                    
                }
                
            }
            // Handle delete action
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
        self.tabBarController?.tabBar.isHidden = false;
        self.medicationsTableView.reloadData()
        title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Medications" : "Medicación"

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
                            let dateString = self.selectedNewDate.dateToString(format: "yyyy-MM-dd")
                            return obj.date == dateString
                        }
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

        let medicineTaken = medicationData[indexPath.row].medicationDetailsByDate.first?.medicalDetails.scheduledTimeList.first?.scheduledTimes.first?.medicineTaken ?? "0"
        
        if let medicineTakenValue = Int(medicineTaken), medicineTakenValue == 1 {
            cell.cellSelectionImage.image = UIImage(named: "CellSelectionImage")
            cell.buttonState = .selected
        } else {
            cell.cellSelectionImage.image = UIImage(named: "cellUnselectedImage")
        }
        
  
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 116
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let next = UIStoryboard(name: "MedicationDetail", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "MedicationsDetailViewController") as? MedicationsDetailViewController
        vc?.title = AppHelper.getLocalizeString(str: "Medications detail")
        vc?.medicineDetails = medicationData[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
}

