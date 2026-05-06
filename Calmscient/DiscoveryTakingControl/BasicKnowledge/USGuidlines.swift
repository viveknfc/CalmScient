//
//  USGuidlines.swift
//  CalmscientIOS
//
//  Created by mac on 02/06/24.
//

import Foundation
import UIKit

class USGuidlines: ViewController {

    @IBOutlet weak var headerLabel: UILabel!
  
    @IBOutlet weak var usguideTextView: UITextView!
    var sectionID2: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextView()
        title = "Basic knowledge"
        self.view.showToastActivity()
        usguideTextView.font = UIFont(name: Fonts().lexendLight, size: 16)
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
        headerLabel.text = AppHelper.getLocalizeString(str: "What are the U.S. guidelines for drinking?")
    //    setupTextView()
        
        }
    private func setupTextView() {
        let fullText = AppHelper.getLocalizeString(str: "US guidelines part1") + "\n\n" + AppHelper.getLocalizeString(str: "US guidelines part2")
        
        let attributedString = NSMutableAttributedString(string: fullText)
        
        // Define attributes
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor(named: "AppointmentsTextColor") as Any
        ]
        
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor(named: "AppointmentsTextColor") as Any,
            .paragraphStyle: paragraphStyle
        ]
        
        let redAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(named: "barColor1") as Any
        ]
        
        // Apply attributes to specific parts of the text
        let firstPartRange = (fullText as NSString).range(of: AppHelper.getLocalizeString(str: "US guidelines part1"))
        attributedString.addAttributes(normalAttributes, range: firstPartRange)
        
        let secondPartRange = (fullText as NSString).range(of: AppHelper.getLocalizeString(str: "US guidelines part2"))
        attributedString.addAttributes(normalAttributes, range: secondPartRange)
        
        // Define target strings for both English and Spanish
        let targetStrings = [
            "2 drinks or less in a day",
            "1 drink or less in a day",
            "2 bebidas o menos al día",
            "1 bebida o menos al día"
        ]
        
        // Apply red color to the target strings if they exist
        for target in targetStrings {
            let range = (fullText as NSString).range(of: target)
            if range.location != NSNotFound {
                attributedString.addAttributes(redAttributes, range: range)
            }
        }
        
        usguideTextView.attributedText = attributedString
        usguideTextView.isEditable = false
        usguideTextView.isScrollEnabled = false
    }

    func updateBasicKnowledgeIndex(patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void){
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
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
            "isCompleted":1,
            "sectionId":sectionID2!
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

