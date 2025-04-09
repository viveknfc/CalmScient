//
//  TakingControllIntro.swift
//  CalmscientIOS
//
//  Created by mac on 25/05/24.
//

import Foundation
import UIKit

class TakingControllIntro: UIViewController,UITableViewDelegate,UITableViewDataSource,QuestionAlertAlertViewActionProtocol {
    var screeningData:[Screening] = []
    var previouslySelectedIndexPath: Int?
    var networkHandler:NetworkAPIRequest = NetworkAPIRequest()
    let screeningRequest = ScreeningListRequestForm()
    
    
    fileprivate var questionAlertBackGroundView:UIView?
    fileprivate var infoAlertBackGroundView:UIView?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoButton: UIButton!
    
    var data: [String] = []
    var introData: [Any] = []
    
    var auditFlag: Int = 0
    var dastFlag: Int = 0
    var cageFlag: Int = 0

    var auditFlag1 : Int?
    var dastFlag1 : Int?
    var cageFlag1 : Int?
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    var doesttext = ""
    var applytometext = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
       
        getScreeningData()
        tableView.dataSource = self
        tableView.delegate = self
        
        title = "Taking control introduction"
        self.navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        
        getTakingControlIntroAPICalling()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let selectedLanguageID = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        data = [
            selectedLanguageID == 1 ? "AUDIT" : "AUDITORÍA",
            selectedLanguageID == 1 ? "DUST-10" : "POLVO-10",
            selectedLanguageID == 1 ? "CAGE" : "JAULA"
        ]
        
        headerLabel.text = (selectedLanguageID != 0) ? "Welcome to taking control!" : "¡Bienvenido a tomar el control!"
        descriptionLabel.text = (selectedLanguageID != 0) ? "Thank you for being willing to talk about alcohol and drugs. Now let’s begin with a brief assessment." : "Gracias por estar dispuesto a hablar sobre el alcohol y las drogas. Ahora comencemos con una breve evaluación."
        
