//
//  FeelDrinkingHabbit.swift
//  CalmscientIOS
//
//  Created by mac on 06/06/24.
//

import Foundation
import UIKit

@available(iOS 16.0, *)
class FeelDrinkingHabbit:  ViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headlbl: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    var sectionID666: Int?
    var optionid2 : Int?
    var questionnaireId2 : Int?
    var answerId2 : Int?
    var patientAnswer : String?
    var basicData2: [[String: Any]] = []
    var options: [String] = []
    var optionsIds: [Int] = []
    let data = [
        "What’s a “standard drink”?",
        "What are the U.S. guidelines for drink?",
        "When is drink in moderation too much ?",
        "What happens to your brain when you drink?",
        "What are the consequences?",
        "My drinking habit",
        "What to expect when you quit drinking?"
    ]
    
    var checkedStates: [Bool] = []
    var previouslySelectedTextView: UITextView?
    var previouslySelectedBackgroundView : UIView?
    var defaultSelectedTextView: UITextView?
    var defaultSelectedBackgroundView: UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        //        print(basicData2[2])
        //        questionnaireId2 = basicData2[2]["questionnaireId"] as? Int
        //        answerId2 = basicData2[1]["answerId"] as? Int ?? 0
        //         print("Answer ID: \(answerId2 ?? 0)")
        //        print("questionnaireId ID: \(questionnaireId2 ?? 0)")
        
        
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
                            //print("answersList:\(basicData2)")
                            print("basicData2:\(basicData2[2])")
                            
                            if let patientAnswerValue = basicData2[2]["patientAnswer"] as? String {
                                patientAnswer = patientAnswerValue
                            } 
//                            else {
//                                patientAnswer = "0"
//                            }
                            print("patientAnswerrrrrr \(String(describing: patientAnswer))")
                            if let patientAns = patientAnswer{
                                optionid2 = Int(patientAns)
                            }
                            
                            questionnaireId2 = basicData2[2]["questionnaireId"] as? Int
                            
                            answerId2 = basicData2[2]["answerId"] as? Int ?? 0
                            print("Answer ID: \(answerId2 ?? 0)")
                           
