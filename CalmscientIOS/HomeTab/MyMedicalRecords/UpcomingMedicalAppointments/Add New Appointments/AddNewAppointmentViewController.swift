//
//  AddNewAppointmentViewController.swift
//  CalmscientIOS
//
//  Created by NFC Solutions on 3/6/25.
//

import UIKit

class AddNewAppointmentViewController: ViewController, NewPickerViewDelegate, UISheetPresentationControllerDelegate, UIGestureRecognizerDelegate {
    
    var forEditMedicalAppointmentsData: MedicalAppointmentDetailsByDate?
    var EditVc: Bool?
    var params: [String: Any] = [:]
    
    func didSelectDate(_ date: Date, indexPath: IndexPath?, isTimePicker: Bool) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone.current
        
        if isTimePicker {
            // Format time and update timeTF
            dateFormatter.dateFormat = "hh:mm a"  // Example: "10:30 AM"
            let formattedTime = dateFormatter.string(from: date)
            self.timeTF.text = formattedTime
            print("The selected time is:", formattedTime)
        } else {
            // Format date and update dateTF
            dateFormatter.dateFormat = "MM/dd/yyyy"  // Example: "08/22/2024"
            let formattedDate = dateFormatter.string(from: date)
            self.dateTF.text = formattedDate
            print("The selected date is:", formattedDate)
        }
    }
    
    func didDismissPicker() {
        
    }
 
    @IBOutlet weak var appointmentStackVW : UIStackView!
    @IBOutlet weak var patientNameTF : UITextField!
    @IBOutlet weak var patientNameVW : UIView!
    @IBOutlet weak var providerNameTF : UITextField!
    @IBOutlet weak var providerNameVW : UIView!
    @IBOutlet weak var locationTF : UITextField!
    @IBOutlet weak var locationVW : UIView!
    @IBOutlet weak var dateTF : UITextField!
    @IBOutlet weak var timeTF : UITextField!
    @IBOutlet weak var descriptionTV : UITextView!
    @IBOutlet weak var notificationBtn : UIButton!
    
    let dropdownTableView = UITableView()
    var locationData: [LocationDetail] = [] // Holds all locations from API
    var providerData: [ProviderDetail] = []

    var filteredItems: [String] = []
    var filteredID: [Int] = []
    
    let placeholderText = "Description"
    
    var appointmentId = Int()
    var patientLocationId = Int()
    var patientId = Int()
    var clientId = Int()
    var providerFirstName = String()
    var providerLastName = String()
    var providerId: Int? = nil  // Can be an Int or nil
    var locationId: Int? = nil  // Can be an Int or nil
    var locationName = String()
    var appointmentDateTime = String()
    var itemDescription = String()
    var dateTimeforParam = String()
    var alert = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = EditVc ?? false ? "Edit Appointment" : "Add Appointment"
        descriptionTV.text = placeholderText
        descriptionTV.textColor = UIColor.lightGray
        descriptionTV.delegate = self
        
        setupDropdownTable()

        patientNameTF.isUserInteractionEnabled = true
        patientNameTF.text = UserDefaults.standard.string(forKey: "titleString")

        dropdownTableView.isHidden = true  // Hide initially
        providerNameTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        locationTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        providerNameTF.delegate = self
        locationTF.delegate = self
        
        // ✅ Add tap gesture recognizer to dismiss dropdown when tapping outside
        let tapGesture = UITapGestureRecognizer(target: self, action: nil)
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            return
        }
        patientLocationId = loginResponse.patientLocationID
        patientId = loginResponse.patientID
        clientId = loginResponse.clientID
        
        locationDetailAPI()
        providerDetailAPI()
        
        if let medicalAppointmentsData = forEditMedicalAppointmentsData {
            
            print("the received appointment details for edit is", medicalAppointmentsData)
            
            let providerNameFromFirstAPI = medicalAppointmentsData.appointmentDetails.providerName
            let hospitalNameFromFirstAPI = medicalAppointmentsData.appointmentDetails.hospitalName

            if let matchedProvider = providerData.first(where: { $0.firstName == providerNameFromFirstAPI }) {
                providerId = matchedProvider.providerId
                print("✅ Found Provider ID: \(String(describing: providerId)) for Provider Name: \(providerNameFromFirstAPI)")
            } else {
                print("❌ No matching provider found for name: \(providerNameFromFirstAPI)")
            }
            
            // Find matching location ID from locationData list
            if let matchedLocation = locationData.first(where: { $0.locationName == hospitalNameFromFirstAPI }) {
                locationId = matchedLocation.locationId
                print("✅ Found Location ID: \(String(describing: locationId)) for Hospital Name: \(hospitalNameFromFirstAPI)")
            } else {
                print("❌ No matching location found for name: \(hospitalNameFromFirstAPI)")
            }
            
//            patientNameTF.text = medicalAppointmentsData.appointmentDetails.patientName
            providerNameTF.text = providerNameFromFirstAPI
            locationTF.text = hospitalNameFromFirstAPI
            let date = medicalAppointmentsData.appointmentDetails.dateAndTime
            parseAndSetDateTime(from: date)
            appointmentId = medicalAppointmentsData.appointmentDetails.appointmentId
            itemDescription = medicalAppointmentsData.appointmentDetails.appointmentDetails
            descriptionTV.text = itemDescription
            alert = medicalAppointmentsData.appointmentDetails.alert ?? 0
            updateNotificationButton()
            
        } else {
            appointmentId = 0
            alert = 0
            
        }

    }

    
    //MARK: - Drop down table
    
    func setupDropdownTable() {
        dropdownTableView.backgroundColor = .white  // To make sure it’s visible
        dropdownTableView.delegate = self
        dropdownTableView.dataSource = self
        dropdownTableView.isHidden = true
        dropdownTableView.allowsSelection = true
        dropdownTableView.isUserInteractionEnabled = true
        dropdownTableView.layer.borderWidth = 1
        dropdownTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        dropdownTableView.layer.borderColor = UIColor.lightGray.cgColor
        view.addSubview(dropdownTableView)
        view.bringSubviewToFront(dropdownTableView)
    }
    
    //MARK: - Date and Time to convert from api to textfield
    
    func parseAndSetDateTime(from isoString: String) {
        let isoFormatter = DateFormatter()
        isoFormatter.locale = Locale(identifier: "en_US")
        isoFormatter.timeZone = TimeZone.current
        isoFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // API format

        // Convert ISO string to Date object
        guard let date = isoFormatter.date(from: isoString) else {
            print("Error: Invalid date format from API")
            return
        }

        // Extract and set Date (MM/dd/yyyy)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MM/dd/yyyy"
        self.dateTF.text = dateFormatter.string(from: date)

        // Extract and set Time (hh:mm a)
        let timeFormatter = DateFormatter()
        timeFormatter.locale = Locale(identifier: "en_US")
        timeFormatter.dateFormat = "hh:mm a"
        self.timeTF.text = timeFormatter.string(from: date)

        print("Parsed Date:", self.dateTF.text ?? "N/A")
        print("Parsed Time:", self.timeTF.text ?? "N/A")
    }

    
    //MARK: - Date Time in Required format for param
    
    func formatToISO8601() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone.current

        // Validate date input
        dateFormatter.dateFormat = "MM/dd/yyyy"
        guard let dateText = dateTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !dateText.isEmpty,
              let selectedDate = dateFormatter.date(from: dateText) else {
            showGeneralAlert(
                title: "Please enter a valid date.",
                okButtonTitle: "Ok",
                okAction: {

                },
                showDismissButton: false
            )
            return false
        }

        // Validate time input
        dateFormatter.dateFormat = "hh:mm a"
        guard let timeText = timeTF.text?.trimmingCharacters(in: .whitespacesAndNewlines), !timeText.isEmpty,
              let selectedTime = dateFormatter.date(from: timeText) else {
            showGeneralAlert(
                title: "Please enter a valid time.",
                okButtonTitle: "Ok",
                okAction: {

                },
                showDismissButton: false
            )
            return false
        }

        // Combine date and time
        let calendar = Calendar.current
        let finalDate = calendar.date(
            bySettingHour: calendar.component(.hour, from: selectedTime),
            minute: calendar.component(.minute, from: selectedTime),
            second: 0,
            of: selectedDate
        ) ?? selectedDate

        // Convert to ISO 8601 format
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateTimeforParam = dateFormatter.string(from: finalDate)
        
        return true
    }


    