        doesttext = selectedLanguageID == 1 ? "Doesn't apply to me" : "No se aplica a mi"
        applytometext = selectedLanguageID == 1 ? "Apply to me" : "Aplicarme"

        
        tableView.reloadData()

    }

    
    //MARK: - Get Taking Control Intro Data API Calling
    
    func getTakingControlIntroAPICalling() {
        self.view.showToastActivity()
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Any] = [
            "clientId":userInfo.clientID,
            "patientId": userInfo.patientID,
            "plId":userInfo.patientLocationID
        ]

        APIService.getTakingControlIntroAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            self.getresponseforGetTakingControlIntroAPI(response: response)
        }
    }
    
    //MARK: - Get Taking Control Intro Data API Response
    
    func getresponseforGetTakingControlIntroAPI(response: Any) {
        self.view.hideToastActivity()
        
        if let responseDict = response as? [String: Any] {
            print("Response from Get Taking Control Intro Data:", responseDict)

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                let decodedResponse = try JSONDecoder().decode(IntroductionResponse.self, from: jsonData)

                auditFlag = decodedResponse.takingControlIntroduction.result.auditFlag
                cageFlag = decodedResponse.takingControlIntroduction.result.cageFlag
                dastFlag = decodedResponse.takingControlIntroduction.result.dastFlag

                print("Audit Flag: \(String(describing: auditFlag))")
                print("Cage Flag: \(String(describing: cageFlag))")
                print("DAST Flag: \(String(describing: dastFlag))")

                tableView.reloadData()
                // 👉 You can now use these flags however you want (e.g. update UI)

            } catch {
                print("Decoding failed with error:", error)
            }

        } else {
            print("Unsupported response type:", type(of: response))
        }
    }

    //END
    
    func getScreeningData() {
        screeningData = []
        guard let requestURL = screeningRequest.getURLRequest() else {
            self.view.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }
        NetworkAPIRequest.sendRequest(request: requestURL) { [weak self](response: ScreeningResponse?, failureResponse: FailureResponse?, error: Error?) in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.view.hideToastActivity()
                if let _ = error {
                    self.view.showToast(message: "An Unknown error occured. Please check with Admin")
                } else if let response = response {
                    self.screeningData = response.screeningList
                } else if let failureResponse = failureResponse {
                    self.view.showToast(message: failureResponse.statusResponse.responseMessage)
                }
            }
            
        }
    }

    @available(iOS 16.0, *)
    @IBAction func forwardButtonAction(_ sender: Any) {
                let next = UIStoryboard(name: "introductionTakingPage", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "introductionTakingPage") as? introductionTakingPage
        print(AppHelper.getLocalizeString(str: "Taking control introduction"));
        vc?.title = AppHelper.getLocalizeString(str: "Taking control introduction")
                self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    func saveTakingControlIntroduction(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void){
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/takingControl/saveTakingControlIntroduction") else {
            print("Invalid URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        
        // Define the JSON payload
        let payload: [String: Any] = [
            
            "patientId": patientId,
            "clientId": clientId,
            "plId":plId,
            "introductionFlag": 0,
            "auditFlag": auditFlag1 as Any,
            "dastFlag": dastFlag1 as Any,
            "cageFlag": cageFlag1 as Any,
            "tutorialFlag": 0
        ]
        
        print("payload\(payload)")
        // Convert the payload to JSON data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            print(jsonData)
        } catch {
            print("Error converting payload to JSON: \(error)")
            completion(.failure(error))
            return
        }
        
        // Create the URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with request: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                print("Response JSON: \(jsonResponse)")
            } catch {
                print("Error parsing JSON response: \(error)")
                completion(.failure(error))
                return
            }
            // If needed, handle the response here
            completion(.success(data))
        }
        
        // Start the data task
        task.resume()
    }
    
    
    
    func updateTakingControlIndex(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void){
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/takingControl/updateTakingControlIndex") else {
            print("Invalid URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        
        // Define the JSON payload
        let payload: [String: Any] = [
            
            
            "patientId": patientId,
            "clientId": clientId,
            "plId":plId,
            "courseId":1,
            "isCompleted":1
            
        ]
        
        
        print("payload\(payload)")
        // Convert the payload to JSON data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            print(jsonData)
        } catch {
            print("Error converting payload to JSON: \(error)")
            completion(.failure(error))
            return
        }
        
        // Create the URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with request: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                print("Response JSON: \(jsonResponse)")
            } catch {
                print("Error parsing JSON response: \(error)")
                completion(.failure(error))
                return
            }
            // If needed, handle the response here
            completion(.success(data))
        }
        
        // Start the data task
        task.resume()
    }
    fileprivate lazy var questionAlertView:QuestionAlert = {
        let questionAlertView = QuestionAlert(frame: .zero)
        questionAlertView.contentLabel.text =  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Are you sure?" : "Estas segura?"
       
        //        questionAlertView.titleLabel.text = "Delete"
        questionAlertView.alertIconImage.image = UIImage(named: "question2")
        questionAlertView.alertActionDelegate = self
        return questionAlertView
    }()
    fileprivate func showDeleteAlertMessageView(value:String) {
        questionAlertBackGroundView = UIView(frame: .zero)
        questionAlertBackGroundView?.frame = self.view.frame
        questionAlertBackGroundView?.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        questionAlertBackGroundView?.addSubview(questionAlertView)
        questionAlertView.translatesAutoresizingMaskIntoConstraints = false
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.navigationController?.navigationBar.layer.zPosition = -1
            self.view.addSubview(self.questionAlertBackGroundView!)
        }, completion: nil)
        questionAlertView.layer.cornerRadius = 10
        
        if auditFlag == 0 {
            questionAlertView.contentLabel.text = "\(value) \(applytometext)"
        }
        if auditFlag == 1 {
            questionAlertView.contentLabel.text = "\(value) \(doesttext)"
        }
        if dastFlag == 0 {
            questionAlertView.contentLabel.text = "\(value) \(applytometext)"
        }
        if dastFlag == 1{
            questionAlertView.contentLabel.text = "\(value) \(doesttext)"
        }
        
        if cageFlag == 0 {
            questionAlertView.contentLabel.text = "\(value) \(applytometext)"
        }
        if cageFlag == 1{
            questionAlertView.contentLabel.text = "\(value) \(doesttext)"
        }
        //questionAlertView.contentLabel.text = "\(value) doesn't apply to me"
        questionAlertView.layer.masksToBounds = true
        questionAlertView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        questionAlertView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        questionAlertView.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.9).isActive = true
        questionAlertView.heightAnchor.constraint(equalToConstant: 275).isActive = true
    }


    
    @IBAction func infoTapped(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
        if let customAlertVC = storyboard.instantiateViewController(withIdentifier: "InfoButtonVC") as? InfoButtonVC {
            customAlertVC.modalPresentationStyle = .overFullScreen
            customAlertVC.modalTransitionStyle = .crossDissolve
            self.present(customAlertVC, animated: true, completion: nil)
        }

    }
    
