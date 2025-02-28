//
//  ScreeningQuestionsViewController.swift
//  CalmscientIOS
//
//  Created by NFC on 27/04/24.
//

import UIKit

fileprivate class ScreeningQuestion {
    var question:String
    var options:[String]
    var answerSelectedIndex = -1
    init(question: String, options: [String]) {
        self.question = question
        self.options = options
    }
}

class ScreeningQuestionsViewController: ViewController {
    
    var networkHandler:NetworkAPIRequest = NetworkAPIRequest()
    
    fileprivate var selectedAnswersIdx:[Int] = []
    fileprivate var patientAnsweredOption:[PatientAnswer?] = []
    fileprivate var questionData:[QuestionnaireItem] = [] {
        didSet {
            self.view.hideToastActivity()
            maxPage = questionData.count
            selectedAnswersIdx = Array(repeating: -1, count: questionData.count)
            patientAnsweredOption = Array(repeating: nil, count: questionData.count)
            updateAlreadySelectedAnswers()
            questionsTableView.dataSource = self
            questionsTableView.delegate = self
            self.questionsTableView.reloadData()
        }
    }
    
    @IBOutlet weak var infoButton: UIButton!
//    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var questionsTableView: UITableView!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    
    @IBOutlet weak var completeButton: UIButton!
    public weak var selectedScreening:Screening? = nil
    fileprivate var pageNumber:Int = 0
    fileprivate var maxPage:Int = 0
    
    var screeningAllQuestionsSuccessfullySubmittedClosure:((_ selectedScreening:Screening?) -> Void)? = nil
    
    fileprivate func updateAlreadySelectedAnswers() {
        guard let screeningObject = self.selectedScreening, let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            return
        }
        for (qIdx,question) in questionData.enumerated() {
            for (idx,opt) in question.answerResponse.enumerated() {
                if (opt.answerId != nil) {
                    selectedAnswersIdx[qIdx] = idx
                    patientAnsweredOption[qIdx] = PatientAnswer(from: question, loginDetails: loginResponse, screening: screeningObject, selectedAnswerIndex: idx,AnswerID: opt.answerId)
                    break
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let alertController = UIAlertController(title: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "Information": "Información", message: selectedScreening?.screeningReminder ?? "", preferredStyle: .alert)
        let cancelAction =  UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(cancelAction)
        // Present the alert
        self.present(alertController, animated: true, completion: nil)
        infoButton.isHidden = false
        guard let screeningObject = self.selectedScreening, let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            return
        }
        self.title = screeningObject.screeningType
        backwardButton.isHidden = true
        forwardButton.isHidden = false
        questionsTableView.register(UINib(nibName: "ScreeningQuestionarrieTableViewCell", bundle: nil), forCellReuseIdentifier: "ScreeningQuestionarrieTableViewCell")
        questionsTableView.dataSource = self
        questionsTableView.delegate = self
        questionsTableView.separatorStyle = .none
        questionsTableView.tableFooterView = nil
        questionsTableView.tableHeaderView = nil
//        titleLabel.text = ""
        getQuestionarieForScreening()
        questionsTableView.contentInset = .zero
        questionsTableView.scrollIndicatorInsets = .zero
        questionsTableView.bounces = false
        questionsTableView.alwaysBounceVertical = false
        questionsTableView.alwaysBounceHorizontal = false
        // Do any additional setup after loading the view.
        
        completeButton.isHidden = true
        completeButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14)
    }
    
//    var flag: String
//    var answerId: Int
//    var screeningId: Int
//    var patientLocationId: Int
//    var questionnaireId: Int
//    var optionId: Int
//    var score: Int
//    var clientId: Int
//    var patientId: Int
//    var assessmentId: Int
    
