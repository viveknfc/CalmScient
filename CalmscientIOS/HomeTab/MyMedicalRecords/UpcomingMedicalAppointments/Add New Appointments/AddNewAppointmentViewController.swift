//
//  AddNewAppointmentViewController.swift
//  CalmscientIOS
//
//  Created by NFC Solutions on 3/6/25.
//

import UIKit

class AddNewAppointmentViewController: ViewController, NewPickerViewDelegate, UISheetPresentationControllerDelegate {
 
    
    func didSelectDate(_ date: Date, indexPath: IndexPath?) {
        let calendar = Calendar.current
        let resetDate = calendar.startOfDay(for: date)
        
        // Format the selected date as a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        dateFormatter.locale = Locale(identifier: "en_US")  // Set the locale
        dateFormatter.timeZone = TimeZone.current

        let formattedDate = dateFormatter.string(from: resetDate)
        print("The formatted date is:", formattedDate)
        self.dateTF.text = formattedDate
        print("The selected date is:", date)        
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
    
    var inPutTextField = UITextField()
    
    private let appointmentsTB = UITableView()
    private let data = ["Kevin", "Hyderabad", "Cherry", "Date", "Elderberry"]
    private var filteredData = ["Kevin", "Hyderabad", "Cherry", "Date", "Elderberry"]
    var appointmentsTBTop = 0.0
    
    let placeholderText = "Description"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add Appointment"
        descriptionTV.text = placeholderText
        descriptionTV.textColor = UIColor.lightGray
        descriptionTV.delegate = self
        
        setUpTextFields()
        setupTableView()

    }
    
//MARK: - Button Actions
    
    @IBAction func notificationBtnAction(){
        
        notificationBtn.isSelected = !notificationBtn.isSelected
        if !notificationBtn.isSelected == true {
            notificationBtn.setImage(UIImage(named: "cellUnselectedImage"), for: .normal)
        }
        else
        {
            notificationBtn.setImage(UIImage(named: "CellSelectionImage"), for: .normal)
        }
    }
    
    @IBAction func cancelBtnAction(){
        
    }
  
    @IBAction func saveBtnAction(){
        
        self.showSuccessAlert(successContent: "Your appointment has been successfully added.", centreImage: nil) {
            print("OK button tapped!")
            
        }
        
    }
    
    @IBAction func dateBtnAction(){
        
        guard let parentViewController = self.findViewController() else {
            print("No parent view controller found")
            return
        }
        
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        guard let vc = next.instantiateViewController(withIdentifier: "newPickerViewVC") as? newPickerViewVC else {
            fatalError("Could not instantiate view controller with identifier 'BottomSheetTimeAndAlarmVC'")
        }
        
        vc.delegate = self
        
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                
                if #available(iOS 16.0, *) {
                    let customDetent = UISheetPresentationController.Detent.custom { _ in
                        return 270 // Replace with desired height
                    }
                    sheet.detents = [customDetent]
                } else {
                    sheet.detents = [.medium()]
                    // Fallback on earlier versions
                }
                
                
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true

                sheet.delegate = self // To handle delegate methods and adjust dimming view

            }
        } else {
            // Fallback on earlier versions
        }

        vc.isModalInPresentation = true
        parentViewController.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func timeBtnAction(){
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        // Create the Date Picker
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time  // Set mode to Time
        timePicker.preferredDatePickerStyle = .wheels // Use classic wheel style
        timePicker.locale = Locale(identifier: "en_US") // Ensures 12-hour format
        
        // Set DatePicker frame
        timePicker.frame = CGRect(x: 0, y: 70, width: alertController.view.frame.width - 20, height: 150)
        
        // Create toolbar with Done & Cancel buttons
        let toolBar = UIToolbar(frame: CGRect(x: 5, y: 0, width: alertController.view.frame.width - 25, height: 44))
        toolBar.barStyle = .default
        toolBar.backgroundColor = UIColor.clear
        toolBar.barTintColor = UIColor(hex: "F0F0F0")
        toolBar.layer.cornerRadius = 10
        toolBar.layer.masksToBounds = true
        
        
        
        // Flexible space to push buttons to right side
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // Done button
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: nil, action: nil)
        doneButton.action = #selector(self.doneButtonTapped(_:))
        doneButton.target = self
        doneButton.tintColor = .black
        
        // Cancel button
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: nil)
        cancelButton.action = #selector(self.cancelButtonTapped(_:))
        cancelButton.target = self
        cancelButton.tintColor = .black
        
        // Add buttons to toolbar
        toolBar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
        
        // Add toolbar and date picker to the alert
        alertController.view.addSubview(toolBar)
        alertController.view.addSubview(timePicker)
        
        // Adjust height of the alert
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alertController.view!,
                                                            attribute: .height,
                                                            relatedBy: .equal,
                                                            toItem: nil,
                                                            attribute: .notAnAttribute,
                                                            multiplier: 1,
                                                            constant: 260) // Adjust height
        
        alertController.view.addConstraint(height)
        
        // Present the alert
        present(alertController, animated: true)
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


