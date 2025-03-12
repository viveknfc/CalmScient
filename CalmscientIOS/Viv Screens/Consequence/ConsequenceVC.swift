//
//  ConsequenceVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 04/12/24.
//

import UIKit

class ConsequenceVC: ViewController {
    
    @IBOutlet weak var Button1: CurvedOutlineButton!
    @IBOutlet weak var Button2: CurvedOutlineButton!
    @IBOutlet weak var Button3: CurvedOutlineButton!
    @IBOutlet weak var button4: CurvedOutlineButton!
    @IBOutlet weak var button5: CurvedOutlineButton!
    
    @IBOutlet weak var completButton: CapsuleButton1!
    
    var sectionID5: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func button1Pressed(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "" // Set an empty string for the back button
        self.navigationItem.backBarButtonItem = backItem
        
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "ConSub1VC") as? ConSub1VC
        vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @IBAction func button2Pressed(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "" // Set an empty string for the back button
        self.navigationItem.backBarButtonItem = backItem
        
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "ConSub2VC") as? ConSub2VC
        vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @IBAction func button3Pressed(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "" // Set an empty string for the back button
        self.navigationItem.backBarButtonItem = backItem
        
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "ConSub3VC") as? ConSub3VC
        vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func button4Pressed(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "" // Set an empty string for the back button
        self.navigationItem.backBarButtonItem = backItem
        
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "ConSub4VC") as? ConSub4VC
        vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @IBAction func button5Pressed(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "" // Set an empty string for the back button
        self.navigationItem.backBarButtonItem = backItem
        
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "ConSub5VC") as? ConSub5VC
        vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        self.view.showToastActivity()
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        updateBasicKnowledgeIndex( patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            self.view.hideToastActivity()
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            print(json)
                            
                            self.view.hideToastActivity()
                            self.navigationController?.popViewController(animated: true)
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
            "isCompleted":1,
            "sectionId": sectionID5 ?? 0
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
