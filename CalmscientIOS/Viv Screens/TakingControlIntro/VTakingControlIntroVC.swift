//
//  VTakingControlIntroVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 12/05/25.
//

import UIKit

class VTakingControlIntroVC: UIViewController {
    
    @IBOutlet weak var introLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var pointLabel: FontLM25!
    
    @IBOutlet weak var submitButton: LinearGradientButton!
    
    var answers: [String?] = []
    var summaryArray: [TakingFirstQueSummary] = []
    var questionnaireArray: [Question] = []
    var assessmentId = Int()
    
    var answersArrayParam: [[String: Any]] = []
    
    var auditScreeningData:[Screening] = []
    var dast10ScreeningData:[Screening] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = AppHelper.getLocalizeString(str: "Taking control introduction")
        
        let headingFont = UIFont(name: Fonts().lexendMedium, size: 16)!
        let bodyFont = UIFont(name: Fonts().lexendLight, size: 14)!
        
        let fullText = AppHelper.getLocalizeString(str: "Taking control Intro")

        let attributedText = NSMutableAttributedString(string: fullText, attributes: [.font: bodyFont])

        // Apply bold to headings
        let heading1 = AppHelper.getLocalizeString(str: "Welcome to taking control!")
        let heading2 = AppHelper.getLocalizeString(str: "CAGE-AID Questionnaire")

        if let range1 = fullText.range(of: heading1) {
            let nsRange1 = NSRange(range1, in: fullText)
            attributedText.addAttribute(.font, value: headingFont, range: nsRange1)
        }

        if let range2 = fullText.range(of: heading2) {
            let nsRange2 = NSRange(range2, in: fullText)
            attributedText.addAttribute(.font, value: headingFont, range: nsRange2)
        }

        introLabel.attributedText = attributedText
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        
        let nib = UINib(nibName: "TakincontrolIntroCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "takinccontrolintroTC")

        getscreeningListAssessmentrId()
        
        //nav bar back button start
        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)

        // Create a UIButton
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonOverrideAction), for: .touchUpInside)

        // Set constraints to adjust the size
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true // Set desired width
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true // Set desired height

        // Create a UIBarButtonItem using the UIButton
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        let multipleAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor(named: "Color") ?? UIColor.white,
            NSAttributedString.Key.font: UIFont(name: Fonts().lexendMedium, size: 18.0) ?? UIFont.systemFont(ofSize: 25.0) ]
        let subtitle = AppHelper.getLocalizeString(str: "Submit")
        let attrButtonName = NSAttributedString(string: subtitle, attributes: multipleAttributes)
        self.submitButton.titleLabel?.attributedText = attrButtonName
        
    }
    
    @objc func backButtonOverrideAction() {

            if #available(iOS 16.0, *) {
                let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "TakingControlIndex") as? TakingControlIndex
                vc?.title = AppHelper.getLocalizeString(str: "Taking control")
                vc?.initialSegmentIndex = 0
                
                self.navigationController?.pushViewController(vc!, animated: true)
            } else {
                // Fallback on earlier versions
            }
        
    }

    
    func updateScoreLabel() {
        let yesCount = answers.compactMap { $0 }.filter { $0 == "Yes" }.count
        pointLabel.text =  "\(yesCount)"
    }
    
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        
        let unansweredIndex = answers.firstIndex(where: { $0 != "Yes" && $0 != "No" })
        
        if let index = unansweredIndex {
            // Show alert if a question is unanswered

            showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: AppHelper.getLocalizeString(str: "Please answer all questions"),
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {},
                showDismissButton: false
            )
            
            return
        }
 
        submitAPICall()
            
    }
    
    //MARK: - Submit API Call
    
    func submitAPICall() {
        self.view.showToastActivity()
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        answersArrayParam.removeAll()
        for question in summaryArray {
            var answerJSON: [String: Any] = [:]
            
            answerJSON["flag"] = "I"
            answerJSON["answerId"] = question.selectedanswerId ?? 0
            answerJSON["optionId"] = question.selectedoptionId ?? 0
            answerJSON["score"] = question.selectedScore ?? 0
            
            answerJSON["questionnaireId"] = question.questionId
            answerJSON["screeningId"] = 5
            
            answerJSON["patientLocationId"] = userInfo.patientLocationID
            answerJSON["clientId"] = userInfo.clientID
            answerJSON["patientId"] = userInfo.patientID
            answerJSON["assessmentId"] = assessmentId
            
            answersArrayParam.append(answerJSON)
        }
        
        let params: [String: Any] = [
            "patientAnswers": answersArrayParam
        ]
        
        print("the submit API call params", params)
        
        APIService.takingccontrolIntrofirstscreenAnswerAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            
            self.submitAPIResponse(response: response)
        }
    }
    
    //MARK: - Submit API Response
        
    func submitAPIResponse(response: AnyObject) {
        DispatchQueue.main.async {
            self.view.hideToastActivity()
            
            if let responseDict = response as? [String: Any],
               let statusResponse = responseDict["statusResponse"] as? [String: Any],
               let responseMessage = statusResponse["responseMessage"] as? String {
                
                // ✅ Show success alert with extracted message
                self.showSuccessAlert(successContent: responseMessage, centreImage: nil, okButtonAction: {
                    let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
                    if let vc = next.instantiateViewController(withIdentifier: "IntroSecondPageVC") as? IntroSecondPageVC {
                        vc.auditData = self.auditScreeningData
                        vc.dastData = self.dast10ScreeningData
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            } else {
                print("Invalid response format or missing keys.")
            }
        }
    }

    
    //MARK: - API call for Screening Questions
    
    func getscreeningListQuestions() {

        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Any] = [
            "assessmentId": assessmentId,
            "screeningId": 5,
            "patientId": userInfo.patientID,
            "patientLocationId": userInfo.patientLocationID,
            "clientId": userInfo.clientID,
            "fromDate": "",
            "toDate": ""
            ]
        
        print("the getscreeningListAssessmentrId API call params", params)
        
        APIService.takingccontrolIntrofirstscreenDataAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            
            self.view.hideToastActivity()
            self.parsethetakingfirstScreen(response: response)
        }
    }
    
    //MARK: - Parsing the Response of Taking control first screen Data
        
    func parsethetakingfirstScreen(response: AnyObject) {

        if let responseString = response as? String {
            print("Response received from Get Drinking Data API calling is", responseString)
        } else if let responseDict = response as? [String: Any] {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                let decoded = try JSONDecoder().decode(TakingIntrofirstScreenQuestions.self, from: jsonData)

                summaryArray.removeAll()
                
                questionnaireArray = decoded.questionnaire
                
                for question in decoded.questionnaire {

                        let summary = TakingFirstQueSummary(
                            questionId: question.questionId,
                            questionName: question.questionName,
                            optionTypeId: question.optionTypeId,
                            selectedanswerId: nil,
                            selectedScore: nil,
                            selectedoptionId: nil,
                            selectedAnswerLabel: ""
                        )
                        summaryArray.append(summary)
                    
                }
                
                print("the summary array is", summaryArray)
                tableView.reloadData()
                answers = Array(repeating: nil, count: summaryArray.count)

            } catch {
                print("Error decoding JSON: \(error)")
            }
        } else {
            print("Unsupported response type:", type(of: response))
        }
    }
    
    //MARK: - API call for assessment ID
    
    func getscreeningListAssessmentrId() {
        self.view.showToastActivity()
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Any] = [
                "patientId": userInfo.patientID,
                "patientLocationId": userInfo.patientLocationID,
                "clientId": userInfo.clientID
            ]
        
        print("the getscreeningListAssessmentrId API call params", params)
        
        APIService.screeningListAssessmentrIdAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in

            self.parsetheAssessmentIdResponse(response: response)
        }
    }
    
    //MARK: - Parsing the Response of assesment id
        
    func parsetheAssessmentIdResponse(response: AnyObject) {

        if let responseString = response as? String {
            print("Response received from Get Drinking Data API calling is", responseString)
        } else if let responseDict = response as? [String: Any] {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                let decodedResponse = try JSONDecoder().decode(ScreeningResponse.self, from: jsonData)
                
                let allScreenings = decodedResponse.screeningList
                
                self.auditScreeningData = allScreenings.filter { $0.screeningType.uppercased() == "AUDIT" }
                self.dast10ScreeningData = allScreenings.filter { $0.screeningType.uppercased() == "DAST-10" }
                
                if let cageAssessment = allScreenings.first(where: { $0.screeningType == "CAGE" }) {
                    assessmentId = cageAssessment.assessmentID
                    print("CAGE Assessment ID: \(cageAssessment.assessmentID)")
                    
                    getscreeningListQuestions()
                    
                } else {
                    print("CAGE screeningType not found.")
                }

            } catch {
                print("Error decoding JSON: \(error)")
            }
        } else {
            print("Unsupported response type:", type(of: response))
        }
    }
    

}