extension AddNewAppointmentViewController :  UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableView() {
        appointmentsTB.frame = CGRect(x: 30, y: patientNameVW.frame.maxY + 100, width: patientNameTF.frame.width, height: 150)
        appointmentsTB.delegate = self
        appointmentsTB.dataSource = self
        appointmentsTB.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        appointmentsTB.separatorStyle = .none
        appointmentsTB.layer.shadowColor = UIColor.black.cgColor
        appointmentsTB.layer.shadowOpacity = 0.3
        appointmentsTB.layer.shadowOffset = CGSize(width: 0, height: 3)
        appointmentsTB.layer.shadowRadius = 5
        appointmentsTB.layer.masksToBounds = false
        appointmentsTB.layer.cornerRadius = 4
        appointmentStackVW.addSubview(appointmentsTB)
        appointmentsTB.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideTableView))
            tapGesture.cancelsTouchesInView = false
            view.addGestureRecognizer(tapGesture)
        
    }
    @objc private func hideTableView() {
        appointmentsTB.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.selectionStyle = .none
        cell.textLabel?.text = filteredData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appointmentsTB.isHidden = true
        print("------ ", filteredData[indexPath.row], " ------")
        if inPutTextField == patientNameTF {
            patientNameTF.text = filteredData[indexPath.row]
        }
        else if inPutTextField == providerNameTF{
            providerNameTF.text = filteredData[indexPath.row]
        }
        else if inPutTextField == locationTF{
            locationTF.text = filteredData[indexPath.row]
        }
        
    }
}



extension AddNewAppointmentViewController : UITextFieldDelegate {
    

    func setUpTextFields() {
        patientNameTF.delegate = self
        providerNameTF.delegate = self
        locationTF.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        appointmentsTB.isHidden = false
        if textField == patientNameTF {
            inPutTextField = patientNameTF
            appointmentsTB.frame = CGRect(x: patientNameVW.frame.minX, y: patientNameVW.frame.maxY, width: patientNameTF.frame.width, height: 150)
        }
        else if textField == providerNameTF {
            inPutTextField = providerNameTF
            appointmentsTB.frame = CGRect(x: patientNameVW.frame.minX, y: providerNameVW.frame.maxY, width: patientNameTF.frame.width, height: 150)
        }
        else if textField == locationTF {
            inPutTextField = locationTF
            appointmentsTB.frame = CGRect(x: patientNameVW.frame.minX, y: locationVW.frame.maxY, width: patientNameTF.frame.width, height: 150)
        }
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
        if let text = textField.text as NSString? {
            let updatedText = text.replacingCharacters(in: range, with: string).lowercased()
            
            if updatedText.isEmpty {
                filteredData = data
            } else {
                filteredData = data.filter { $0.lowercased().contains(updatedText) }
            }
            
            DispatchQueue.main.async {
                self.appointmentsTB.reloadData()
                self.updateTableViewHeight()
            }
            
        }
        return true
        
    }
    
    private func updateTableViewHeight() {
        let rowHeight: CGFloat = 44  // Approximate row height
        let newHeight = min(CGFloat(filteredData.count) * rowHeight, 200)

        UIView.animate(withDuration: 0.3) {
            self.appointmentsTB.frame.size.height = newHeight
        }
    }
    
}
