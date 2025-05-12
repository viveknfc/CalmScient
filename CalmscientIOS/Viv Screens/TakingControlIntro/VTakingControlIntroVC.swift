//
//  VTakingControlIntroVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 12/05/25.
//

import UIKit

class VTakingControlIntroVC: ViewController {
    
    @IBOutlet weak var introLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var pointLabel: FontLM25!
    
    let questions = [
        "Have you ever felt that you ought to Cut down on your drinking or drug use?",
        "Have people Annoyed you by criticizing your drinking or drug use?",
        "Have you ever felt bad or Guilty about your drinking or drug use?",
        "Have you ever had a drink or used drugs first thing in the morning to steady your nerves or to get rid of a hangover (Eye opener)?"
    ]
    var answers: [String?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Taking control introduction"
        
        let headingFont = UIFont(name: Fonts().lexendMedium, size: 16)!
        let bodyFont = UIFont(name: Fonts().lexendLight, size: 14)!

        let fullText = """
        Welcome to taking control!
        
        Thank you for being willing to talk about alcohol and drugs. Now let’s begin with a brief assessment.
        
        CAGE-AID Questionnaire
        
        When thinking about drug use, include illegal drug and the use of prescriptions drug use other than prescribed.
        """

        let attributedText = NSMutableAttributedString(string: fullText, attributes: [.font: bodyFont])

        // Apply bold to headings
        let heading1 = "Welcome to taking control!"
        let heading2 = "CAGE-AID Questionnaire"

        if let range1 = fullText.range(of: heading1) {
            let nsRange1 = NSRange(range1, in: fullText)
            attributedText.addAttribute(.font, value: headingFont, range: nsRange1)
        }

        if let range2 = fullText.range(of: heading2) {
            let nsRange2 = NSRange(range2, in: fullText)
            attributedText.addAttribute(.font, value: headingFont, range: nsRange2)
        }

        introLabel.attributedText = attributedText
        
        answers = Array(repeating: nil, count: questions.count)
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        
        let nib = UINib(nibName: "TakincontrolIntroCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "takinccontrolintroTC")

        
    }
    
    func updateScoreLabel() {
        let yesCount = answers.compactMap { $0 }.filter { $0 == "Yes" }.count
        pointLabel.text =  "\(yesCount)"
    }
    
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        self.showSuccessAlert(successContent: "Submitted successfully", centreImage: nil, okButtonAction: {
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "IntroSecondPageVC") as? IntroSecondPageVC
            self.navigationController?.pushViewController(vc!, animated: true)
        })
    }
    

}

extension VTakingControlIntroVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "takinccontrolintroTC", for: indexPath) as? takinccontrolintroTC else {
            return UITableViewCell()
        }
        
        let numberPrefix = "\(indexPath.row + 1). "
        let questionText = questions[indexPath.row]
        let fullText = numberPrefix + questionText
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0
        
        let font = cell.questionLabel.font ?? UIFont.systemFont(ofSize: 17)
        
        let indentWidth = (numberPrefix as NSString).size(withAttributes: [.font: font]).width
        paragraphStyle.headIndent = indentWidth
        
        let attributedString = NSAttributedString(string: fullText, attributes: [
            .paragraphStyle: paragraphStyle,
            .font: font
        ])

        cell.questionLabel.attributedText = attributedString
        
        // Button state
        let selectedAnswer = answers[indexPath.row]

        let activeColor = #colorLiteral(red: 0.3882352941, green: 0.4196078431, blue: 0.7019607843, alpha: 1)

        cell.yesButton.backgroundColor = (selectedAnswer == "Yes") ? activeColor : .white
        cell.yesButton.setTitleColor((selectedAnswer == "Yes") ? .white : .black, for: .normal)

        cell.noButton.backgroundColor = (selectedAnswer == "No") ? activeColor : .white
        cell.noButton.setTitleColor((selectedAnswer == "No") ? .white : .black, for: .normal)

        cell.yesTapped = { [weak self] in
            self?.answers[indexPath.row] = "Yes"
            self?.updateScoreLabel()
            tableView.reloadRows(at: [indexPath], with: .none)
        }

        cell.noTapped = { [weak self] in
            self?.answers[indexPath.row] = "No"
            self?.updateScoreLabel()
            tableView.reloadRows(at: [indexPath], with: .none)
        }

        return cell
    }
    
}
