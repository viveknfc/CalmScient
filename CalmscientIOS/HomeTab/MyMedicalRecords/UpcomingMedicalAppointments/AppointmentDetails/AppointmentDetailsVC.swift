//
//  AppointmentDetailsVC.swift
//  HealthScreeningApp
//
//  Created by KA on 20/03/24.
//

import UIKit

class AppointmentDetailsVC: ViewController {
    
    @IBOutlet weak var doctorLabel: UILabel!
    @IBOutlet weak var hospitalName: UILabel!
    
    
    @IBOutlet weak var dataAndTimeLabel: UILabel!
    @IBOutlet weak var dateAndTimeValue: UILabel!
    
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var contactValue: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addressValue: UILabel!
    
    
    @IBOutlet weak var appointmentDetalLabel: UILabel!
    @IBOutlet weak var appointmentDetailValue: UILabel!
    
    @IBOutlet weak var doctorIconView: UIView!
    
    var medicalAppointment:MedicalAppointmentDetailsByDate? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.title = "Appointment details"
        doctorIconView.layer.cornerRadius = doctorIconView.frame.height / 2
        guard let appointDetails = medicalAppointment else {
            return
        }
        doctorLabel.text = appointDetails.appointmentDetails.providerName
        hospitalName.text = appointDetails.appointmentDetails.hospitalName
       
        let originalDateString = appointDetails.appointmentDetails.dateAndTime // No need for `if let`

        let originalDateFormatter = DateFormatter()
        originalDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Ensure format matches the input
        originalDateFormatter.locale = Locale(identifier: "en_US_POSIX")
        originalDateFormatter.timeZone = TimeZone.current

        if let date = originalDateFormatter.date(from: originalDateString) {
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
            outputDateFormatter.locale = Locale(identifier: "en_US_POSIX")
            outputDateFormatter.timeZone = TimeZone.current
            
            dateAndTimeValue.text = outputDateFormatter.string(from: date)
        } else {
            dateAndTimeValue.text = AppHelper.getLocalizeString(str: "Invalid Date")
        }



        
        contactValue.text = appointDetails.appointmentDetails.contact
        
        addressValue.text = appointDetails.appointmentDetails.address
        appointmentDetailValue.text = appointDetails.appointmentDetails.appointmentDetails
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
        dataAndTimeLabel.text = AppHelper.getLocalizeString(str:"Date and Time")
        self.title = AppHelper.getLocalizeString(str:"Appointment Details")
        contactLabel.text =  AppHelper.getLocalizeString(str:"Contact")
        addressLabel.text = AppHelper.getLocalizeString(str:"Address")
        appointmentDetalLabel.text = AppHelper.getLocalizeString(str:"Appointment Detail")
        }
}
