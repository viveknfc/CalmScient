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

class NextAppointmentsViewController: ViewController, CalendarToViewDelegate, NCalendarToViewDelegate {
    func NcalendardidChangeBounds(newBounds: CGRect) {
        calenderHeightConstraint.constant = newBounds.height
    }

    func NuserSelectedNewDate(selectedDate: Date) {
        selectedNewDate = selectedDate
    }
    

    @IBOutlet weak var calenderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var calender: NewCalender!
    @IBOutlet weak var nextAppointmentTableView: UITableView!
    
    private var selectedNewDate:Date = Date()
    private var isDataExistForSelectedDate:Bool = false
    private var userMedicalAppointments:[MedicalAppointmentDetailsList] = []
    private var currentWeekList:[Date] = Date().datesOfCurrentWeek() ?? []
    private var medicalAppointmentsData:[EmptyOrMedicalAppointment] = []
    
    private let actionView = UIView()
    private var selectedIndexPath = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        calender.calendarToViewDelegate = self
        nextAppointmentTableView.register(UINib(nibName: "AppointmentsEmptyTableViewCell", bundle: nil), forCellReuseIdentifier: "AppointmentsEmptyTableViewCell")
        nextAppointmentTableView.dataSource = self
        nextAppointmentTableView.delegate = self
        
        getMedicalAppointmentsData(forDate: selectedNewDate)
        // Do any additional setup after loading the view.
        setupActionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedIndexPath = 0
        self.title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Next appointments" : "Próximas citas"
    }
    
    func calendardidChangeBounds(newBounds: CGRect) {
        calenderHeightConstraint.constant = newBounds.height
    }
    
    func userSelectedNewDate(selectedDate: Date) {
        selectedNewDate = selectedDate
        getMedicalAppointmentsData(forDate: selectedNewDate)
    }
    
    func getMedicalAppointmentsData(forDate:Date) {
        currentWeekList = forDate.datesOfCurrentWeek() ?? []
        self.view.showToastActivity()
        var prepareRequestBodyParams:[String:Any] = [:]
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            return
        }
        prepareRequestBodyParams["patientLocationId"] = loginResponse.patientLocationID
        prepareRequestBodyParams["patientId"] = loginResponse.patientID
        prepareRequestBodyParams["clientId"] = loginResponse.clientID
        
        let tomorrowDate = Date().getTomorrowDate()
        prepareRequestBodyParams["fromDate"] = currentWeekList.first?.dateInMMDDYYYYFormat() ?? Date().dateInMMDDYYYYFormat()
        prepareRequestBodyParams["toDate"] = currentWeekList.last?.dateInMMDDYYYYFormat() ?? Date().getTomorrowDate().dateInMMDDYYYYFormat()