//    @IBAction func back_action(_ sender: UIButton) {
//        self.navigationController?.popViewController(animated: true) //showGeneralAlertYesNo
//    }
    func didClickOnYESButton() {
        print("YES button clicked")
        
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        if previouslySelectedIndexPath == 0{
            if auditFlag == 1 {
                auditFlag1 = 0
            } else {
                auditFlag1 = 1
            }
            dastFlag1 = dastFlag
            cageFlag1 = cageFlag
        }
        if previouslySelectedIndexPath == 1{
            if dastFlag == 1 {
                dastFlag1 = 0
            } else {
                dastFlag1 = 1
            }
            auditFlag1 = auditFlag
            cageFlag1 = cageFlag
            
        }
        if previouslySelectedIndexPath == 2{
            if cageFlag == 1 {
                cageFlag1 = 0
            } else {
                cageFlag1 = 1
            }
            auditFlag1 = auditFlag
            dastFlag1 = dastFlag
        }
        
        self.view.showToastActivity()
        saveTakingControlIntroduction( plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            print(json)
                          
                            auditFlag = auditFlag1 ?? 0
                            dastFlag = dastFlag1 ?? 0
                            cageFlag = cageFlag1 ?? 0
                            tableView.reloadData()
                            self.view.hideToastActivity()
                           
                        }
                        
                    } else {
                        print("Unable to convert data to JSON")
                    }
                } catch {
                    print("Error converting data to JSON: \(error)")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.questionAlertView.removeFromSuperview()
            self.questionAlertBackGroundView?.removeFromSuperview()
            self.questionAlertBackGroundView = nil
            self.navigationController?.navigationBar.layer.zPosition = 0
        }, completion: nil)
        
        
    }
    
    func didClickOnNOButton() {
        print("NO button clicked")
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.questionAlertView.removeFromSuperview()
            self.questionAlertBackGroundView?.removeFromSuperview()
            self.questionAlertBackGroundView = nil
            self.navigationController?.navigationBar.layer.zPosition = 0
        }, completion: nil)
    }
    func didClickOnAlertmessage(index:IndexPath) {
        showDeleteAlertMessageView(value: data[index.row])
        
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        print("Button tapped in row!")
        // Determine the indexPath of the button tapped
        let point = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) {
           // print(indexPath.row)
            previouslySelectedIndexPath = indexPath.row
            
            if indexPath.row == 0{
                auditFlag1 = 0
                dastFlag1 = dastFlag
                cageFlag1 = cageFlag
            }
            if indexPath.row == 1{
                dastFlag1 = 0
                auditFlag1 = auditFlag
                cageFlag1 = cageFlag
            }
            if indexPath.row == 2{
                cageFlag1 = 0
                auditFlag1 = auditFlag
                dastFlag1 = dastFlag
               
            }
            print("auditFlag==\(auditFlag1 ?? 0)")
            print("dastFlag==\(dastFlag1 ?? 0)")
            print("cageFlag==\(cageFlag1 ?? 0)")
            
            
            showDeleteAlertMessageView(value: data[indexPath.row])
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.main_view.layer.cornerRadius = 10
        cell.main_view.layer.borderWidth = 1
        cell.main_view.layer.borderColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 0.2).cgColor
        cell.name_label.text = data[indexPath.row]
        cell.selectionStyle = .none
        
        if indexPath.row == 0 {
            if auditFlag == 1 {
                
                cell.action_button.setTitle(doesttext, for: .normal)
                cell.selectionStyle = .none
                cell.main_view.backgroundColor = UIColor(named: "AppBackGroundColor")

            }
            else if auditFlag == 0{
                cell.action_button.setTitle(applytometext, for: .normal)
                cell.selectionStyle = .none
                cell.main_view.backgroundColor = UIColor(named: "barColor3")

            }
        }
    
    
    if indexPath.row == 1 {
        if dastFlag == 1{
            cell.action_button.setTitle(doesttext, for: .normal)
            cell.selectionStyle = .none
            cell.main_view.backgroundColor = UIColor(named: "AppBackGroundColor")
        }
        else if dastFlag == 0 {
            cell.action_button.setTitle(applytometext, for: .normal)
            cell.selectionStyle = .none
            cell.main_view.backgroundColor = UIColor(named: "barColor3")
        }
    }
    if indexPath.row == 2 {
        if cageFlag == 1{
            cell.action_button.setTitle(doesttext, for: .normal)
            cell.selectionStyle = .none
            cell.main_view.backgroundColor = UIColor(named: "AppBackGroundColor")
        }
        else if cageFlag == 0 {
            cell.action_button.setTitle(applytometext, for: .normal)
            cell.selectionStyle = .none
            cell.main_view.backgroundColor = UIColor(named: "barColor3")
        }
    }

