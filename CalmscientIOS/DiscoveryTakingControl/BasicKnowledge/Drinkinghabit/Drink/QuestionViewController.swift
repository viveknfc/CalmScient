//
//  QuestionViewController.swift
//  CalmscientIOS
//
//  Created by mac on 07/06/24.
//

import Foundation
import UIKit

@available(iOS 16.0, *)
class QuestionViewController: ViewController, UITableViewDataSource,UITextViewDelegate, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let headers = ["1. What is your understanding of how these things are affect yourself?", "2. What is your understanding of how these things are affect people?", "3. And if you are comfortable sharing, which of these impact are you dealing with right now?"]
    let spanishHeaders = [
        "1. ¿Cuál es su comprensión de cómo estas cosas le afectan a usted mismo?",
        "2. ¿Cuál es su comprensión de cómo estas cosas afectan a las personas?",
        "3. Y si se siente cómodo compartiendo, ¿con cuál de estos impactos está lidiando en este momento?"
      ]
    let texts = ["Text for section 1", "Text for section 2", "Text for section 3"]
    //    var values = ["Anxiety, paranoia, panic","Depression","Decreased memory and problem solving ability","Sleep problems","Mood swings","Family relationships—more fighting and arguing","Health problems","Getting in trouble with the law","Accidents and injuries"]
    
    var selectedIndexPath: IndexPath?
    let data = Array(1...9).map { "Row \($0)" }
    
    var optionid7 : Int?
    var optionid5 : Int?
    var optionid6 : Int?
    var questionnaireId5 : Int?
    var answerId5 : Int?
    var questionnaireId6 : Int?
    var answerId6 : Int?
    var questionnaireId7 : Int?
    var answerId7 : Int?
    var basicData2: [[String: Any]] = []
    var options: [String] = []
    var values: [String] = []
    var optionType5: String = ""
    var optionType6: String = ""
    var sectionID66666: Int?
    var answerText4: String = ""
    var answerText5: String = ""
    var patientAnswer7 : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        // Register the custom cells
        let textNib = UINib(nibName: "HeadersCell", bundle: nil)
        tableView.register(textNib, forCellReuseIdentifier: "HeadersCell")
        
        let buttonNib = UINib(nibName: "ButtonsCell", bundle: nil)
        tableView.register(buttonNib, forCellReuseIdentifier: "ButtonsCell")
        let Nib = UINib(nibName: "SaveCell", bundle: nil)
        tableView.register(Nib, forCellReuseIdentifier: "SaveCell")
        
        
        
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
                            self.basicData2 = json["answersList"] as! [[String : Any]]
                            print("answersList:\(basicData2[4])")
                            answerText4 = basicData2[4]["answerText"] as? String ?? ""
                            questionnaireId5 = basicData2[4]["questionnaireId"] as? Int
                            
                            answerId5 = basicData2[4]["answerId"] as? Int ?? 0
                            
                            questionnaireId6 = basicData2[5]["questionnaireId"] as? Int
                            answerText5 = basicData2[5]["answerText"] as? String ?? ""
                            
                            answerId6 = basicData2[5]["answerId"] as? Int ?? 0
                            
                            questionnaireId7 = basicData2[6]["questionnaireId"] as? Int
                            
                            answerId7 = basicData2[6]["answerId"] as? Int ?? 0
                            
                            guard let options1 = basicData2[6]["options"] as? [[String: Any]] else { return }
                            self.values = options1.compactMap { $0["optionValue"] as? String }
                            print("self.options\(self.values)")
                            
                            let answer5 = basicData2[4]
                            
                            if let options = answer5["options"] as? [[String: Any]], let firstOption = options.first {
                                optionid5 = firstOption["optionId"] as? Int
                                print("Option ID: \(optionid5 ?? 0)")
                            }
                            optionType5 = answerText4
                            
                            let answer6 = basicData2[5]
                            
                            if let options = answer6["options"] as? [[String: Any]], let firstOption = options.first {
                                optionid6 = firstOption["optionId"] as? Int
                                print("Option ID: \(optionid6 ?? 0)")
                            }
                            optionType6 = answerText5
                            
                            let answer7 = basicData2[6]
                            
                            if let options7 = answer7["options"] as? [[String: Any]], let firstOption7 = options7.first {
                                optionid7 = firstOption7["optionId"] as? Int
                                print("Option ID: \(optionid7 ?? 0)")
                            }
                            if let patientAnswerValue = basicData2[6]["patientAnswer"] as? String {
                                patientAnswer7 = patientAnswerValue
                              //  optionid7 = Int(patientAnswer7)
                            } else {
                                patientAnswer7 = "0"
                            }
                            
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
        
        self.view.showToastActivity()
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        updateBasicKnowledgeIndex( patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
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
           vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
   //            vc?.courseID = 3
           self.navigationController?.pushViewController(vc!, animated: true)
           
       }
    func updateBasicKnowledgeIndex(patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void){
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/takingControl/updateBasicKnowledgeIndex") else {
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
            
            "patientId":patientId,
            "isCompleted": 1,
            "sectionId": sectionID66666!
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
    // MARK: - UITableViewDataSource
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0)
        {
            return 2
        }
        if(section == 1)
        {
            return 1
        }
        if(section == 3)
        {
            return 1
        }
        return values.count // Each section contains one row
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HeadersCell", for: indexPath) as? HeadersCell else {
                return UITableViewCell()
            }
            cell.separatorInset = .zero
            cell.headerLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? headers[indexPath.row] : spanishHeaders[indexPath.row]
            cell.textView.delegate = self
            cell.textView.tag = indexPath.row
            if cell.textView.tag == 0 {
                cell.textView.text = self.optionType5
            }
            if cell.textView.tag == 1 {
                cell.textView.text = self.optionType6
            }
            
            return cell
        }
        else if(indexPath.section == 1)
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "HeadersCell", for: indexPath) as? HeadersCell else {
                return UITableViewCell()
            }
            cell.separatorInset = .zero
            cell.headerLabel.text = "3. And if you are comfortable sharing, which of these impact are you dealing with right now?"
            //            cell.textView.delegate = self
            //            cell.textView.tag = indexPath.row
            //            cell.textView.text = optionType6
            return cell
        }
        else if(indexPath.section == 3)
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SaveCell", for: indexPath) as? SaveCell else {
                return UITableViewCell()
            }
            cell.save_btn.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
            
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonsCell", for: indexPath) as? ButtonsCell else {
                return UITableViewCell()
            }
            cell.labl_name.text = values[indexPath.row]
            cell.labl_name.textColor = UIColor(named: "424242Color")
            if indexPath == selectedIndexPath {
                cell.backgroundColor = .systemBlue
                
            } else {
                cell.labl_name.textColor = UIColor(named: "424242Color")
                cell.backgroundColor = .clear
            }
            
            return cell
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        // Update the variable when the text changes
        if textView.tag == 0 {
            optionType5 = textView.text
        }
        if textView.tag == 1{
            optionType6 = textView.text
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath.section == 0)
        {
            return 220
        }
        else if(indexPath.section == 1)
        {
            
            return 68
        }
        else if(indexPath.section == 3)
        {
            
            return 103
        }
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("hellll is selected")
        // Deselect the previously selected row
        if(indexPath.section ==  0 || indexPath.section ==  1)
        {
            
        }else if (indexPath.section ==  2)
        {
            
            guard let options1 = basicData2[6]["options"] as? [[String: Any]] else { return }
            
            // Retrieve the selected option dictionary
            let selectedOption = options1[indexPath.row]
            
            // Get the optionId
            if let optionId = selectedOption["optionId"] as? Int {
                optionid7 = optionId
                print("Selected optionId: \(optionid7 ?? 0)")
            }
            
            if let selectedIndexPath = selectedIndexPath {
                let cell = tableView.cellForRow(at: selectedIndexPath) as! ButtonsCell
                cell.main_view.backgroundColor = .clear
                cell.labl_name.textColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
            }
            
            // Select the new row
            let cell = tableView.cellForRow(at: indexPath) as! ButtonsCell
            cell.main_view.backgroundColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1)
            cell.labl_name.textColor = .white
            
            // Update the selected index path
            selectedIndexPath = indexPath
        }
        else{
        }
    }
    // MARK: - Actions
    
    @objc func saveButtonTapped(_ sender: UIButton) {
        // Handle the save button action
        optionType5 = answerText4
        optionType6 = answerText5
        if let cell = sender.superview?.superview as? SaveCell {
            let indexPath = tableView.indexPath(for: cell)
            print("Save button tapped at row)")
            
            
            guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
                fatalError("Unable to found Application Shared Info")
            }
            self.view.showToastActivity()
            if optionType5 == "nil"{
                self.view.showToast(message: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Please fill textfield one" : "Por favor complete el campo de texto uno")
                
            }
            else{
                saveBasicKnowledgeCource5(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
                    switch result {
                    case .success(let data):
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                DispatchQueue.main.async { [self] in
                                    // self.view.hideToastActivity()
                                    print("saveBasicKnowledgeCource5:\(json)")
                                    if optionType6 == "nil"{
                                        self.view.showToast(message: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Please fill textfield two" : "Por favor complete el campo de texto dos")
                                    }
                                    else {
                                        // self.view.showToastActivity()
                                        
                                        saveBasicKnowledgeCource6(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
                                            switch result {
                                            case .success(let data):
                                                do {
                                                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                                        DispatchQueue.main.async { [self] in
                                                            //   self.view.hideToastActivity()
                                                            print("saveBasicKnowledgeCource6:\(json)")
                                                            if optionid7 == nil{
                                                                self.view.showToast(message:  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Please select one option" : "Por favor seleccione una opción")
                                                               
                                                            }
                                                            else{
                                                                //   self.view.showToastActivity()
                                                                
                                                                saveBasicKnowledgeCource7(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
                                                                    switch result {
                                                                    case .success(let data):
                                                                        do {
                                                                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                                                                DispatchQueue.main.async { [self] in
                                                                                    self.view.hideToastActivity()
                                                                                    print("saveBasicKnowledgeCource7:\(json)")
                                                                                    let vc1 = UIStoryboard(name: "Basicknowledge", bundle: nil).instantiateViewController(withIdentifier: "Basicknowledge") as! Basicknowledge
                                                                                    self.navigationController?.pushViewController(vc1, animated: true)
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
    }
    
    @IBAction func backward_action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }
    func saveBasicKnowledgeCource5(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
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
            "answerId": answerId5!,
            "plId": plId,
            "patientId": patientId,
            "clientId": clientId,
            "optionId": optionid5!,
            "optionValue": optionType5,
            "assessmentId": 0,
            "quantity": 0,
            "questionnaireId" : questionnaireId5!
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
    func saveBasicKnowledgeCource6(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
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
            "answerId": answerId6!,
            "plId": plId,
            "patientId": patientId,
            "clientId": clientId,
            "optionId": optionid6!,
            "optionValue": optionType6,
            "assessmentId": 0,
            "quantity": 0,
            "questionnaireId" : questionnaireId6!
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
    func saveBasicKnowledgeCource7(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
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
            "answerId": answerId7!,
            "plId": plId,
            "patientId": patientId,
            "clientId": clientId,
            "optionId": optionid7!,
            "optionValue": "",
            "assessmentId": 0,
            "quantity": 0,
            "questionnaireId" : questionnaireId7!
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
            "courseId":3,
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
}