//    func formatToISO8601() {
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "en_US")
//        dateFormatter.timeZone = TimeZone.current
//
//        // Get the date from dateTF or use current date
//        dateFormatter.dateFormat = "MM/dd/yyyy"
//        let selectedDate = dateTF.text.flatMap { dateFormatter.date(from: $0) } ?? Date()
//
//        // Get the time from timeTF or use current time
//        dateFormatter.dateFormat = "hh:mm a"
//        let selectedTime = timeTF.text.flatMap { dateFormatter.date(from: $0) } ?? Date()
//
//        // Combine date and time
//        let calendar = Calendar.current
//        let finalDate = calendar.date(
//            bySettingHour: calendar.component(.hour, from: selectedTime),
//            minute: calendar.component(.minute, from: selectedTime),
//            second: calendar.component(.second, from: selectedTime),
//            of: selectedDate
//        ) ?? Date()
//
//        // Convert to ISO 8601 format
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
//        dateTimeforParam = dateFormatter.string(from: finalDate)
//
//    }
    
    //MARK: - Location Detail API Call
    
    func locationDetailAPI() {
        let params: [String: Int] = ["locationId": patientLocationId, "clientId": clientId]
        
        self.view.showToastActivity()
        APIService.LocationDetailsAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            self.getResponseForLocationDetailsAPI(response: response)
        }
    }
    
    //MARK: - Provider Detail API Call
    
    func providerDetailAPI() {
        let params: [String: Int] = ["locationId": patientLocationId, "clientId": clientId]
        print("the param for provider detail is",params)
        
        self.view.showToastActivity()
        APIService.ProviderDetailsAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            self.getResponseForProviderDetailsAPI(response: response)
        }
    }
    
    //MARK: - Provider Details API Response
    
    func getResponseForProviderDetailsAPI(response: AnyObject) {
        print("entered provider deyail response")
        print("🔹 Raw API Response:", response)

        self.view.hideToastActivity()
        
        if let responseData = try? JSONSerialization.data(withJSONObject: response, options: []) {
            do {
                let decodedResponse = try JSONDecoder().decode(ProviderResponse.self, from: responseData)
                
                DispatchQueue.main.async {
                    self.providerData = decodedResponse.providerList
                    print("✅ Decoded provider list count:", self.providerData.count)
                    print("Provider name", self.providerData.first?.firstName ?? "UNKNOWN")
                    self.dropdownTableView.reloadData()
                }
                // Use decodedResponse.locationDetails in your dropdown
            } catch {
                print("Decoding error:", error)
            }
        } else {
            print("Invalid response format")
        }
    }

    
    //MARK: - Location Details API Response
    
    func getResponseForLocationDetailsAPI(response: AnyObject) {
        self.view.hideToastActivity()
        
        if let responseData = try? JSONSerialization.data(withJSONObject: response, options: []) {
            do {
                let decodedResponse = try JSONDecoder().decode(LocationResponse.self, from: responseData)

                print("Total Locations:", decodedResponse.totalRecords)
                
                DispatchQueue.main.async {
                    self.locationData = decodedResponse.locationDetails
                    print("loc name", self.locationData.first?.locationName ?? "UNKNOWN")
                    print("loc ID", self.locationData.first?.locationId ?? "NA")
                    self.dropdownTableView.reloadData()
                }
                // Use decodedResponse.locationDetails in your dropdown
            } catch {
                print("Decoding error:", error)
            }
        } else {
            print("Invalid response format")
        }
    }

    
