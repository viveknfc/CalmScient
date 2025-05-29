//
//  NextAppointmentsViewController.swift
//  MainTabBarApp
//
//  Created by KA on 05/04/24.
//

import UIKit

fileprivate enum EmptyOrMedicalAppointment {
    case emptyAppointment(String)
    case medicalAppointment(MedicalAppointmentDetailsByDate)
}

class NextAppointmentsViewController: ViewController, NCalendarToViewDelegate {
    func NcalendardidChangeBounds(newBounds: CGRect) {
        calenderHeightConstraint.constant = newBounds.height
    }

    func NuserSelectedNewDate(selectedDate: Date) {
        selectedNewDate = selectedDate
        getMedicalAppointmentsData(forDate: selectedNewDate)
    }
    

    @IBOutlet weak var calenderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var calender: NewCalender!
    @IBOutlet weak var nextAppointmentTableView: UITableView!
    
    private var selectedNewDate:Date = Date()
    private var isDataExistForSelectedDate:Bool = false
    private var userMedicalAppointments:[MedicalAppointmentDetailsList] = []
    private var currentWeekList:[Date] = Date().nextSevenDays()
    private var medicalAppointmentsData:[EmptyOrMedicalAppointment] = []
    
    private let actionView = UIView()
    private var selectedIndexPath = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        calender.calendarToViewDelegate = self
        nextAppointmentTableView.register(UINib(nibName: "AppointmentsEmptyTableViewCell", bundle: nil), forCellReuseIdentifier: "AppointmentsEmptyTableViewCell")
        nextAppointmentTableView.dataSource = self
        nextAppointmentTableView.delegate = self
        nextAppointmentTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 150, right: 0)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedIndexPath = 0
        self.title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Next appointments" : "Próximas citas"
        getMedicalAppointmentsData(forDate: selectedNewDate)
    }
    
    func getMedicalAppointmentsData(forDate:Date) {
        currentWeekList = forDate.nextSevenDays()
        self.view.showToastActivity()
        var prepareRequestBodyParams:[String:Any] = [:]
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            return
        }
        prepareRequestBodyParams["patientLocationId"] = loginResponse.patientLocationID
        prepareRequestBodyParams["patientId"] = loginResponse.patientID
        prepareRequestBodyParams["clientId"] = loginResponse.clientID
        
        let calendar = Calendar.current
        let toDate = calendar.date(byAdding: .day, value: 6, to: Date())

        prepareRequestBodyParams["fromDate"] = Date().dateInMMDDYYYYFormat()
        prepareRequestBodyParams["toDate"] = toDate?.dateInMMDDYYYYFormat() ?? Date().dateInMMDDYYYYFormat()

        let questonariesRequest = GetUserMedicalAppointmentsRequestForm(prepareRequestBodyParams)
        guard let requestURL = questonariesRequest.getURLRequest() else {
            self.view.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }
        NetworkAPIRequest.sendRequest(request: requestURL) { [weak self](response: MedicalAppointmentResponse?, failureResponse: FailureResponse?, error: Error?) in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                if let _ = error {
                    self.view.showToast(message: "An Unknown error occured. Please check with Admin")
                } else if let response = response {
                    if response.statusResponse.responseCode != 200 {
                        self.view.showToast(message: response.statusResponse.responseMessage)
                    } else {
                        var tableData:[EmptyOrMedicalAppointment] = []
                        self.userMedicalAppointments = response.appointmentDetailsList
                        
                        for datum in self.currentWeekList{
                            let matchedAppointments = response.appointmentDetailsList.filter { instance in
                                let appointmentDateString = instance.date.getDate().dateToString(format: "MM/dd/yyyy")
                                let dateString = datum.dateToString(format: "MM/dd/yyyy")
                                return appointmentDateString == dateString
                            }
                            
                            if matchedAppointments.isEmpty {
                                tableData.append(.emptyAppointment(datum.dateToString(format: "MM/dd/yyyy")))
                            } else {

                                var isFirstAppointmentForDate = true
                                
                                for appointmentDetailsList in matchedAppointments {
                                    for eachAppointment in appointmentDetailsList.appointmentDetailsByDate {
                                        let updatedAppointment = eachAppointment
                                        updatedAppointment.dateString = appointmentDetailsList.date.getDate().dateToString(format: "MM/dd/yyyy")
                                        
                                        // Set `showDateLabel` to true only for the first appointment of the day
                                        updatedAppointment.showDateLabel = isFirstAppointmentForDate
                                        isFirstAppointmentForDate = false
                                        
                                        tableData.append(.medicalAppointment(updatedAppointment))
                                    }
                                }

                            }
                            self.medicalAppointmentsData = tableData
                        }

                        self.view.hideToastActivity()
                        self.nextAppointmentTableView.reloadData()
                    }
                } else if let failureResponse = failureResponse {
                    self.view.showToast(message: failureResponse.statusResponse.responseMessage)
                }
            }
        }
    }
    
    @IBAction func didClickOnAddAppointments(_ sender: Any) {
        
//        if selectedNewDate < Calendar.current.startOfDay(for: Date()) {
//            self.view.showToast(message: "Appointment cannot able to create in past days")
//            return
//        }
        
        let next = UIStoryboard(name: "AddNewAppointment", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "AddNewAppointmentViewController") as? AddNewAppointmentViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

extension NextAppointmentsViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medicalAppointmentsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentsEmptyTableViewCell", for: indexPath) as! AppointmentsEmptyTableViewCell
        if #available(iOS 16.0, *) {
            cell.delegate = self
        } else {
            // Fallback on earlier versions
        }
        cell.indexPath = indexPath
        cell.selectionStyle = .none
        let instance = medicalAppointmentsData[indexPath.row]
        
            switch instance {
                
            case .emptyAppointment(let dateInstance):
                cell.dateLabel.text = dateInstance
                cell.dateLabel.isHidden = false
                cell.dateLabelHeight.constant = 20
                cell.dateToAppointmentHeight.constant = 8
                cell.cellIconImageView.image = UIImage(named: "appointmentIcon")
                cell.forwardButton.isHidden = true
                cell.forwardButton.setImage(UIImage(named: "MedicationsCellArrow"), for: .normal)
                cell.editDeletButton.isHidden = true
                cell.contentTextLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "No appointments" : "Sin citas"
                cell.contentTextLabel.textColor = .black
                return cell
                
            case .medicalAppointment(let appointment):
                cell.dateLabel.text = appointment.appointmentDetails.dateAndTime.toFormattedDateString()
                
                if appointment.showDateLabel {
                    cell.dateLabel.isHidden = false
                    cell.dateLabelHeight.constant = 20  // Desired height when visible
                    cell.dateToAppointmentHeight.constant = 8
                } else {
                    cell.dateLabel.isHidden = true
                    cell.dateLabelHeight.constant = 0   // Collapse height when hidden
                    cell.dateToAppointmentHeight.constant = 0
                }
                
                cell.cellIconImageView.image = UIImage(named: "doctorWithSteth")
                cell.editDeletButton.isHidden = false
                cell.forwardButton.isHidden = true
                cell.editDeletButton.setImage(UIImage(named: "seperatorIcon"), for: .normal)
                cell.contentTextLabel.text = appointment.appointmentDetails.providerName
                cell.contentTextLabel.textColor = .black
                return cell
                
            }

    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let instance = medicalAppointmentsData[indexPath.row]
        switch instance {
        case .emptyAppointment(_):
           return 110
        case .medicalAppointment(let appointment):
            if appointment.showDateLabel {
                return 130  // Height when dateLabel is visible
            } else {
                return 94  // Height when dateLabel is hidden
            }
//            return 130
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("row selected from did select")

        let instance = medicalAppointmentsData[indexPath.row]
        switch instance {
        case .emptyAppointment(_):
           break
        case .medicalAppointment(let appointment):
            let next = UIStoryboard(name: "AppointmentDetailsVC", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "AppointmentDetailsVC") as? AppointmentDetailsVC
            vc?.medicalAppointment = appointment
            self.navigationController?.pushViewController(vc!, animated: true)
        }
       
    }

}