//        prepareRequestBodyParams["fromDate"] = Date().dateInMMDDYYYYFormat()
//        prepareRequestBodyParams["toDate"] = tomorrowDate.dateInMMDDYYYYFormat()
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
                        for datum in self.currentWeekList {
                            if let appointmentDetailsList = response.appointmentDetailsList.filter({ instance in
                                let appointmentDateString = instance.date.getDate().dateToString(format: "MM/dd/yyyy")
                                print("appointmentDateString: \(appointmentDateString)")
                                let dateString = datum.dateToString(format: "MM/dd/yyyy")
                                return appointmentDateString == dateString
                            }).first {
                                for eachAppointment in appointmentDetailsList.appointmentDetailsByDate {
                                    eachAppointment.dateString = appointmentDetailsList.date.getDate().dateToString(format: "MM/dd/yyyy")
                                    tableData.append(.medicalAppointment(eachAppointment))
                                }
                            } else {
                                tableData.append(.emptyAppointment(datum.dateToString(format: "MM/dd/yyyy")))
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
//        let next = UIStoryboard(name: "AddAppointments", bundle: nil)
//        let vc = next.instantiateViewController(withIdentifier: "AddAppoinementsViewController") as? AddAppoinementsViewController
//        self.navigationController?.pushViewController(vc!, animated: true)
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
        let instance = medicalAppointmentsData[indexPath.row]
        cell.editDeletButton.tag = indexPath.row
        /// below lines for testing purpose to know how the booked  appointmenrs will show ..we can edit once api create appointment api is ready
        
        if (indexPath.row % 2) == 0 {
            
            switch instance {
            case .emptyAppointment(let dateInstance):
                cell.dateLabel.text = dateInstance
                cell.cellIconImageView.image = UIImage(named: "appointmentIcon")
                cell.editDeletButton.setImage(UIImage(named: "MedicationsCellArrow"), for: .normal)
               // UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "No appointments" : "Sin citas"
                cell.contentTextLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "No appointments" : "Sin citas"
            case .medicalAppointment(let appointment):
                cell.dateLabel.text = appointment.dateString
                cell.cellIconImageView.image = UIImage(named: "doctorWithSteth")
                cell.contentTextLabel.text = appointment.appointmentDetails.hospitalName
                break
            }
        }
        else
        {
            cell.contentTextLabel.text = "Booked Appointment"
            cell.cellIconImageView.image = UIImage(named: "UpcomingMedicalAppointmentsDoctor")
            cell.editDeletButton.setImage(UIImage(named: "seperatorIcon"), for: .normal)
            cell.editDeletButton.addTarget(self, action: #selector(editDeletBtnAction), for: .touchUpInside)
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let instance = medicalAppointmentsData[indexPath.row]
        switch instance {
        case .emptyAppointment(_):
           return 110
        case .medicalAppointment(_):
            return 130
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let instance = medicalAppointmentsData[indexPath.row]
//        switch instance {
//        case .emptyAppointment(_):
//           break
//        case .medicalAppointment(let appointment):
//            let next = UIStoryboard(name: "AppointmentDetailsVC", bundle: nil)
//            let vc = next.instantiateViewController(withIdentifier: "AppointmentDetailsVC") as? AppointmentDetailsVC
//            vc?.medicalAppointment = appointment
//            self.navigationController?.pushViewController(vc!, animated: true)
//        }
        
        let next = UIStoryboard(name: "AppointmentDetailsVC", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "AppointmentDetailsVC") as? AppointmentDetailsVC
//        vc?.medicalAppointment = appointment
        self.navigationController?.pushViewController(vc!, animated: true)
       
    }
    
    @objc func editDeletBtnAction(sender : UIButton) {
        
//        actionView.frame.origin = CGPoint(x: sender.frame.maxX - 100, y: sender.frame.maxY + 5)
//                    actionView.isHidden = false
//                    
//        print("Button tapped at row: \(sender.tag)")
        selectedIndexPath = sender.tag
        if let cell = sender.superview?.superview?.superview?.superview?.superview as? AppointmentsEmptyTableViewCell, let indexPath = nextAppointmentTableView.indexPath(for: cell) {
                    let buttonFrame = sender.convert(sender.bounds, to: view) // Get button's position in the main view
                    actionView.frame.origin = CGPoint(x: buttonFrame.maxX - 100, y: buttonFrame.maxY + 5)
                    actionView.isHidden = false
                    
                    print("Button tapped at row: \(indexPath.row)")
                }
        
    }
    

}



extension NextAppointmentsViewController {
    
    private func setupActionView() {
           actionView.frame = CGRect(x: 0, y: 0, width: 100, height: 80)
           actionView.backgroundColor = .white
           actionView.layer.cornerRadius = 8
           actionView.layer.shadowColor = UIColor.black.cgColor
           actionView.layer.shadowOpacity = 0.3
           actionView.layer.shadowOffset = CGSize(width: 0, height: 3)
           actionView.layer.shadowRadius = 5
           actionView.isHidden = true  // Initially hidden
           
        let editButton = UIButton(type: .custom)
            editButton.setImage(UIImage(named: "editIcon"), for: .normal)
            editButton.setTitle("  Edit    ", for: .normal)
            editButton.setTitleColor(UIColor(named: "barColor1"), for: .normal)
            editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
           
        let deleteButton = UIButton(type: .custom)
            deleteButton.setImage(UIImage(named: "deleteIcon"), for: .normal)
            deleteButton.setTitle("  Delete", for: .normal)
            deleteButton.setTitleColor(UIColor(named: "barColor1"), for: .normal)
            deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
           
           let stackView = UIStackView(arrangedSubviews: [editButton, deleteButton])
           stackView.axis = .vertical
           stackView.spacing = 10
           stackView.alignment = .fill
           stackView.distribution = .fillEqually
           stackView.frame = CGRect(x: 10, y: 10, width: 80, height: 60)
           
           actionView.addSubview(stackView)
           view.addSubview(actionView)
           
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideActionView))
           view.addGestureRecognizer(tapGesture)
       }
       
    @objc private func editTapped() {
           print("Edit tapped")
           hideActionView()
        let next = UIStoryboard(name: "AddNewAppointment", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "AddNewAppointmentViewController") as? AddNewAppointmentViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    
       }
       
       @objc private func deleteTapped() {
           print("Delete tapped")
           hideActionView()
       }
       
       @objc private func hideActionView() {
           actionView.isHidden = true
       }
}
