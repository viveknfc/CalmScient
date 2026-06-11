//
//  EventsTrackersViewController.swift
//  CalmscientIOS
//
//  Created by NFC Solutions on 6/17/24.
//

import UIKit

class EventsTrackersViewController: UIViewController {

    @IBOutlet weak var saveButton: LinearGradientButton!
    @IBOutlet weak var dateText: UILabel!
    @IBOutlet weak var eventTrackerTableView: UITableView!
    @IBOutlet weak var dateLabel: UIView!
    var events: [[String: Any]] = []
    var eventsUpdate: [[String: Any]] = []
    var saveButtonEnabled: Bool = false {
        didSet {
            saveButton.isHidden = saveButtonEnabled
           // saveButton.alpha = saveButtonEnabled ? 1.0 : 0.5 // Optional: Visual feedback for disabled state
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        eventTrackerTableView.register(UINib(nibName: "EventsTrackersTableViewCell", bundle: nil), forCellReuseIdentifier: "EventsTrackersTableViewCell")
        
        self.title = "Events tracker"
        
        eventTrackerTableView.dataSource = self
        eventTrackerTableView.delegate = self
        eventTrackerTableView.reloadData()
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        self.saveButtonEnabled = true
        
        getAlcoholEvents(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            print(json)
                            var newDate = json["date"] as? String
                            newDate = self.getCurrentDateString()
                            self.dateText.text = newDate
                            self.events = json["evevntsList"] as! [[String : Any]]
                            print("Data received: \(self.events)")
                            self.eventTrackerTableView.reloadData()
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
        
    }
    func getCurrentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: Date())
    }
    func postUpdatesEvents(eventsData: [[String: Any]], bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
        
        guard let url = URL(string: "\(baseURLString)patients/api/v1/alcohol/createEventTracking") else {
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
            "alcohol": eventsUpdate
        ]
        print("payload\(payload)")
        // Convert the payload to JSON data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            //  print(jsonData)
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
            
            // If needed, handle the response here
            completion(.success(data))
        }
        
        // Start the data task
        task.resume()
    }
    @IBAction func saveButtonAction(_ sender: Any) {
        print(eventsUpdate)
        self.view.showToastActivity()
        postUpdatesEvents(eventsData: eventsUpdate, bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
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
    
    func getAlcoholEvents(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
        
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/alcohol/getEventsList") else {
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
            "activityDate": activityDate
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
            
            // If needed, handle the response here
            completion(.success(data))
        }
        
        // Start the data task
        task.resume()
    }
   
    func addOrUpdateEventsData(eventId: Int, eventFlag: Int, flag: String) {
        let currentDate = getCurrentDateString()
        
        if let index = eventsUpdate.firstIndex(where: { $0["eventId"] as? Int == eventId }) {
            eventsUpdate[index]["eventFlag"] = eventFlag
            eventsUpdate[index]["flag"] = flag
            eventsUpdate[index]["activityDate"] = currentDate
            
        } else {
            guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
                fatalError("Unable to found Application Shared Info")
            }
            
            let newEntry: [String: Any] = [
                "flag": flag,
                "plId": userInfo.patientLocationID,
                "patientId": userInfo.patientID,
                "clientId": userInfo.clientID,
                "eventFlag": eventFlag,
                "eventId": eventId,
                "activityDate": currentDate            ]
            eventsUpdate.append(newEntry)
            
        }
    }
    
    func updateTakingControlIndex(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void){
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
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
            "courseId":7,
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
@available(iOS 14.0, *)
extension EventsTrackersViewController : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventsTrackersTableViewCell", for: indexPath) as! EventsTrackersTableViewCell
        let event = events[indexPath.row]
        
        if let eventName = event["eventName"] as? String {
            cell.titleLabel.text = eventName
        }
        
        if let imageUrlString = event["imageUrl"] as? String, let url = URL(string: imageUrlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        cell.eventsImageView.image = UIImage(data: data)
                        let eventFlag1 = event["eventFlag"] as? Int
                        if eventFlag1 == 1 {
                            if PatientLanguagePreference.isEnglishForLocalizedAssets() {
                                cell.yesAndNobutton.setImage(UIImage(named: "ToggleSwitch_Yes"), for: .normal)
                            } else {
                                cell.yesAndNobutton.setImage(UIImage(named: "ToggleSwitch_Si"), for: .normal)
                            }

                        }
                        else{
                            cell.yesAndNobutton.setImage(UIImage(named: "ToggleSwitch_No"), for: .normal)
                        }
                    }
                    
                    
                    var eventFlag = event["eventFlag"] as? Int ?? 0
                   
                   
                            cell.yesAndNobuttonAction = { [weak self, weak cell] in
                                guard let self = self, let cell = cell else { return }
                                if cell.yesAndNobutton.currentImage == UIImage(named: "ToggleSwitch_No") {
                                    if PatientLanguagePreference.isEnglishForLocalizedAssets() {
                                        cell.yesAndNobutton.setImage(UIImage(named: "ToggleSwitch_Yes"), for: .normal)
                                    } else {
                                        cell.yesAndNobutton.setImage(UIImage(named: "ToggleSwitch_Si"), for: .normal)
                                    }
                                } else {
                                    cell.yesAndNobutton.setImage(UIImage(named: "ToggleSwitch_No"), for: .normal)
                                }
                                guard let eventId = event["eventId"] as? Int else { return }
                                
                               eventFlag = eventFlag == 1 ? 0 : 1
                                let newEventFlag = eventFlag
                                print("newEventFlag==\(newEventFlag)")
                                let flag = newEventFlag == 1 ? "I" : "U"
                                
                                self.saveButtonEnabled = false
                                self.addOrUpdateEventsData(eventId: eventId, eventFlag: newEventFlag, flag: flag)
                            }
                    
                   

                }
            }
        }
        
       
        
//        cell.switchAction = { [weak self] isOn in
//            guard let self = self else { return }
//            // Determine the flag based on the switch state
//            let eventId = event["eventId"] as! Int
//            let eventFlag = isOn ? 1 : 0
//            let flag = isOn ? "I" : "U"
//            self.saveButtonEnabled = false
//            self.addOrUpdateEventsData(eventId: eventId, eventFlag: eventFlag, flag: flag)
//            
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    @objc func toggleButtonImage(_ sender: UIButton) {
            // Check the current image and toggle it
            if sender.currentImage == UIImage(named: "ToggleSwitch_No") {
                if PatientLanguagePreference.isEnglishForLocalizedAssets() {
                    sender.setImage(UIImage(named: "ToggleSwitch_Yes"), for: .normal)
                } else {
                    sender.setImage(UIImage(named: "ToggleSwitch_Si"), for: .normal)
                }

            } else {
                sender.setImage(UIImage(named: "ToggleSwitch_No"), for: .normal)
            }
        }
}
