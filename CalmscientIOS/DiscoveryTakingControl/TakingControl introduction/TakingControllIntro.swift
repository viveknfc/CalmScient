//
//  TakingControllIntro.swift
//  CalmscientIOS
//
//  Created by mac on 25/05/24.
//

import Foundation
import UIKit

class TakingControllIntro: ViewController,UITableViewDelegate,UITableViewDataSource,QuestionAlertAlertViewActionProtocol, InfoAlertViewActionProtocol {
    var screeningData:[Screening] = []
    var previouslySelectedIndexPath: Int?
    var networkHandler:NetworkAPIRequest = NetworkAPIRequest()
    let screeningRequest = ScreeningListRequestForm()
    
    
    fileprivate var questionAlertBackGroundView:UIView?
    fileprivate var infoAlertBackGroundView:UIView?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoButton: UIButton!
    //    @IBOutlet weak var alcholnowView: UIView!
    //    @IBOutlet weak var drinkgoalView: UIView!
    //    @IBOutlet weak var drinknowView: UIView!
    //    @IBOutlet weak var basicKnowledge: UIButton!
    //    @IBOutlet weak var labelsContainerView: UIView!
    
    var data = ["AUDIT","DUST-10","CAGE"]
    var introData: [Any] = []
    var auditFlag : Int?
    var dastFlag : Int?
    var cageFlag : Int?
    var auditFlag1 : Int?
    var dastFlag1 : Int?
    var cageFlag1 : Int?
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    var doesttext = ""
    var applytometext = ""
    override func viewDidLoad() {
        
        super.viewDidLoad()
        doesttext = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Doesn't apply to me" : "No se aplica a mi"
        applytometext = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Apply to me" : "Aplicarme"
        getScreeningData()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
        
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        updateTakingControlIndex( plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            print(json)
                            
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
        
        self.view.showToastActivity()
        
        getTakingControlIntroduction(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            self.view.hideToastActivity()
                            if let introData = json["takingControlIntroduction"] as? [String: Any] {
                                if let auditFlagValue = introData["auditFlag"] as? Int {
                                    auditFlag = auditFlagValue
                                    print("auditFlag\(auditFlag ?? 0)")
                                } else {
                                    print("auditFlag not found or not an Int")
                                }
                                if let dustFlagValue = introData["dastFlag"] as? Int {
                                    dastFlag = dustFlagValue
                                    print("dastFlag\(dastFlag ?? 0)")
                                   
                                } else {
                                    print("dustFlagValue not found or not an Int")
                                }
                                if let cageFlagFlagValue = introData["cageFlag"] as? Int {
                                    cageFlag = cageFlagFlagValue
                                    print("cageFlag\(cageFlag ?? 0)")
                                  

                                } else {
                                    print("cageFlag not found or not an Int")
                                }
                                tableView.reloadData()
                                self.view.hideToastActivity()
                            } else {
                                print("Unable to cast takingControlIntroduction to [String: Any]")
                            }
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
    }
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
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
        data = [UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "AUDIT" : "AUDITORÍA" ,
                    
                    UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "DUST-10" : "POLVO-10" ,
                    UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "CAGE" : "JAULA"]
        tableView.reloadData()
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        self.view.showToastActivity()
        
        getTakingControlIntroduction(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            self.view.hideToastActivity()
                            if let introData = json["takingControlIntroduction"] as? [String: Any] {
                                if let auditFlagValue = introData["auditFlag"] as? Int {
                                    auditFlag = auditFlagValue
                                    print("auditFlag\(auditFlag ?? 0)")
                                } else {
                                    print("auditFlag not found or not an Int")
                                }
                                if let dustFlagValue = introData["dastFlag"] as? Int {
                                    dastFlag = dustFlagValue
                                    print("dastFlag\(dastFlag ?? 0)")
                                   
                                } else {
                                    print("dustFlagValue not found or not an Int")
                                }
                                if let cageFlagFlagValue = introData["cageFlag"] as? Int {
                                    cageFlag = cageFlagFlagValue
                                    print("cageFlag\(cageFlag ?? 0)")
                                  

                                } else {
                                    print("cageFlag not found or not an Int")
                                }
                                tableView.reloadData()
                                self.view.hideToastActivity()
                            } else {
                                print("Unable to cast takingControlIntroduction to [String: Any]")
                            }
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
    }
    
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
                
                
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
                
               
            }
    //    self.title = AppHelper.getLocalizeString(str: "Taking Control Introduction")
        
        
        headerLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Welcome to taking control!" : "¡Bienvenido a tomar el control!"
        descriptionLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Thank you for being willing to talk about alcohol and drugs. Now let’s begin with a brief assessment." : "Gracias por estar dispuesto a hablar sobre el alcohol y las drogas. Ahora comencemos con una breve evaluación."
        
       
        
        }
    @available(iOS 16.0, *)
    @IBAction func forwardButtonAction(_ sender: Any) {
                let next = UIStoryboard(name: "introductionTakingPage", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "introductionTakingPage") as? introductionTakingPage
        print(AppHelper.getLocalizeString(str: "Taking control introduction"));
        vc?.title = AppHelper.getLocalizeString(str: "Taking control introduction")
                self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    //override func viewWillAppear(_ animated: Bool) {
//    tableView.reloadData()
//    print("viewWillAppear")
//        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
//            fatalError("Unable to found Application Shared Info")
//        }
//        
//        self.view.showToastActivity()
//        getTakingControlIntroduction(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
//            switch result {
//            case .success(let data):
//                // Convert data to JSON object and print it
//                do {
//                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                        DispatchQueue.main.async { [self] in
//                            self.view.hideToastActivity()
//                            if let introData = json["takingControlIntroduction"] as? [String: Any] {
//                                if let auditFlagValue = introData["auditFlag"] as? Int {
//                                    auditFlag = auditFlagValue
//                                    print("auditFlag\(auditFlag ?? 0)")
//                                } else {
//                                    print("auditFlag not found or not an Int")
//                                }
//                                if let dustFlagValue = introData["dastFlag"] as? Int {
//                                    dastFlag = dustFlagValue
//                                    print("dastFlag\(dastFlag ?? 0)")
//                                   
//                                } else {
//                                    print("dustFlagValue not found or not an Int")
//                                }
//                                if let cageFlagFlagValue = introData["cageFlag"] as? Int {
//                                    cageFlag = cageFlagFlagValue
//                                    print("cageFlag\(cageFlag ?? 0)")
//                                  
//
//                                } else {
//                                    print("cageFlag not found or not an Int")
//                                }
//                                tableView.reloadData()
//                                self.view.hideToastActivity()
//                            } else {
//                                print("Unable to cast takingControlIntroduction to [String: Any]")
//                            }
//                        }
//                    } else {
//                        print("Unable to convert data to JSON")
//                    }
//                } catch {
//                    print("Error converting data to JSON: \(error)")
//                }
//            case .failure(let error):
//                print("Error: \(error)")
//            }
//        }
//    }
    func getTakingControlIntroduction(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void){
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/takingControl/getTakingControlIntroduction") else {
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
//        {
//        "patientId": 4,
//        "clientId": 1,
//        "plId": 4,
//        "introductionFlag": 0,
//        "auditFlag": null,
//        "dastFlag": 0,
//        "cageFlag": null,
//        "tutorialFlag": null
//        }
        
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
        questionAlertView.heightAnchor.constraint(equalToConstant: 333).isActive = true
    }
    fileprivate lazy var infoAlertView:InfoAlert = {
        let infoAlertView = InfoAlert(frame: .zero)
        
        //        questionAlertView.titleLabel.text = "Delete"
        infoAlertView.alertActionDelegate =  self
        
        return infoAlertView
    }()
    fileprivate func showinfoAlertMessageView() {
        infoAlertBackGroundView = UIView(frame: .zero)
        infoAlertBackGroundView?.frame = self.view.frame
        infoAlertBackGroundView?.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        infoAlertBackGroundView?.addSubview(infoAlertView)
        infoAlertView.translatesAutoresizingMaskIntoConstraints = false
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.navigationController?.navigationBar.layer.zPosition = -1
            self.view.addSubview(self.infoAlertBackGroundView!)
        }, completion: nil)
        infoAlertView.layer.cornerRadius = 10
        infoAlertView.layer.masksToBounds = true
        infoAlertView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        infoAlertView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        infoAlertView.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.9).isActive = true
        infoAlertView.heightAnchor.constraint(equalToConstant: 750).isActive = true
    }
    
    @IBAction func infoTapped(_ sender: UIButton) {
        showinfoAlertMessageView()
    }
    @IBAction func back_action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
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
//        print("flag1====\(auditFlag1 ?? 0)")
//        print("dastFlag1====\(dastFlag1 ?? 0)")
//        print("dastFlag1====\(cageFlag1 ?? 0)")
//        
//        print("flag====\(auditFlag ?? 0)")
//        print("dastFlag====\(dastFlag ?? 0)")
//        print("cageFlag====\(cageFlag ?? 0)")
        
        self.view.showToastActivity()
        saveTakingControlIntroduction( plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            print(json)
                          
                            auditFlag = auditFlag1
                            dastFlag = dastFlag1
                            cageFlag = cageFlag1
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

        
//        self.view.showToastActivity()
//        getTakingControlIntroduction(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
//            switch result {
//            case .success(let data):
//                // Convert data to JSON object and print it
//                do {
//                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                        DispatchQueue.main.async { [self] in
//                            self.view.hideToastActivity()
//                            print("getTakingControlIntroduction")
//                            if let introData = json["takingControlIntroduction"] as? [String: Any] {
//                                if let auditFlagValue = introData["auditFlag"] as? Int {
//                                    auditFlag = auditFlagValue
//                                    print("auditFlag123\(auditFlag ?? 0)")
//                                } else {
//                                    print("auditFlag not found or not an Int")
//                                }
//                                if let dustFlagValue = introData["dastFlag"] as? Int {
//                                    dastFlag = dustFlagValue
//                                    print("dastFlag123\(dastFlag ?? 0)")
//                                   
//                                } else {
//                                    print("dustFlagValue not found or not an Int")
//                                }
//                                if let cageFlagFlagValue = introData["cageFlag"] as? Int {
//                                    cageFlag = cageFlagFlagValue
//                                    print("cageFlag123\(cageFlag ?? 0)")
//                                  
//
//                                } else {
//                                    print("cageFlag not found or not an Int")
//                                }
//                                
//                                tableView.reloadData()
//                               
//                               
//                            } else {
//                                print("Unable to cast takingControlIntroduction to [String: Any]")
//                            }
//                        }
//                    } else {
//                        print("Unable to convert data to JSON")
//                    }
//                } catch {
//                    print("Error converting data to JSON: \(error)")
//                }
//            case .failure(let error):
//                print("Error: \(error)")
//            }
//        }
        
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.questionAlertView.removeFromSuperview()
            self.questionAlertBackGroundView?.removeFromSuperview()
            self.questionAlertBackGroundView = nil
            self.navigationController?.navigationBar.layer.zPosition = 0
        }, completion: nil)
//
//        let next = UIStoryboard(name: "introductionTakingPage", bundle: nil)
//        let vc = next.instantiateViewController(withIdentifier: "introductionTakingPage") as? introductionTakingPage
//        vc?.title = "Taking control Introduction"
//        self.navigationController?.pushViewController(vc!, animated: true)
        
        
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
    func didClickOnCancelButton() {
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.infoAlertView.removeFromSuperview()
            self.infoAlertBackGroundView?.removeFromSuperview()
            self.infoAlertBackGroundView = nil
            self.navigationController?.navigationBar.layer.zPosition = 0
        }, completion: nil)
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
    
    //cell.action_button.setTitle("Doesn't apply to me", for: .normal)
    //                cell.selectionStyle = .none
    // Configure the cell as needed
    cell.action_button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
    
    
    return cell
}

        
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            var screeningID = 3
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
            var screeningID1 = 4
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
        return 100
    }
   
    
}