//MARK: - Button Actions
    
    @IBAction func notificationBtnAction(){
        
        notificationBtn.isSelected = !notificationBtn.isSelected
        if !notificationBtn.isSelected == true {
            notificationBtn.setImage(UIImage(named: "cellUnselectedImage"), for: .normal)
            alert = 0
        }
        else
        {
            notificationBtn.setImage(UIImage(named: "CellSelectionImage"), for: .normal)
            alert = 1
        }
    }
    
    //MARK: - Function to update the UI of alert
    
    func updateNotificationButton() {
        notificationBtn.isSelected = alert == 1
        let imageName = alert == 1 ? "CellSelectionImage" : "cellUnselectedImage"
        notificationBtn.setImage(UIImage(named: imageName), for: .normal)
    }
    
    @IBAction func cancelBtnAction(){
        self.navigationController?.popViewController(animated: true)
    }
  
    @IBAction func saveBtnAction(){
        
        let patientName = patientNameTF.text ?? ""
        providerFirstName = providerNameTF.text ?? ""
        locationName = locationTF.text ?? ""
        itemDescription = descriptionTV.text ?? ""
        
        // Validation check
        
        if patientName.isEmpty {
            showGeneralAlert(
                title: "Patient Name cannot be empty.",
                okButtonTitle: "Ok",
                okAction: {

                },
                showDismissButton: false
            )
            return
        }
        
        if providerFirstName.isEmpty {
            showGeneralAlert(
                title: "Provider Name cannot be empty.",
                okButtonTitle: "Ok",
                okAction: {

                },
                showDismissButton: false
            )
            return
        }

        if locationName.isEmpty {
            showGeneralAlert(
                title: "Location Name cannot be empty.",
                okButtonTitle: "Ok",
                okAction: {

                },
                showDismissButton: false
            )
            return
        }
        
        if !formatToISO8601() {
            return // Stop execution if date/time is invalid
        }
        
        self.view.showToastActivity()
        
        params =                       ["appointmentId": appointmentId,
                                       "plId": patientLocationId,
                                       "patientId": patientId,
                                       "clientId": clientId,
                                       "providerFirstName": providerFirstName,
                                       "providerLastName": NSNull(),
                                       "locationName": locationName,
                                       "appointmentDateTime": dateTimeforParam,
                                       "description": itemDescription,
                                       "status": "Active",
                                       "alert": alert]
        
        params["providerId"] = providerId ?? NSNull()
        params["locationId"] = locationId ?? NSNull()
        
        print("the params of appoibntment save are ", params)
        
        if EditVc ?? false {
            
            APIService.editSaveAppointmentAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
                self.getresponseforEditSaceAppointmentAPI(response: response)
            }
            
        } else {
            
            APIService.SaveAppointmentAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
                self.getresponseforEditSaceAppointmentAPI(response: response)
            }

        }
    }
    
    //MARK: - Edit Save Button API Response
    
    func getresponseforEditSaceAppointmentAPI(response:AnyObject)->() {
        self.view.hideToastActivity()
        if let responseString = response as? String {
            print("Response received from Edit Save API calling is", responseString)
        } else if let responseDict = response as? [String: Any] {

                if let responseMessage = responseDict["responseMessage"] as? String {
                    
                    print("Response Message:", responseMessage)
                    
                    self.showSuccessAlert(successContent: responseMessage, centreImage: nil, okButtonAction: {
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                       } else {
                           print("Response Message not found or is not a string.")
                       }

        } else {
            print("Unsupported response type:", type(of: response))
        }
    }
    
    //MARK: - Date / Time Picker Function
    
    func openPicker(pickerMode: PickerMode) {
        guard let parentViewController = self.findViewController() else {
            print("No parent view controller found")
            return
        }
        
        let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "newPickerViewVC") as? newPickerViewVC else {
            fatalError("Could not instantiate view controller with identifier 'newPickerViewVC'")
        }
        
        vc.delegate = self
        vc.pickerMode = pickerMode // Set mode (date or time)

        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    let customDetent = UISheetPresentationController.Detent.custom { _ in
                        return 270 // Custom height
                    }
                    sheet.detents = [customDetent]
                } else {
                    sheet.detents = [.medium()]
                }
                
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                sheet.delegate = self
            }
        }

        vc.isModalInPresentation = true
        parentViewController.present(vc, animated: true, completion: nil)
    }

    
    //END
    
    @IBAction func dateBtnAction(){
        
        openPicker(pickerMode: .date)
        
    }
    
    @IBAction func timeBtnAction(){
        
        openPicker(pickerMode: .time)

    }
    
    // Done Button Action
       @objc func doneButtonTapped(_ sender: UIBarButtonItem) {
           if let alertController = self.presentedViewController as? UIAlertController,
              let datePicker = alertController.view.subviews.last(where: { $0 is UIDatePicker }) as? UIDatePicker {
               let formatter = DateFormatter()
               formatter.dateFormat = "hh:mm a" // 12-hour format with AM/PM
               let selectedTime = formatter.string(from: datePicker.date)
               self.timeTF.text = selectedTime // Set button title
           }
           dismiss(animated: true)
       }

       // Cancel Button Action
       @objc func cancelButtonTapped(_ sender: UIBarButtonItem) {
           dismiss(animated: true)
       }
    
}