extension VTakingControlIntroVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return summaryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "takinccontrolintroTC", for: indexPath) as? takinccontrolintroTC else {
            return UITableViewCell()
        }
        
        let fullText = summaryArray[indexPath.row].questionName

        // Extract prefix (e.g., "1. ") from the existing text
        let components = fullText.components(separatedBy: " ")
        let numberPrefix = components.first ?? ""

        // Calculate indentation based on the actual prefix
        let font = cell.questionLabel.font ?? UIFont.systemFont(ofSize: 17)
        let indentWidth = (numberPrefix as NSString).size(withAttributes: [.font: font]).width + 4 // +4 for extra spacing

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.firstLineHeadIndent = 0
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
            guard let self = self else { return }
            self.answers[indexPath.row] = "Yes"

            let question = self.questionnaireArray[indexPath.row]
            let yesOption = question.answerResponse[1] // assuming Yes is always index 1

            var summary = self.summaryArray[indexPath.row]
            summary.selectedanswerId = yesOption.answerId
            summary.selectedScore = Int(yesOption.optionScore)
            summary.selectedoptionId = yesOption.optionLabelId
            summary.selectedAnswerLabel = yesOption.optionLabel
            self.summaryArray[indexPath.row] = summary

            self.updateScoreLabel()
            tableView.reloadRows(at: [indexPath], with: .none)
        }

        cell.noTapped = { [weak self] in
            guard let self = self else { return }
            self.answers[indexPath.row] = "No"

            let question = self.questionnaireArray[indexPath.row]
            let noOption = question.answerResponse[0] // assuming No is always index 0

            var summary = self.summaryArray[indexPath.row]
            summary.selectedanswerId = noOption.answerId
            summary.selectedScore = Int(noOption.optionScore)
            summary.selectedoptionId = noOption.optionLabelId
            summary.selectedAnswerLabel = noOption.optionLabel
            self.summaryArray[indexPath.row] = summary

            self.updateScoreLabel()
            tableView.reloadRows(at: [indexPath], with: .none)
        }

        return cell
    }
    
}




