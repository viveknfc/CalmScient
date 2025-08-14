//
//  newPickerViewVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 10/01/25.
//

import UIKit

protocol NewPickerViewDelegate: AnyObject {
    func didSelectDate(_ date: Date, indexPath: IndexPath?, isTimePicker: Bool)
    func didDismissPicker()
}

enum PickerMode {
    case date
    case time
}

class newPickerViewVC: UIViewController {
    
    @IBOutlet weak var titleLabel: FontLL15!
    @IBOutlet weak var dateSelector: UIDatePicker!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: NewPickerViewDelegate?
    var indexPath: IndexPath?
    var minimumDate: Date?
    var maximumDate: Date?
    
    var pickerMode: PickerMode = .date // Default mode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateSelector.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())
        
        switch pickerMode {
        case .date:
            dateSelector.datePickerMode = .date
            titleLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Please select date" : "Por favor, seleccione la fecha"
        case .time:
            dateSelector.datePickerMode = .time
            titleLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Please select time" : "Por favor, seleccione la hora"
        }
        
        if let minimumDate = minimumDate {
            dateSelector.minimumDate = minimumDate
           }
        
        if let maximumDate = maximumDate {
            dateSelector.maximumDate = maximumDate
           }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
         tapGesture.cancelsTouchesInView = false
         view.addGestureRecognizer(tapGesture)
        // Do any additional setup after loading the view.
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func okButtonTapped(_ sender: UIButton) {
            dismissKeyboard()
           let selectedDate = dateSelector.date
//            delegate?.didSelectDate(selectedDate, indexPath: indexPath)
        
        if pickerMode == .time {
            // Extract only the time part
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedDate)
            let normalizedTime = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                               minute: timeComponents.minute ?? 0,
                                               second: 0,
                                               of: Date()) ?? selectedDate
            
            delegate?.didSelectDate(normalizedTime, indexPath: indexPath, isTimePicker: true)
        } else {
            // Send full date
            delegate?.didSelectDate(selectedDate, indexPath: indexPath, isTimePicker: false)
        }
        
            delegate?.didDismissPicker()
           dismiss(animated: true, completion: nil)
       }
       
       @IBAction func cancelButtonTapped(_ sender: UIButton) {
           dismissKeyboard()
           delegate?.didDismissPicker()
           dismiss(animated: true, completion: nil)
       }


}
