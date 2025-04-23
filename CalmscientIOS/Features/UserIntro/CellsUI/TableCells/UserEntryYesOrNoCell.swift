//
//  UserEntryYesOrNoCell.swift
//  HealthApp
//
//  Created by KA on 26/02/24.
//

import UIKit

class UserEntryYesOrNoCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var journalTextView: UITextView!
    @IBOutlet weak var toggleImageView: UIImageView!
    
    var toggleValue: Int? {
        didSet {
            let toggleImage: UIImage
            if toggleValue == 1 {
                toggleImage = UIImage(named: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "ToggleSwitch_Yes" : "ToggleSwitch_Si")!
                instance.medicineAnswer = "1"
                self.toggleImageView.tag = 1
            } else {
                toggleImage = UIImage(named: "ToggleSwitch_No")!
                instance.medicineAnswer = "0"
                self.toggleImageView.tag = -1
            }
            UIView.transition(with: self.toggleImageView,
                              duration: 0.2,
                              options: .transitionCrossDissolve,
                              animations: { self.toggleImageView.image = toggleImage },
                              completion: nil)
        }
    }

    
    private var cellType:UserEntryDayFeedbackTableCell! {
        didSet {
            if cellType == .UserEntryJournalCell {
                let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")

                var labelText: String
                labelText = languageId == 1 ? (instance.journalData?.journalKey ?? "") : "Diario"

                // Create an attributed string with red asterisk
                let attributedText = NSMutableAttributedString(string: labelText)
                let redAsterisk = NSAttributedString(
                    string: " *",
                    attributes: [.foregroundColor: UIColor.red]
                )
                attributedText.append(redAsterisk)

                // Set the attributed text to the label
                self.titleLabel.attributedText = attributedText

            } else {
                let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
                
                self.titleLabel.text = languageId == 1 ? instance.medicineData?.medicineQuestion : "¿Tomaste tus medicamentos esta mañana?"
            }
        }
    }
    var instance:UserStartupScreenDayData!
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        addShadowAndBorder()
        
//        shadowView.applyShadow()
        borderView.applyShadow()
        self.journalTextView.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.2).cgColor
        self.journalTextView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        self.journalTextView.layer.borderWidth = 1.0
        self.journalTextView.layer.cornerRadius = 4
        self.journalTextView.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.toggleTheImage))
        self.toggleImageView.isUserInteractionEnabled = true
        self.toggleImageView.addGestureRecognizer(tapGestureRecognizer)

        journalTextView.delegate = self
        // Initialization code
    }
    
    func textViewDidChange(_ textView: UITextView) {
        instance.journalAnswer = textView.text
    }
    
    func getUpdatedToggleData() -> String? {
        return instance.medicineAnswer
    }
    
    func getUpdatedJournalData() -> String? {
        return self.journalTextView.text
    }

    
    func updateUIWithCellInstance(instance:UserStartupScreenDayData, cellType:UserEntryDayFeedbackTableCell) {
        self.instance = instance
        self.cellType = cellType
    }
    
    @objc func toggleTheImage(){
        print("the toggle value is",self.toggleImageView.tag)
        var toggleImage:UIImage!
        if self.toggleImageView.tag == -1 {
            instance.medicineAnswer = "1"
            toggleImage = UIImage(named: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "ToggleSwitch_Yes" : "ToggleSwitch_Si")
            self.toggleImageView.tag = 1
        } else {
            instance.medicineAnswer = "0"
            toggleImage = UIImage(named: "ToggleSwitch_No")
            self.toggleImageView.tag = -1
        }
        UIView.transition(with: self.toggleImageView,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: { self.toggleImageView.image = toggleImage },
                          completion: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configureJournalView(isJournalView:Bool) {
        toggleImageView.isHidden = isJournalView
        self.journalTextView.isHidden = !isJournalView
    
    }

    
}
