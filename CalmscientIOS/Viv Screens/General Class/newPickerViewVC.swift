//
//  newPickerViewVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 10/01/25.
//

import UIKit

protocol NewPickerViewDelegate: AnyObject {
    func didSelectDate(_ date: Date, indexPath: IndexPath?)
    func didDismissPicker()
}

class newPickerViewVC: UIViewController {
    
    @IBOutlet weak var titleLabel: FontLL15!
    @IBOutlet weak var dateSelector: UIDatePicker!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: NewPickerViewDelegate?
    var indexPath: IndexPath?
    var minimumDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let minimumDate = minimumDate {
            dateSelector.minimumDate = minimumDate
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
            delegate?.didSelectDate(selectedDate, indexPath: indexPath)
            delegate?.didDismissPicker()
           dismiss(animated: true, completion: nil)
       }
       
       @IBAction func cancelButtonTapped(_ sender: UIButton) {
           dismissKeyboard()
           delegate?.didDismissPicker()
           dismiss(animated: true, completion: nil)
       }


}
