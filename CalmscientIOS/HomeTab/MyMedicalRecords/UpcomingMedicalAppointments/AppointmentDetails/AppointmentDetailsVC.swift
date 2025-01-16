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
        self.title = "Appointment Details"
        doctorIconView.layer.cornerRadius = doctorIconView.frame.height / 2
        guard let appointDetails = medicalAppointment else {
            return
        }
        doctorLabel.text = appointDetails.appointmentDetails.providerName
        hospitalName.text = appointDetails.appointmentDetails.hospitalName
        
        dateAndTimeValue.text = appointDetails.appointmentDetails.dateAndTime
        
        // Assuming appointDetails.appointmentDetails.dateAndTime is a string
        let originalDateString = appointDetails.appointmentDetails.dateAndTime

        // Define the date formatter for the original date string
        let originalDateFormatter = DateFormatter()
        // Set the format of the original date string according to its current format
        originalDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
       

        // Parse the original date string into a Date object
        if let date = originalDateFormatter.date(from: originalDateString) {
            // Define the date formatter for the desired output format
            let outputDateFormatter = DateFormatter()
            // Set the desired output format
            outputDateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
            
            // Convert the Date object to the desired output format
            let formattedDateString = outputDateFormatter.string(from: date)
            
            // Assign the formatted date string to the label
            dateAndTimeValue.text = formattedDateString
        } else {
            // Handle the case where the date string could not be parsed
            dateAndTimeValue.text = "Invalid Date"
            dateAndTimeValue.text = AppHelper.getLocalizeString(str:"Invalid Date")
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