//    cell.action_button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
    //viv start
        
        // Configure button action
        cell.onButtonTap = { [weak self] in
            guard let self = self else { return }
            self.handleAlertForRow(at: indexPath.row)
        }

    //end
    
    return cell
}
    
    //MARK: - Alert Function
    
    func handleAlertForRow(at index: Int) {
        var flagValue = 0
        var flagName = ""
        var updateFlag: ((Int) -> Void)? = nil

        switch index {
        case 0:
            flagValue = auditFlag
            flagName = data[0]
            updateFlag = { self.auditFlag = $0 }
        case 1:
            flagValue = dastFlag
            flagName = data[1]
            updateFlag = { self.dastFlag = $0 }
        case 2:
            flagValue = cageFlag
            flagName = data[2]
            updateFlag = { self.cageFlag = $0 }
        default:
            return
        }

        let subTitle = flagValue == 0 ? "\(flagName) \(applytometext)" : "\(flagName) \(doesttext)"

        showGeneralAlertYesNo(
            title: flagName,
            subTitle: subTitle,
            okButtonTitle: "Yes",
            cancelButtonTitle: "No",
            okAction: {
                let newFlag = flagValue == 0 ? 1 : 0
                updateFlag?(newFlag)
                print("Updated \(flagName) flag to \(newFlag)")
                // optionally reload this row only
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        )
    }


    
    //END

        
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let screeningID = 3
            if auditFlag == 0{
                
            }
            else if auditFlag == 1{
                if let selectedScreening = screeningData.filter({ $0.screeningID == screeningID }).first {
                    let storyboard = UIStoryboard(name: "ScreeningQuestions", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "ScreeningQuestionsViewController") as? ScreeningQuestionsViewController {
                        vc.selectedScreening = selectedScreening
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                
            }
        }
        if indexPath.row == 1 {
            let screeningID1 = 4
            if dastFlag == 0 {
                
            }
            else if dastFlag == 1 {
                if let selectedScreening = screeningData.filter({ $0.screeningID == screeningID1 }).first {
                    let storyboard = UIStoryboard(name: "ScreeningQuestions", bundle: nil)
                    if let vc = storyboard.instantiateViewController(withIdentifier: "ScreeningQuestionsViewController") as? ScreeningQuestionsViewController {
                        vc.selectedScreening = selectedScreening
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
   
    
}
