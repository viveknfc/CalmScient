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
    @IBOutlet weak var textCount: UILabel!

    // Three pill buttons replacing the toggle
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var notYetButton: UIButton!

    // Keep toggleImageView as a dummy UIView so existing VC code that sets
    // toggleImageView.tag doesn't crash. Nothing is wired to it in the XIB.
    var toggleImageView: UIView = UIView()
    private var _medicineAnswer: String? = nil

    var instance: UserStartupScreenDayData!

    // Pre-fill from API data (called by VC)
    // 1 = Yes, 0 = No, 2 = Not yet
    var toggleValue: Int? {
        didSet {
            switch toggleValue {
            case 1: applySelection(to: yesButton);    _medicineAnswer = "1"
            case 0: applySelection(to: noButton);     _medicineAnswer = "0"
            case 2: applySelection(to: notYetButton); _medicineAnswer = "2"
            default: deselectAll();                   _medicineAnswer = nil
            }
        }
    }

    private var cellType: UserEntryDayFeedbackTableCell!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        borderView.applyShadow()
        setupJournalTextView()
        setupPillButtons()
    }

    private func setupJournalTextView() {
        journalTextView.layer.borderColor = UIColor.darkGray.withAlphaComponent(0.2).cgColor
        journalTextView.backgroundColor  = UIColor.lightGray.withAlphaComponent(0.1)
        journalTextView.layer.borderWidth = 1.0
        journalTextView.layer.cornerRadius = 4
        journalTextView.textContainerInset = UIEdgeInsets(top: 15, left: 10, bottom: 15, right: 10)
        journalTextView.delegate = self
    }

    private func setupPillButtons() {
        let themeColor = UIColor(named: "AppThemeColor") ?? UIColor(red: 0.36, green: 0.33, blue: 0.72, alpha: 1)
        let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 0
                         ? 1
                         : UserDefaults.standard.integer(forKey: "SelectedLanguageID")

        let titles: [UIButton: String]
        if languageId == 1 {
            titles = [yesButton: "Yes", noButton: "No", notYetButton: "Not yet"]
        } else {
            titles = [yesButton: "Sí", noButton: "No", notYetButton: "Aún no"]
        }

        for (btn, title) in titles {
            btn.setTitle(title, for: .normal)
            btn.layer.cornerRadius = 18
            btn.layer.borderWidth  = 1.5
            btn.layer.borderColor  = UIColor.lightGray.cgColor
            btn.backgroundColor    = .clear
            btn.setTitleColor(UIColor.gray, for: .normal)
            btn.titleLabel?.font   = UIFont(name: "Lexend-Regular", size: 14)
                                      ?? UIFont.systemFont(ofSize: 14, weight: .regular)
            btn.clipsToBounds = true
            _ = themeColor // reference to suppress warning
        }
    }

    // MARK: - Button Actions

    @IBAction func didTapYes(_ sender: UIButton) {
        applySelection(to: yesButton); _medicineAnswer = "1"
        

    }

    @IBAction func didTapNo(_ sender: UIButton) {
        applySelection(to: noButton);  _medicineAnswer = "0"

    }

    @IBAction func didTapNotYet(_ sender: UIButton) {
        applySelection(to: notYetButton); _medicineAnswer = "2"
    }

    private func applySelection(to selected: UIButton) {
        deselectAll()
//        let themeColor = UIColor(named: "AppThemeColor") ?? UIColor(red: 0.36, green: 0.33, blue: 0.72, alpha: 1)
        let selectedFillColor = UIColor(named: "circleCellSelectedColor")
        selected.backgroundColor = selectedFillColor
        selected.layer.borderColor = selectedFillColor?.cgColor
        selected.setTitleColor(.white, for: .normal)
    }

    private func deselectAll() {
        for btn in [yesButton, noButton, notYetButton] {
            guard let btn = btn else { continue }
            btn.backgroundColor = .clear
            btn.layer.borderColor = UIColor.lightGray.cgColor
            btn.setTitleColor(UIColor.gray, for: .normal)
        }
    }

    // MARK: - Data Getters

    func getUpdatedToggleData() -> String? {
        return _medicineAnswer
    }

    func getUpdatedJournalData() -> String? {
        let text = journalTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return text.isEmpty ? nil : text
    }

    // MARK: - Configure

    func updateUIWithCellInstance(instance: UserStartupScreenDayData, cellType: UserEntryDayFeedbackTableCell) {
        self.instance = instance
        self.cellType = cellType

        if cellType == .UserEntryJournalCell {
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            let labelText = languageId == 1 ? (instance.journalData?.journalKey ?? "Daily Journal") : "Diario"
            let attributed = NSMutableAttributedString(string: labelText)
            attributed.append(NSAttributedString(string: " ", attributes: [.foregroundColor: UIColor.red]))
            titleLabel.attributedText = attributed
            textCount.text = "\(journalTextView.text.count)/2000"

        } else if cellType == .UserEntryMedicineCell {
            if UserDefaults.standard.bool(forKey: "Morning") {
                titleLabel.text = AppHelper.getLocalizeString(str: "Did_you_take_your_meds_this_morning")
            } else {
                titleLabel.text = AppHelper.getLocalizeString(str: "Did_you_take_your_meds")
            }
            addRedAsterisk()

        } else if cellType == .UserMoodHoursCell {
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 0
                             ? 1
                             : UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            titleLabel.text = languageId == 1
                ? "Did you take your evening meds?"
                : "¿Tomaste tus medicamentos esta tarde?"
            addRedAsterisk()
        }
    }

    private func addRedAsterisk() {
        guard let text = titleLabel.text else { return }
        let attributed = NSMutableAttributedString(string: text)
        attributed.append(NSAttributedString(string: " ", attributes: [.foregroundColor: UIColor.red]))
        titleLabel.attributedText = attributed
    }

    public func configureJournalView(isJournalView: Bool) {
        yesButton.isHidden    = isJournalView
        noButton.isHidden     = isJournalView
        notYetButton.isHidden = isJournalView
        journalTextView.isHidden = !isJournalView
        textCount.isHidden       = !isJournalView
    }

    // MARK: - UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        instance.journalAnswer = textView.text
        textCount.text = "\(textView.text.count)/2000"
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        if text.contains("<") || text.contains(">") || text.contains("/") { return false }
        if updatedText.count <= 2000 {
            textCount.text = "\(updatedText.count)/2000"
            return true
        }
        return false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

