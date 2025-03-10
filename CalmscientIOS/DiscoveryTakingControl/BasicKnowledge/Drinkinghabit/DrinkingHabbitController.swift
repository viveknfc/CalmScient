//
//  DrinkingHabbitController.swift
//  CalmscientIOS
//
//  Created by mac on 06/06/24.
//

import Foundation
import UIKit

@available(iOS 16.0, *)
class DrinkingHabbitController:  ViewController {
    
    @IBOutlet var None_button: UIButton!
    @IBOutlet var lessthan2_button: UIButton!
    @IBOutlet var threetofive_button: UIButton!
    @IBOutlet var almost_button: UIButton!
    @IBOutlet var evryday_button: UIButton!
    var sectionID6: Int?
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var questionLabel: UILabel!
    var answersList: [[String: Any]] = []
    var optionid : Int?
    var questionnaireId : Int?
    var answerId : Int?
    
    var patientAnswer : String = ""
    
    //var options: [String] = ["None", "Less than 2 days", "3-5 days", "Almost everyday", "Everyday"]
    var options: [String] = []
    var optionids: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title =  AppHelper.getLocalizeString(str: "Basic Knowledge")
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
            
        }
        
        self.view.showToastActivity()
        getBasicKnowledgeQuestions(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            self.view.hideToastActivity()
                            self.answersList = json["answersList"] as! [[String : Any]]
                            print("answersList:\(answersList[0])")
                            questionnaireId = answersList[0]["questionnaireId"] as? Int
                            
                            
                            answerId = answersList[0]["answerId"] as? Int ?? 0
                            
                            
                            if let patientAnswerValue = answersList[0]["patientAnswer"] as? String {
                                patientAnswer = patientAnswerValue
                                optionid = Int(patientAnswer)
                            } else {
                                patientAnswer = "0"
                            }
                            print("patientAnswerrrrrr \(String(describing: patientAnswer))")
                            
                            guard let options2 = answersList[0]["options"] as? [[String: Any]] else { return }
                            self.optionids = options2.compactMap { $0["optionId"] as? String }
                            
                            
                            
                            guard let options1 = answersList[0]["options"] as? [[String: Any]] else { return }
                            self.options = options1.compactMap { $0["optionValue"] as? String }
                            
                            
                            
                            
                            setupQuestionnaire()
                            
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
        
        //end
    }
    @objc func backButtonOverrideAction() {
           print("Back button tapped")
           // Perform the action you want here
           let next = UIStoryboard(name: "Basicknowledge", bundle: nil)
           let vc = next.instantiateViewController(withIdentifier: "Basicknowledge") as? Basicknowledge
           vc?.title =  AppHelper.getLocalizeString(str: "Basic Knowledge")
   //            vc?.courseID = 3
           self.navigationController?.pushViewController(vc!, animated: true)
           
       }
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
    }
    
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
                
                
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
                
               
            }
        self.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        
        headerLabel.text = AppHelper.getLocalizeString(str: "How many days a week do you drink?")
        questionLabel.text = AppHelper.getLocalizeString(str: "1. Now let’s see what drinking habits do you have")
        None_button.titleLabel?.text = AppHelper.getLocalizeString(str:"None" )
        lessthan2_button.titleLabel?.text = AppHelper.getLocalizeString(str:"Less than 2 days" )
        threetofive_button.titleLabel?.text = AppHelper.getLocalizeString(str:"3-5 days")
        almost_button.titleLabel?.text = AppHelper.getLocalizeString(str:"Almost everyday")
        evryday_button.titleLabel?.text = AppHelper.getLocalizeString(str:"Everyday")
        
        }
    func setupQuestionnaire() {
        // Create the main vertical stack view
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        mainStackView.distribution = .equalSpacing
        mainStackView.spacing = 16
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the question label
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Now let's see what drinking habits do you have"
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
        mainStackView.addArrangedSubview(descriptionLabel)
        
        let questionLabel = UILabel()
        questionLabel.text = "1. How many days a week do you drink?"
        questionLabel.textAlignment = .center
        questionLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        questionLabel.numberOfLines = 0
        mainStackView.addArrangedSubview(questionLabel)
        
        // Add the description label
       
        
        // Create the button stack views
        guard let options = answersList.first?["options"] as? [[String: Any]] else { return }
        
        
        view.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        let buttonStackView1 = createButtonStackView(options: Array(options.prefix(2)))
        let buttonStackView2 = createButtonStackView(options: Array(options[2...3]))
        let buttonStackView3 = createButtonStackView(options: Array(options.suffix(1)))
        
        mainStackView.addArrangedSubview(buttonStackView1)
        mainStackView.addArrangedSubview(buttonStackView2)
        mainStackView.addArrangedSubview(buttonStackView3)
        
        // Set constraints for the main stack view
        NSLayoutConstraint.activate([
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    @IBAction func forward_action(_ sender: UIButton) {
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
            
        }
        if optionid == nil
        {
            
        }
        else{
            self.view.showToastActivity()
            saveBasicKnowledgeCource(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
                switch result {
                case .success(let data):
                    // Convert data to JSON object and print it
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            DispatchQueue.main.async { [self] in
                                self.view.hideToastActivity()
                                print(json)
                                let next = UIStoryboard(name: "DrinikingHabbit", bundle: nil)
                                let vc = next.instantiateViewController(withIdentifier: "DrinikingHabbit") as? DrinikingHabbit
                                vc?.sectionID66 = sectionID6
                                vc?.title = "Basic Knowledge"
                                // vc?.basicData = answersList
                                self.navigationController?.pushViewController(vc!, animated: true)
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
        
    }
    @IBAction func backward_action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func createButtonStackView(options: [[String: Any]]) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        for option in options {
            if let title = option["optionValue"] as? String, let optionId = option["optionId"] as? Int {
                let button = createButton(title: title, optionId: optionId)
                stackView.addArrangedSubview(button)
            }
        }
        
        return stackView
    }
    
    func createButton(title: String, optionId: Int) -> UIButton {
        
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(UIColor(named: "One424242Color"), for: .normal)
        if optionId == Int(patientAnswer)!  {
            button.backgroundColor = UIColor(named: "6E6BB3ColorOnly")
            button.setTitleColor(UIColor.white, for: .normal)
        } else {
            button.backgroundColor = .white
        }
        
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hex: "#F2F2F2").cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tag = optionId
        button.addTarget(self, action: #selector(didClickOnAnswer(_:)), for: .touchUpInside)
        
        
//        button.layer.shadowColor = UIColor.black.cgColor
//        button.layer.shadowOpacity = 0.1
//        button.layer.shadowOffset = CGSize(width: 0, height: 2)
//        button.layer.shadowRadius = 4
//        button.layer.masksToBounds = false
       // backGroundView.layer.borderWidth = 1
       // backGroundView.layer.borderColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1).cgColor
               
               // Adding a shadow path for better performance
        button.applyShadow()
       // button.layer.shadowPath = UIBezierPath(roundedRect: button.bounds, cornerRadius: button.layer.cornerRadius).cgPath
        
        NSLayoutConstraint.activate([
               button.heightAnchor.constraint(equalToConstant: 40) // Set the height you want here
           ])
        return button
    }
    
    @objc func didClickOnAnswer(_ sender: UIButton) {
        resetAllButtons()
        sender.setTitleColor(UIColor.white, for: .normal)
        sender.backgroundColor = UIColor(named: "6E6BB3ColorOnly")
        
        optionid = sender.tag
        print("Clicked optionId: \(optionid ?? 0)")
    }
    
    func resetAllButtons() {
        resetButtons(in: view)
    }
    
    private func resetButtons(in view: UIView) {
        for subview in view.subviews {
            if let button = subview as? UIButton {
                button.setTitleColor(UIColor(named: "One424242Color"), for: .normal)
                button.backgroundColor = .white
            } else {
                resetButtons(in: subview)
            }
        }
    }
    
    func imageFromColor(color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image?.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .stretch)
    }
    func getBasicKnowledgeQuestions(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/takingControl/getPatientBasicKnowledgeCourse") else {
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
            "plId": plId,
            "patientId": patientId,
            "clientId": clientId,
            "assessmentId": 1
        ]
        print(payload)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            //    print(jsonData)
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
                // print("Response JSON: \(jsonResponse)")
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
    func saveBasicKnowledgeCource(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/takingControl/saveBasicKnowledgeCourse") else {
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
            "answerId": answerId!,
            "plId": plId,
            "patientId": patientId,
            "clientId": clientId,
            "optionId": optionid!,
            "assessmentId": 0,
            "quantity": 0,
            "questionnaireId" : questionnaireId!,
            "optionValue":"",
        ]
        print(payload)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            //    print(jsonData)
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
                // print("Response JSON: \(jsonResponse)")
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
}
