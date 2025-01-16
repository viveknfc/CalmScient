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

class NextAppointmentsViewController: ViewController, CalendarToViewDelegate {

    @IBOutlet weak var calenderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var calender: CustomCalender!
    @IBOutlet weak var nextAppointmentTableView: UITableView!
    
    private var selectedNewDate:Date = Date()
    private var isDataExistForSelectedDate:Bool = false
    private var userMedicalAppointments:[MedicalAppointmentDetailsList] = []
    private var currentWeekList:[Date] = Date().datesOfCurrentWeek() ?? []
    private var medicalAppointmentsData:[EmptyOrMedicalAppointment] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        calender.calendarToViewDelegate = self
        nextAppointmentTableView.register(UINib(nibName: "AppointmentsEmptyTableViewCell", bundle: nil), forCellReuseIdentifier: "AppointmentsEmptyTableViewCell")
        nextAppointmentTableView.dataSource = self
        nextAppointmentTableView.delegate = self
        
        getMedicalAppointmentsData(forDate: selectedNewDate)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        let next = UIStoryboard(name: "AddAppointments", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "AddAppoinementsViewController") as? AddAppoinementsViewController
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
        switch instance {
        case .emptyAppointment(let dateInstance):
            cell.dateLabel.text = dateInstance
            cell.cellIconImageView.image = UIImage(named: "appointmentIcon")
           // UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "No appointments" : "Sin citas"
            cell.contentTextLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "No appointments" : "Sin citas"
        case .medicalAppointment(let appointment):
            cell.dateLabel.text = appointment.dateString
            cell.cellIconImageView.image = UIImage(named: "doctorWithSteth")
            cell.contentTextLabel.text = appointment.appointmentDetails.hospitalName
            break
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
