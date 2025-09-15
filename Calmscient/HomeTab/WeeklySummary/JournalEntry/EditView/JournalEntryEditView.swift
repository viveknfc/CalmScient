//
//  JournalEntryEditView.swift
//  CalmscientIOS
//
//  Created by NFC on 29/04/24.
//

import UIKit

protocol JournalEntryEditViewActions:AnyObject {
    func closeAction()
    func saveAction(updatedText:String, initialText: String)
}

class JournalEntryEditView: UIView, UITextViewDelegate {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var entryTitleLabel: UILabel!
    @IBOutlet weak var journalTextView: UITextView!
    @IBOutlet weak var updateButton: LinearGradientButton!
    @IBOutlet weak var textCount: UILabel!
    
    weak var journalEntryEditActionDelegate:JournalEntryEditViewActions?
    var editingIndexPath:IndexPath = IndexPath(row: 0, section: 0)
    
    var initialText: String = ""
    
//    lazy var initialText: String = {
//        let selectedLanguageID = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
//        return selectedLanguageID == 1 ? "Add your Journal Here" : "Agregue su registro del diario aquí"
//    }() {
//        didSet {
//            journalTextView.text = initialText
//        }
//    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromNib(nibName: "JournalEntryEditView")
        updateTextView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib(nibName: "JournalEntryEditView")
        updateTextView()
    }
    
    private func updateTextView() {
        let selectedLanguageID = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        self.journalTextView.layer.borderColor = UIColor(named: "UserRegistrationTextViewBorderColor")?.cgColor
        self.journalTextView.backgroundColor = UIColor(named: "UserRegistrationTextViewBackgroundColor")
        self.journalTextView.layer.borderWidth = 1.0
        self.journalTextView.layer.cornerRadius = 4
        let updateTitle = selectedLanguageID == 1 ? "Add" : "Agregar"
        self.updateButton.setAttributedTitleWithGradientDefaults(title: updateTitle)
        self.journalTextView.textContainerInset = UIEdgeInsets(top: 15, left: 16, bottom: 15, right: 10)
        
        self.initialText = selectedLanguageID == 1 ? "Add your journal here" : "Agregue su registro del diario aquí"
        journalTextView.text = initialText
        self.journalTextView.delegate = self
        
        self.textCount.text = "0/2000"

        entryTitleLabel.text = selectedLanguageID == 1 ? "Add journal entry" : "Agregar registro del diario"
        
    }
    
    private func loadViewFromNib(nibName: String) {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    @IBAction func didClickOnCloseAction(_ sender: UIButton) {
        journalEntryEditActionDelegate?.closeAction()
    }
    
    @IBAction func didClickOnUpdateAction(_ sender: Any) {
        journalEntryEditActionDelegate?.saveAction(updatedText: journalTextView.text, initialText: initialText)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == initialText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            textView.text = initialText
        }
        textView.resignFirstResponder()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        textCount.text = "\(updatedText.count)/2000"
        return updatedText.count < 2000
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textCount.text = "\(textView.text.count)/2000"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
}