    fileprivate func sendPatientSelectedAnswersToServer() {
        self.view.showToastActivity()
        let onlySelectedAnswers = patientAnsweredOption.compactMap({$0})
        var answersArray:[[String:Any]] = []
        for answer in onlySelectedAnswers {
            var answerJSON:[String:Any] = [:]
            answerJSON["flag"] = answer.flag
            answerJSON["answerId"] = answer.answerId
            answerJSON["screeningId"] = answer.screeningId
    
            answerJSON["patientLocationId"] = answer.patientLocationId
            answerJSON["questionnaireId"] = answer.questionnaireId
            answerJSON["optionId"] = answer.optionId
            
            answerJSON["score"] = answer.score
            answerJSON["clientId"] = answer.clientId
            answerJSON["patientId"] = answer.patientId
            
            answerJSON["assessmentId"] = answer.assessmentId
            answersArray.append(answerJSON)
        }
        let requestBodyParams:[String:Any] = ["patientAnswers":answersArray]
        let requestForm = ScreeningAnswersSavedRequestForm(requestBodyParams)
        guard let requestURL = requestForm.getURLRequest() else {
            self.view.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }
        NetworkAPIRequest.sendRequest(request: requestURL) { [weak self](response: ScreeningAnswersSavedResponse?, failureResponse: FailureResponse?, error: Error?) in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.view.hideToastActivity()
                if let _ = error {
                    self.view.showToast(message: "An Unknown error occured. Please check with Admin")
                } else if let response = response {
                    if response.statusResponse.responseCode == 200 {
                        let alertController = UIAlertController(title: AppHelper.getLocalizeString(str:  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Screening" : "Cribado"), message: response.statusResponse.responseMessage, preferredStyle: .alert)
                        // Add an action button to the alert
                        let okAction = UIAlertAction(title: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "OK" : "DE ACUERDO", style: .default) { _ in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                self.screeningAllQuestionsSuccessfullySubmittedClosure?(self.selectedScreening)
                            })
                        }
                        alertController.addAction(okAction)
                        DispatchQueue.main.async {
                            self.present(alertController, animated: true, completion: nil)
                        }
                    } else {
                        let alertController = UIAlertController(title: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Screening" : "Cribado", message: response.statusResponse.responseMessage, preferredStyle: .alert)
                        // Add an action button to the alert
                        let okAction = UIAlertAction(title: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "OK" : "DE ACUERDO", style: .default) { _ in
                                self.navigationController?.popViewController(animated: true)
                        }
                        alertController.addAction(okAction)
                        DispatchQueue.main.async {
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                } else if let failureResponse = failureResponse {
                    self.view.showToast(message: failureResponse.statusResponse.responseMessage)
                }
            }
        }
    }
    
    fileprivate func getQuestionarieForScreening() {
        self.view.showToastActivity()
        var prepareRequestBodyParams:[String:Any] = [:]
        guard let screeningObject = self.selectedScreening, let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            return
        }
        prepareRequestBodyParams["screeningId"] = screeningObject.screeningID
        prepareRequestBodyParams["assessmentId"] = screeningObject.assessmentID
        
        prepareRequestBodyParams["patientLocationId"] = loginResponse.patientLocationID
        prepareRequestBodyParams["patientId"] = loginResponse.patientID
        prepareRequestBodyParams["clientId"] = loginResponse.clientID
        
        prepareRequestBodyParams["fromDate"] = ""
        prepareRequestBodyParams["toDate"] = ""
        
        let questonariesRequest = ScreeningQuestionarieForm(prepareRequestBodyParams)
        guard let requestURL = questonariesRequest.getURLRequest() else {
            self.view.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }
        NetworkAPIRequest.sendRequest(request: requestURL) { [weak self](response: QuestionnaireResponse?, failureResponse: FailureResponse?, error: Error?) in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
//                self.titleLabel.text = self.selectedScreening?.screeningReminder
                self.view.hideToastActivity()
                self.view.hideToastActivity()
                if let _ = error {
                    self.view.showToast(message: "An Unknown error occured. Please check with Admin")
                } else if let response = response {
                    self.questionData = response.questionnaire
                    print("self.questionData===\(self.questionData)")
                    self.questionsTableView.reloadData()
                } else if let failureResponse = failureResponse {
                    self.view.showToast(message: failureResponse.statusResponse.responseMessage)
                    self.questionsTableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func didClickOnBackWardButton(_ sender: Any) {
        let tempPageNo = pageNumber - 1
//        titleLabel.text = ""
//        titleLabel.sizeToFit()
        if tempPageNo >= 0 && tempPageNo < maxPage {
            pageNumber = tempPageNo
            UIView.transition(with: questionsTableView,
                              duration: 0.35,
                              options: .transitionCrossDissolve,
                              animations: {                self.questionsTableView.reloadData()

            })
        }
        if pageNumber == 0 {
            infoButton.isHidden = false
//            titleLabel.text = selectedScreening?.screeningReminder
//            titleLabel.sizeToFit()
            forwardButton.isHidden = false
            backwardButton.isHidden = true
            completeButton.isHidden = true
        } else if pageNumber == maxPage - 1 {
            infoButton.isHidden = true
            forwardButton.isHidden = false
            backwardButton.isHidden = false
        } else {
            infoButton.isHidden = true
            forwardButton.isHidden = false
            backwardButton.isHidden = false
            completeButton.isHidden = true
        }
    }
    
    @IBAction func didClickOnInfoButton(_ sender: Any) {
        let alertController = UIAlertController(title: AppHelper.getLocalizeString(str:"Information") , message: selectedScreening?.screeningReminder ?? "", preferredStyle: .alert)
        let cancelAction =  UIAlertAction(title: "Ok", style: .default)
        alertController.addAction(cancelAction)
        // Present the alert
        self.present(alertController, animated: true, completion: nil)
        
    }
    @IBAction func didClickOnForwardButton(_ sender: Any) {
        
        print("page number is",pageNumber, "Max page number is",maxPage)
        
        if pageNumber == maxPage - 1 {

        } else {
            let tempPageNo = pageNumber + 1
            
            if tempPageNo >= 0 && tempPageNo < maxPage {
                pageNumber = tempPageNo
                UIView.transition(with: questionsTableView,
                                  duration: 0.45,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    self.questionsTableView.reloadData()
                })
            }
        }

            if pageNumber == 0 {
                infoButton.isHidden = false
                forwardButton.isHidden = false
                backwardButton.isHidden = true
            } else if pageNumber == maxPage - 1 {
                infoButton.isHidden = true
                forwardButton.isHidden = true
                completeButton.isHidden = false
                backwardButton.isHidden = false
            } else {
                infoButton.isHidden = true
                forwardButton.isHidden = false
                backwardButton.isHidden = false
            }
        
        
    }
    
    //viv complete button
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        print(patientAnsweredOption)
        if(patientAnsweredOption.compactMap({$0}).count == 0){
            // create the alert
            let alert = UIAlertController(title: "", message:UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Please answer the questions": "Por favor, responde las preguntas", preferredStyle: UIAlertController.Style.alert)

                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                    // show the alert
                    self.present(alert, animated: true, completion: nil)
        }else{
            self.sendPatientSelectedAnswersToServer()
        }
    }
    

}

extension ScreeningQuestionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if maxPage > 0 {
            return questionData[pageNumber].answerResponse.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if maxPage > 0 {
//            let possibleWidth =  tableView.bounds.width - 64
//            let view = QuestionHeaderView(frame: CGRect(x: 0, y: 0, width: possibleWidth - 64, height: 1000))
//            view.headerLabel.text = "\(pageNumber + 1). \(questionData[pageNumber].questionName)"
//            view.headerLabel.sizeToFit()
//            return  view.headerLabel.bounds.size.height
            
                let width = tableView.frame.width
                return calculateHeaderHeight(for: "\(pageNumber + 1). \(questionData[pageNumber].questionName)", width: tableView.bounds.width - 64)
        } else {
            return 0
        }
       
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if maxPage > 0 {
            let view = QuestionHeaderView()
          //  view.headerLabel.text = "\(pageNumber + 1). \(questionData[pageNumber].questionName)"
            view.headerLabel.font = UIFont(name: Fonts().lexendMedium, size: 20)
            view.headerLabel.text = "\(questionData[pageNumber].questionName)"
            return view
        } else {
            return nil
        }
      
    }
    
    func calculateHeaderHeight(for text: String, width: CGFloat) -> CGFloat {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = text
        label.font = UIFont(name: Fonts().lexendMedium, size: 20) // Use the appropriate font
        
        let maxSize = CGSize(width: width - 64, height: CGFloat.greatestFiniteMagnitude) // 64 accounts for the leading and trailing padding
        let size = label.sizeThatFits(maxSize)

        return size.height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScreeningQuestionarrieTableViewCell", for: indexPath) as! ScreeningQuestionarrieTableViewCell
        cell.cellTextLabel.text = questionData[pageNumber].answerResponse[indexPath.row].optionLabel
        cell.selectionStyle = .none
        if indexPath.row == selectedAnswersIdx[pageNumber] {
            cell.applyFill(isSelected: true)
        } else {
            cell.applyFill(isSelected: false)
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let screeningObject = self.selectedScreening, let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            return
        }
        selectedAnswersIdx[pageNumber] = indexPath.row
        let answerID = "\(patientAnsweredOption[pageNumber]?.answerId ?? 0)"
        patientAnsweredOption[pageNumber] = PatientAnswer(from: questionData[pageNumber], loginDetails: loginResponse, screening: screeningObject, selectedAnswerIndex: indexPath.row, AnswerID: answerID)
        tableView.reloadData()
    }
    
    
}