@available(iOS 16.0, *)
extension NextAppointmentsViewController: CustomTableViewCellDelegate {
    
    func didTapMoreButton(in cell: UITableViewCell, at indexPath: IndexPath, buttonFrame: CGRect) {

        let buttonFrameInView = nextAppointmentTableView.convert(buttonFrame, to: self.view)
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
    
    //MARK: - Edit Button Tapped
    
    func didTapEditButton(in cell: UITableViewCell) {
        
        if let indexPath = self.nextAppointmentTableView.indexPath(for: cell) {
            print("Edit button tapped for row \(indexPath.row)")
            
            let instance = medicalAppointmentsData[indexPath.row]
            let next = UIStoryboard(name: "AddNewAppointment", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "AddNewAppointmentViewController") as? AddNewAppointmentViewController
            if case let .medicalAppointment(details) = instance {
                vc?.forEditMedicalAppointmentsData = details
                vc?.EditVc = true
            } else {
                vc?.forEditMedicalAppointmentsData = nil
            }

            self.navigationController?.pushViewController(vc!, animated: true)
            
            
        }

    }
    
    //MARK: - Delete Button Tapped
    
    func didTapDeleteButton(in cell: UITableViewCell) {
        if let indexPath = self.nextAppointmentTableView.indexPath(for: cell) {
            print("Delete button tapped for row \(indexPath.row)")
            
            
            let alertController = UIAlertController(title: AppHelper.getLocalizeString(str: "Confirm Deletion"),
                                                            message: AppHelper.getLocalizeString(str: "Are you sure you want to delete this appointment?"),
                                                            preferredStyle: .alert)
                    
            let cancelAction = UIAlertAction(title: AppHelper.getLocalizeString(str: "No"), style: .cancel, handler: nil)
            cancelAction.setValue(#colorLiteral(red: 0.431, green: 0.420, blue: 0.702, alpha: 1), forKey: "titleTextColor") // Hex: #6e6bb3
                    let deleteAction = UIAlertAction(title: AppHelper.getLocalizeString(str: "Yes"), style: .destructive) { _ in
                        self.deleteAppointment(at: indexPath)
                    }
                    
                    alertController.addAction(cancelAction)
                    alertController.addAction(deleteAction)
                    
                    self.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    //MARK: - Delete Button API Call
    
    private func deleteAppointment(at indexPath: IndexPath) {
        
        let instance = medicalAppointmentsData[indexPath.row]
        
        if case let .medicalAppointment(details) = instance {
                let iD = Int(details.appointmentDetails.appointmentId)
                print("The ID is", iD)
                let params: [String: Int] = ["appointmentId": iD]
                
                self.view.showToastActivity()
                APIService.deleteAppointmentAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "url") { response in
                    self.getresponsefordeleteAppointmentAPI(response: response)
                }
            

        } else {

        }
        
    }
    
    //MARK: - Delete Button API Response
    
    func getresponsefordeleteAppointmentAPI(response:AnyObject)->() {
        self.view.hideToastActivity()
        if let responseString = response as? String {
            print("Response received from delete Appointment API calling is", responseString)
        } else if let responseDict = response as? [String: Any] {

                if let responseMessage = responseDict["responseMessage"] as? String {
                    
                    print("Response Message:", responseMessage)
                    showGeneralAlert(
                        image: UIImage(named: "InfoIcon"),
                        imageSize: CGSize(width: 60, height: 60),
                        title: responseMessage,
                        okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                        okAction: {},
                        showDismissButton: false
                    )
                    getMedicalAppointmentsData(forDate: selectedNewDate)

                       } else {
                           print("Response Message not found or is not a string.")
                       }

        } else {
            print("Unsupported response type:", type(of: response))
        }

    }
    
    func didTapTakenButton(in cell: UITableViewCell, buttonType: ButtonType) {
        return
    }

}