//
                            guard let options1 = basicData2[2]["options"] as? [[String: Any]] else { return }
                            self.options = options1.compactMap { $0["optionValue"] as? String }
                            self.optionsIds = options1.compactMap { $0["optionId"] as? Int }
                            print("self.options\(self.options)")
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
        
        
        
        tableView.register(UINib(nibName: "FeelDrink", bundle: nil), forCellReuseIdentifier: "FeelDrink")
        configureLabel1(headlbl, withText: "What do you feel about your drinking habit?")
        tableView.rowHeight = UITableView.automaticDimension
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
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
        headlbl.text = AppHelper.getLocalizeString(str: "3. What do you feel about your drinking habit?")
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
    func configureLabel1(_ label: UILabel, withText text: String) {
        let bulletPoint = "3. \(text)"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 10
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.lineSpacing = 4
        
        let attributedString = NSAttributedString(string: bulletPoint, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        label.attributedText = attributedString
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeelDrink", for: indexPath) as! FeelDrink
        cell.separatorInset = .zero
        
        let optionValue = self.options[indexPath.row]
        let optionIDS = self.optionsIds[indexPath.row]
        configureTextView(cell.drinkTextView, withHTML: optionValue)
        
//        if optionIDS == Int(patientAnswer) {
//            // Set the default selected cell
//            cell.drinkTextView.backgroundColor = UIColor(named: "barColor1") ?? UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
//            cell.drinkTextView.textColor = UIColor.white
//            cell.newBackGroundView.backgroundColor = UIColor(named: "barColor1") ?? UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
//            
//            // Store references to the default selected views
//            defaultSelectedTextView = cell.drinkTextView
//            defaultSelectedBackgroundView = cell.newBackGroundView
//        } else 
        if optionIDS == optionid2 {
            // Highlight the cell that was selected by the user
            cell.drinkTextView.backgroundColor = UIColor(named: "barColor1") ?? UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
            cell.drinkTextView.textColor = UIColor.white
            cell.newBackGroundView.backgroundColor = UIColor(named: "barColor1") ?? UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
        } else {
            // Reset the appearance for non-selected cells
            cell.drinkTextView.backgroundColor = UIColor.clear
            cell.drinkTextView.textColor = UIColor(named: "424242Color")
            cell.newBackGroundView.backgroundColor = UIColor.clear
        }

        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(drinkTextViewTapped(_:)))
        cell.drinkTextView.addGestureRecognizer(tapGesture)
        cell.drinkTextView.isUserInteractionEnabled = true
        cell.drinkTextView.tag = indexPath.row
        cell.newBackGroundView.tag = indexPath.row
        
        let backgroundViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(drinkTextViewTapped(_:)))
        cell.newBackGroundView.addGestureRecognizer(backgroundViewTapGesture)
        cell.newBackGroundView.isUserInteractionEnabled = true
        cell.newBackGroundView.tag = indexPath.row
        
        return cell
    }

    @objc func drinkTextViewTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else { return }
        let indexPathRow = tappedView.tag

        guard let cell = tableView.cellForRow(at: IndexPath(row: indexPathRow, section: 0)) as? FeelDrink else { return }

        guard let options1 = basicData2[2]["options"] as? [[String: Any]] else { return }

        let selectedOption = options1[indexPathRow]

        if let optionId = selectedOption["optionId"] as? Int {
            optionid2 = optionId
            print("Selected optionId: \(optionid2 ?? 0)")

            // Reset previously selected views
            if let previousTextView = previouslySelectedTextView {
                previousTextView.backgroundColor = UIColor.white
                previousTextView.textColor = UIColor.black
            }
            if let previousBackgroundView = previouslySelectedBackgroundView {
                previousBackgroundView.backgroundColor = UIColor.white
            }

            // Reset the default selected cell if it's not the one being selected
            if let patientAns = patientAnswer{
                if optionId != Int(patientAns) {
                    defaultSelectedTextView?.backgroundColor = UIColor.clear
                    defaultSelectedTextView?.textColor = UIColor.black
                    defaultSelectedBackgroundView?.backgroundColor = UIColor.clear
                }
            }
            

            // Apply selection changes
            cell.drinkTextView.backgroundColor = UIColor(named: "barColor1")
            cell.drinkTextView.textColor = UIColor.white
            cell.newBackGroundView.backgroundColor = UIColor(named: "barColor1")

            // Store references to the current views
            previouslySelectedTextView = cell.drinkTextView
            previouslySelectedBackgroundView = cell.newBackGroundView
            tableView.reloadData()
        }
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 350
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle cell selection
        guard let options1 = basicData2[2]["options"] as? [[String: Any]] else { return }
        
        // Retrieve the selected option dictionary
        let selectedOption = options1[indexPath.row]
        
        // Get the optionId
        if let optionId = selectedOption["optionId"] as? Int {
            optionid2 = optionId
            print("Selected optionId: \(optionid2 ?? 0)")
        }
    }
    
    func parseOptionValue(_ optionValue: String) -> (main: NSAttributedString, part1: String, part2: String, part3: String) {
        // Strip HTML tags and split the text into parts
        let strippedValue = optionValue.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        let components = strippedValue.components(separatedBy: "<br>").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        // Assume the format is known and fixed
        let mainPart = components.first ?? ""
        let part1 = components.count > 1 ? components[1] : ""
        let part2 = components.count > 2 ? components[2] : ""
        let part3 = components.count > 3 ? components[3] : ""
        
        // Create an attributed string for the main part
        let attributedMain = NSMutableAttributedString(string: mainPart)
        if let range = mainPart.range(of: "Aware of problem but not ready to change ") {
            let nsRange = NSRange(range, in: mainPart)
            attributedMain.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: nsRange)
        }
        
        return (attributedMain, part1, part2, part3)
    }
    
    func configureLabel(_ label: UILabel, withText text: String) {
        let bulletPoint = "\(text)"
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 10
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.lineSpacing = 4
        
        let attributedString = NSAttributedString(string: bulletPoint, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        label.attributedText = attributedString
    }
    @IBAction func forward_action(_ sender: UIButton) {
        if optionid2 == nil{
            self.view.showToast(message: "Please select any option")
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
                                vc?.basicData3 = basicData2
                                vc?.title =  AppHelper.getLocalizeString(str: "Basic Knowledge")
                                vc?.sectionID6666 = sectionID666
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
            "answerId": answerId2!,
            "plId": plId,
            "patientId": patientId,
            "clientId": clientId,
            "optionId": optionid2!,
            "optionValue": "",
            "assessmentId": 0,
            "quantity": 0,
            "questionnaireId" : questionnaireId2!
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
    func configureTextView(_ textView: UITextView, withHTML html: String) {
        let font = UIFont.systemFont(ofSize: 16)
        let textColor = UIColor(named: "AppointmentsTextColor") ?? UIColor.black
        
        if let attributedString = NSAttributedString(html: html, font: font) {
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
            mutableAttributedString.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: mutableAttributedString.length))
            
            textView.attributedText = mutableAttributedString
            textView.isEditable = false
            textView.isScrollEnabled = false
            textView.textContainerInset = .zero
            textView.textContainer.lineFragmentPadding = 0
        }
    }

}

extension NSAttributedString {
    convenience init?(html: String, font: UIFont) {
        let modifiedHtml = """
        <style>
        body { font-family: \(font.fontName); font-size: \(font.pointSize)px; color: #000000; }
        b { font-family: \(font.fontName); font-size: \(font.pointSize)px; font-weight: bold; }
        </style>
        \(html.replacingOccurrences(of: "<br>", with: "<br/><br/>"))
        """
        guard let data = modifiedHtml.data(using: .utf8) else { return nil }
        try? self.init(data: data,
                       options: [.documentType: NSAttributedString.DocumentType.html,
                                 .characterEncoding: String.Encoding.utf8.rawValue],
                       documentAttributes: nil)
    }
}