extension AddNewAppointmentViewController :  UITextViewDelegate {
    
    // Hide placeholder when editing begins
       func textViewDidBeginEditing(_ textView: UITextView) {
           if textView.text == placeholderText {
               textView.text = ""
               textView.textColor = UIColor.black
           }
       }   

       // Show placeholder if textView is empty
       func textViewDidEndEditing(_ textView: UITextView) {
           if textView.text.isEmpty {
               textView.text = placeholderText
               textView.textColor = UIColor.lightGray
           }
       }
}


extension AddNewAppointmentViewController :  UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    func updateDropdownPosition(for textField: UITextField) {
        // Convert textField's frame to the main view's coordinate system
        let textFieldFrame = textField.superview?.convert(textField.frame, to: view) ?? textField.frame

        dropdownTableView.frame = CGRect(
            x: textFieldFrame.origin.x,
            y: textFieldFrame.origin.y + textFieldFrame.height + 5, // Ensure it's below the text field
            width: textFieldFrame.width,
            height: 150
        )
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // ✅ If tap is inside dropdownTableView, do NOT dismiss it
        if dropdownTableView.frame.contains(touch.location(in: view)) {
            print("✅ Tap inside dropdown, keeping it open")
            return false
        }

        // ✅ Tap is outside, hide dropdown
        print("✅ Tap outside dropdown, hiding it")
        dropdownTableView.isHidden = true
        return true
    }

    
    // ✅ Show dropdown when text field is tapped
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("✅ textFieldDidBeginEditing called for: \(textField.text ?? "Empty")")
        
        if textField == providerNameTF {
            filteredItems = providerData.map { $0.firstName } // Show provider names//
            filteredID = providerData.map { $0.providerId }
        } else if textField == locationTF {
            filteredItems = locationData.map { $0.locationName } // Show locations
            filteredID = locationData.map { $0.locationId }
        } else {
            return
        }

        dropdownTableView.reloadData()
        updateDropdownPosition(for: textField)
        dropdownTableView.isHidden = filteredItems.isEmpty//false
        print("✅ Dropdown should now be visible!")
    }

    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard textField == providerNameTF || textField == locationTF else { return }

        guard let text = textField.text, !text.isEmpty else {
            filteredItems = (textField == providerNameTF) ? providerData.map { $0.firstName } : locationData.map { $0.locationName }
            dropdownTableView.isHidden = false
            dropdownTableView.reloadData()
            return
        }

        // Filter items based on input
        if textField == providerNameTF {
            filteredItems = providerData.map { $0.firstName }.filter { $0.lowercased().contains(text.lowercased()) }
        } else if textField == locationTF {
            filteredItems = locationData.map { $0.locationName }.filter { $0.lowercased().contains(text.lowercased()) }
        }

        // Show or hide tableView
        dropdownTableView.isHidden = filteredItems.isEmpty
        updateDropdownPosition(for: textField)
        dropdownTableView.reloadData()
    }


    // MARK: - UITableViewDataSource & UITableViewDelegate

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredItems[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if providerNameTF.isFirstResponder {
            providerNameTF.text = filteredItems[indexPath.row]
            providerId = filteredID[indexPath.row]
        } else if locationTF.isFirstResponder {
            locationTF.text = filteredItems[indexPath.row]
            locationId = filteredID[indexPath.row]
        }
        
        dropdownTableView.isHidden = true
        view.endEditing(true) // Dismiss keyboard
        print("✅ Selected: \(filteredItems[indexPath.row]) and Id is \(filteredID[indexPath.row])")
    }

}
