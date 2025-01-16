//
//  introductionTakingPage.swift
//  CalmscientIOS
//
//  Created by mac on 28/05/24.
//

import Foundation
import UIKit
@available(iOS 16.0, *)
class IntroductionPageController: ViewController {
    
    var tutorialFlag : Int?
    var tutorialFlag11 : Int?
    
    var auditFlag : Int?
    var dastFlag : Int?
    var cageFlag : Int?
    @IBOutlet weak var drinkcoach: UIButton!
    @IBOutlet weak var checkbox: UIButton!
    @IBOutlet weak var substainCoach: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var checkBoxLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        checkBoxLabel.text = AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Do_Not_Show_Checkbox_text")
        drinkcoach.setTitle(AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Drink_Coach"), for: .normal)
        substainCoach.setTitle(AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Substance_Coach"), for: .normal)
        messageLabel.text = AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Intro_Message")
    }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            // Set the initial state of the checkbox
           
            setupCustomButton()
            
            
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
                                    if let tutorialFlagValue = introData["tutorialFlag"] as? Int {
                                        tutorialFlag = tutorialFlagValue
                                        print("tutorialFlag\(tutorialFlag ?? 0)")
                                        updateCheckboxAppearance()

                                       
                                    } else {
                                        print("tutorialFlag not found or not an Int")
                                    }
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
    @IBAction func back_action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
//        @IBAction func didTapCheckbox(_ sender: UIButton) {
//            isChecked.toggle()
//        }
    
    
    
//    func updateCheckboxAppearance(tutorialFlag1 : Int) {
//    if tutorialFlag == tutorialFlag1{
//        checkbox.setImage(UIImage(named: "checkbox"), for: .normal)
//    }
//    else if tutorialFlag == tutorialFlag1{
//        checkbox.setImage(UIImage(named: "uncheck"), for: .normal)
//    }
//           let imageName = (tutorialFlag == 0) ? "uncheck" : "checkbox"
//             checkbox.setImage(UIImage(named: imageName), for: .normal)
//    }
    
    func updateCheckboxAppearance() {
        let imageName = (tutorialFlag == 1) ? "checkbox" : "uncheck_img"
        checkbox.setImage(UIImage(named: imageName), for: .normal)
    }
    
    
    
    func setupCustomButton() {
        drinkcoach.heightAnchor.constraint(equalToConstant: 65).isActive = true


        drinkcoach.applyShadow()
        drinkcoach.layer.borderWidth = 0.5
        drinkcoach.layer.borderColor = UIColor.lightGray.cgColor
        drinkcoach.layer.masksToBounds = false
        
        substainCoach.heightAnchor.constraint(equalToConstant: 65).isActive = true
        substainCoach.applyShadow()
        substainCoach.layer.borderWidth = 0.5
        substainCoach.layer.borderColor = UIColor.lightGray.cgColor
        substainCoach.layer.cornerRadius = 10.0
        }
    @IBAction func checkTapped(_ sender: UIButton) {
        
        if tutorialFlag == 1 {
            tutorialFlag = 0
        } else {
            tutorialFlag = 1
        }
        
        // Update the checkbox appearance based on the new value of tutorialFlag
        updateCheckboxAppearance()
        
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
            
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
    }
    @available(iOS 16.0, *)
    @IBAction func drinkCoachTapped(_ sender: UIButton) {
        let next = UIStoryboard(name: "Discovery", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "Discovery") as? Discovery
        vc?.title = "Taking Control"
//            vc?.courseID = 3
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func infoTapped(_ sender: UIButton) {
        let next = UIStoryboard(name: "VideoController", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "VideoController") as? VideoController
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
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
            "auditFlag": auditFlag as Any,
            "dastFlag": dastFlag as Any,
            "cageFlag": cageFlag as Any,
            "tutorialFlag": tutorialFlag as Any
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
    
}
