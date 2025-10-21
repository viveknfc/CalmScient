//
//  AddNewMedicationUserEntryTableCell.swift
//  CalmscientIOS
//
//  Created by NFC on 26/04/24.
//

import UIKit

enum AddMedicationsCellType:String {
    case MedicationName = "Name"
    case MedicationProvider = "Provider"
    case MedicationDosage = "Dosage"
    case MedicationDirection = "Direction"
}

class AddNewMedicationUserEntryTableCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userEntryTextField: TextFieldWithPadding!
    @IBOutlet weak var textCount: UILabel!
    
    public var cellType:AddMedicationsCellType = .MedicationName
    var userEntryCaptureClosure:((_ text:String, _ row:Int)->Void)?
    var cellRow:Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        userEntryTextField.layer.borderWidth = 1
        userEntryTextField.layer.borderColor = UIColor(named: "light6E6BB3Color")?.cgColor
        userEntryTextField.backgroundColor = UIColor(named: "lightF2F2F2Color")
        userEntryTextField.layer.cornerRadius = 2
        userEntryTextField.layer.masksToBounds = true
        userEntryTextField.delegate = self
        if cellType == .MedicationName {
                    userEntryTextField.autocapitalizationType = .sentences
                    userEntryTextField.delegate = self
                }
        
        textCount.text = "0/2000"
        
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userEntryTextField.text = ""
    }
    
    func configureCell(with text: String, at row: Int) {
        userEntryTextField.text = text
        cellRow = row

            // Immediately call the closure to capture the pre-filled value
        userEntryCaptureClosure?(text, row)
        }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        userEntryCaptureClosure?(textField.text ?? "",cellRow)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return true }
        
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        
        if string.contains("<") || string.contains(">") || string.contains("/") {
            return false
        }
        
        // Check if the new text length is within the limit
        if updatedText.count <= 2000 {
            // Update the text field manually
            textField.text = updatedText
            
            // Update the character count label
            textCount.text = "\(updatedText.count)/2000"
            
            // Call the capture closure if needed
            userEntryCaptureClosure?(updatedText, cellRow)
            
            // Set the cursor position appropriately
            let cursorOffset = range.location + string.count
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: cursorOffset) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
            
            return false // We've handled the update
        } else {
            // Optionally, you could shake the text field or show an alert if needed
            return false // Prevent further typing
        }
    }
    
}

public class TextFieldWithPadding: UITextField {
    var textPadding = UIEdgeInsets(
        top: 0,
        left: 8,
        bottom: 0,
        right: 8
    )

    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
}
