//
//  Bsicknowledge.swift
//  CalmscientIOS
//
//  Created by mac on 01/06/24.
//

import Foundation
import Foundation
import UIKit
@available(iOS 16.0, *)
class Basicknowledge: ViewController, UITableViewDelegate, UITableViewDataSource {

        @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var completeButton: CapsuleButton1!

    var data: [String] = []
    var basicData2: [[String: Any]] = []
        
    var checkedStates: [Bool] = []

        override func viewDidLoad() {
            super.viewDidLoad()
            checkedStates = Array(repeating: false, count: data.count)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            tableView.register(UINib(nibName: "CustomCheckboxCell", bundle: nil), forCellReuseIdentifier: "CustomCheckboxCell")
            tableView.estimatedRowHeight = 104.0
            tableView.rowHeight = UITableView.automaticDimension
            
            
            guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
                fatalError("Unable to found Application Shared Info")
                
            }
            
            getBasicKnowledgeQuestions(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
                switch result {
                case .success(let data):
                    // Convert data to JSON object and print it
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            print(json)
                            DispatchQueue.main.async { [self] in
//                                self.view.hideToastActivity()
                                self.basicData2 = json["index"] as! [[String : Any]]
                                print("index:\(basicData2)")
                                
                                tableView.reloadData()
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

    override func viewWillAppear(_ animated: Bool) {
        self.view.showToastActivity()
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
            
        }
        getBasicKnowledgeQuestions(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            
                            self.basicData2 = json["index"] as! [[String : Any]]
                            print("index:\(basicData2)")
                            
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
    }
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return basicData2.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCheckboxCell", for: indexPath) as! CustomCheckboxCell
            let newData = basicData2[indexPath.row]
            cell.customLabel.text = newData["sectionName"] as? String
         
            if let isCompleted = newData["isCompleted"] as? Int {
                cell.checkBox.isHidden = isCompleted != 1 // Hide if not completed
            } else {
                cell.checkBox.isHidden = true // Hide if `isCompleted` is not found or not an Int
            }

           cell.separatorInset = .zero
         
            return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let next = UIStoryboard(name: "BasicStandardDrink", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "BasicStandardDrink") as? BasicStandardDrink
            let newData = basicData2[indexPath.row]
            vc?.sectionID1 = newData["sectionId"] as? Int
            vc?.title =  AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }else if(indexPath.row == 1){
            
            //start
            
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "USGuideLineForDrinkingVC") as? USGuideLineForDrinkingVC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
            
            //end
            
            
//            let next = UIStoryboard(name: "USGuidlines", bundle: nil)
//            let vc = next.instantiateViewController(withIdentifier: "USGuidlines") as? USGuidlines
//            vc?.title =  AppHelper.getLocalizeString(str: "Basic Knowledge")
//            let newData = basicData2[indexPath.row]
//            vc?.sectionID2 = newData["sectionId"] as? Int
//            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if(indexPath.row == 2){
            let next = UIStoryboard(name: "Moderation", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "Moderation") as? Moderation
            vc?.title =  AppHelper.getLocalizeString(str: "Basic Knowledge")
            let newData = basicData2[indexPath.row]
            vc?.sectionID3 = newData["sectionId"] as? Int
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if(indexPath.row == 3){
            let next = UIStoryboard(name: "BasicknowledgeVideo", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "BasicknowledgeVideo") as? BasicknowledgeVideo
            let newData = basicData2[indexPath.row]
            vc?.sectionID4 = newData["sectionId"] as? Int
            vc?.title =  AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if(indexPath.row == 4){
            
            //start
            
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "ConsequenceVC") as? ConsequenceVC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
            
            //end

        }
        else if(indexPath.row == 5){
            
            //start
            
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "HoldYourLiquorVC") as? HoldYourLiquorVC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
            
            //end
            
//            let next = UIStoryboard(name: "DrinkingHabbitController", bundle: nil)
//            let vc = next.instantiateViewController(withIdentifier: "DrinkingHabbitController") as? DrinkingHabbitController
//            let newData = basicData2[indexPath.row]
//            vc?.sectionID6 = newData["sectionId"] as? Int
//            vc?.title =  AppHelper.getLocalizeString(str: "Basic Knowledge")
//            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if(indexPath.row == 6){
            
            //start
            
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "MyDrinkingHabitVC") as? MyDrinkingHabitVC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
            
            //end
            
//            let next = UIStoryboard(name: "WhatToExpectViewController", bundle: nil)
//            let vc = next.instantiateViewController(withIdentifier: "WhatToExpectViewController") as? WhatToExpectViewController
//            vc?.title =  AppHelper.getLocalizeString(str: "Basic Knowledge")
//            let newData = basicData2[indexPath.row]
//            vc?.sectionID7 = newData["sectionId"] as? Int
//            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }

    func getBasicKnowledgeQuestions(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/takingControl/getBasicKnowledgeIndex") else {
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
    
    //MARK: - Complete Button Pressed
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
