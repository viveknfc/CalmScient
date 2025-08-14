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
        // Get the current text, including the new characters
        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return true } // Safely unwrap the range
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        
        // Apply capitalization: Capitalize the first letter, lowercase the rest
//        let capitalizedText = updatedText.prefix(1).uppercased() + updatedText.dropFirst().lowercased()
        
        // Calculate the new cursor position
        let cursorOffset = range.location + string.count
        let newCursorPosition = textField.position(from: textField.beginningOfDocument, offset: cursorOffset)
        
        // Update the text field
        textField.text = updatedText//capitalizedText
        
        // Set the cursor to the new position, if possible
        if let position = newCursorPosition {
            textField.selectedTextRange = textField.textRange(from: position, to: position)
        } else {
            // Fallback: Set the cursor to the end of the text if the position calculation fails
            let endPosition = textField.endOfDocument
            textField.selectedTextRange = textField.textRange(from: endPosition, to: endPosition)
        }
        
        // Returning false as we've already updated the text field manually
        return false
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
