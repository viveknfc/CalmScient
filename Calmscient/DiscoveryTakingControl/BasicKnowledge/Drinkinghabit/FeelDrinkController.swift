//
//  DrinikingHabbit.swift
//  CalmscientIOS
//
//  Created by mac on 06/06/24.
//

import Foundation
import Foundation
import UIKit
@available(iOS 16.0, *)
class FeelDrinkController: ViewController{
    
    @IBOutlet weak var enter_text: UITextView!
    @IBOutlet weak var yesButton: UIButton!
    var optionid3 : Int?
    var questionnaireId3 : Int?
    var answerId3 : Int?
    var basicData3: [[String: Any]] = []
    var options3: [String] = []
    var optionType: String = ""
   
    var checkedStates: [Bool] = []
    var answersList: [[String: Any]] = []
    var optionid : Int?
    var questionnaireId : Int?
    var answerId : Int?
    var answerText : String = ""
    var sectionID6666: Int?
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    
    @IBOutlet weak var normalTextLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enter_text.layer.cornerRadius = 5
        enter_text.layer.borderWidth = 1
        enter_text.layer.borderColor = UIColor(named: "clearAndWhite")?.cgColor
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
                            print("answersList:\(answersList[3])")
                            questionnaireId = answersList[3]["questionnaireId"] as? Int
                            
                             answerId = answersList[3]["answerId"] as? Int ?? 0
                            print("Answer ID: \(answerId ?? 0)")
                            answerText = answersList[3]["answerText"] as? String ?? ""
                            enter_text.text = answerText
                            
                            let answer = answersList[3]
                            if let options = answer["options"] as? [[String: Any]], let firstOption = options.first {
                                optionid = firstOption["optionId"] as? Int
                                            print("Option ID: \(optionid ?? 0)")
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
        
        headerLabel.text = AppHelper.getLocalizeString(str: "Now let’s see what drinking habits do you have")
        questionLabel.text = AppHelper.getLocalizeString(str: "4. What is the reason behind?")
        normalTextLabel.text = AppHelper.getLocalizeString(str:"Save it to weekly summary journal entry")
        yesButton.setTitle(AppHelper.getLocalizeString(str: "Yes"), for: .normal)
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
    @IBAction func yesButtonAction(_ sender: Any) {
        
         optionType =  enter_text.text
        
        if optionType == ""{
            self.view.showToast(message: "Please fill the text field")
        }
        else {
            guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
                fatalError("Unable to found Application Shared Info")
            }
        self.view.showToastActivity()
        saveBasicKnowledgeCource(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            self.view.hideToastActivity()
                            print("FeelDrinkControllerjson:\(json)")
                            
                            let next = UIStoryboard(name: "FeelDrinkController", bundle: nil)
                            let vc = next.instantiateViewController(withIdentifier: "FeelDrinkController") as? FeelDrinkController
                           // self.navigationController?.pushViewController(vc!, animated: true)
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
//        guard let options1 = basicData3[3]["options"] as? [[String: Any]] else { return }
//        if let optionTypeValue = options1.first?["optionValue"] as? String {
//            optionType = optionTypeValue
//            print("Assigned optionType: \(optionType)")
//            enter_text.text = optionType
//        } else {
//            print("optionType not found")
//        }
    }
    
    
    @IBAction func forward_action(_ sender: UIButton) {
        optionType =  enter_text.text
        if optionType == ""{
            self.view.showToast(message: "Please fill the text field")
        }
        else {
            let next = UIStoryboard(name: "QuestionViewController", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController
            vc?.title =  AppHelper.getLocalizeString(str: "Basic Knowledge")
            vc?.sectionID66666 = sectionID6666
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    @IBAction func backward_action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
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
            "optionValue": optionType,
            "questionnaireId" : questionnaireId!
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
