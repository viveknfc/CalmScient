//
//  JournalEntryEditView.swift
//  CalmscientIOS
//
//  Created by NFC on 29/04/24.
//

import UIKit

protocol JournalEntryEditViewActions:AnyObject {
    func closeAction()
    func saveAction(updatedText:String)
}

class JournalEntryEditView: UIView, UITextViewDelegate {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var entryTitleLabel: UILabel!
    @IBOutlet weak var journalTextView: UITextView!
    @IBOutlet weak var updateButton: LinearGradientButton!
    
    weak var journalEntryEditActionDelegate:JournalEntryEditViewActions?
    var editingIndexPath:IndexPath = IndexPath(row: 0, section: 0)
    lazy var initialText:String = "Add your Journal Here" {
        didSet {
            journalTextView.text = initialText
        }
    }
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
        self.journalTextView.layer.borderColor = UIColor(named: "UserRegistrationTextViewBorderColor")?.cgColor
        self.journalTextView.backgroundColor = UIColor(named: "UserRegistrationTextViewBackgroundColor")
        self.journalTextView.layer.borderWidth = 1.0
        self.journalTextView.layer.cornerRadius = 4
        self.updateButton.setAttributedTitleWithGradientDefaults(title: "Add")
        self.journalTextView.textContainerInset = UIEdgeInsets(top: 15, left: 16, bottom: 15, right: 10)
        self.journalTextView.delegate = self
        
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
        journalEntryEditActionDelegate?.saveAction(updatedText: journalTextView.text)
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
}
