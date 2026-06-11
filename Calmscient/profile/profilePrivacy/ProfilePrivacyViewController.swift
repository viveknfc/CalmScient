//
//  ProfilePrivacyViewController.swift
//  CalmscientIOS
//
//  Created by KA on NA.
//

import UIKit

class ProfilePrivacyViewController: UIViewController {
    
    var onScheetClosed:(()->Void)?
    @IBOutlet weak var privacyTableView: UITableView!
    var profilePrivacyData: [[String: Any]] = []
    @IBOutlet weak var privacyLabel: UILabel!
    
    @IBOutlet weak var privacyDescription: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.view.showToastActivity()
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        getPatientPrivacy(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID,bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken){ [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            self.view.hideToastActivity()
                            self.profilePrivacyData = json["patientConsent"] as! [[String : Any]]
                            print("the profile privacy data is", self.profilePrivacyData)
                            self.privacyTableView.reloadData()
                            
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
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: Notification.Name("RemoveDimmingView"), object: nil)
        onScheetClosed?()
    }
    
    func setupLanguage() {
        
privacyLabel.text = AppHelper.getLocalizeString(str:"Privacy")
        privacyDescription.text = AppHelper.getLocalizeString(str:"Data from Calmscient can be transmitted to your doctor for clinical review purposes. Please indicate which data you allow to be shared with your doctor by selecting either Yes or No next to each data element below")
        
        }
    private func setupTableView() {
        let nib = UINib(nibName: "ProfilePrivacyTableViewCell", bundle: nil)
        privacyTableView.register(nib, forCellReuseIdentifier: "ProfilePrivacyTableViewCell")
        privacyTableView.separatorStyle = .none
        privacyTableView.dataSource = self
        privacyTableView.delegate = self
    }
    
    @IBAction func didClickOnClose(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("RemoveDimmingView"), object: nil)
        dismiss(animated: true)
    }
    func getPatientPrivacy(plId: Int, patientId: Int, clientId: Int, bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
        
        // Define the URL
        guard let url = URL(string: "\(baseURLString)identity/api/v1/settings/getPatientPrivacy") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        
        // Define the JSON payload
        let payload: [String: Any] = [
            "plId": plId,
            "patientId": patientId,
            "clientId": clientId,
        ]
        
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
                //  print("Response JSON: \(jsonResponse)")
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
    func updatePatientPrivacyContents(plId: Int, patientId: Int, clientId: Int, bearerToken: String,flag: Int,consentListId: Int) {
        
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
        
        // Define the URL
        guard let url = URL(string: "\(baseURLString)identity/api/v1/settings/updatePatientConsent") else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        let payload: [String: Any] = [
            "plId": plId,
            "patientId": patientId,
            "clientId": clientId,
            "flag": flag,
            "consentListId": consentListId
        ]
        self.view.hideToastActivity()
        do {
                let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
                request.httpBody = jsonData
            } catch {
                print("Error serializing JSON: \(error)")
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    print("Error: \(error)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    return
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("HTTP Error: \(httpResponse.statusCode)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let statusResponse = jsonResponse["statusResponse"] as? [String: Any],
                           let responseCode = statusResponse["responseCode"] as? Int,
                           let responseMessage = statusResponse["responseMessage"] as? String,
                           let isUpdated = jsonResponse["isUpdated"] as? Int {
                            print("Response Code: \(responseCode)")
                            print("Response Message: \(responseMessage)")
                            print("Is Updated: \(isUpdated)")
//                            DispatchQueue.main.async {
//                                self.privacyTableView.reloadData()
//                            }
                        } else {
                            print("Invalid JSON structure")
                        }
                    } else {
                        print("Invalid JSON format")
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
            
            task.resume()
    }
}

extension ProfilePrivacyViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profilePrivacyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = profilePrivacyData[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePrivacyTableViewCell", for: indexPath) as? ProfilePrivacyTableViewCell else {
            return UITableViewCell()
        }
      //  DispatchQueue.main.async {
            let eventFlag1 = data["consentFlag"] as? Int
            if eventFlag1 == 1{
                if PatientLanguagePreference.isEnglishForLocalizedAssets() {
                    cell.yesAndNobutton.setImage(UIImage(named: "ToggleSwitch_Yes"), for: .normal)
                }else {
                    cell.yesAndNobutton.setImage(UIImage(named: "ToggleSwitch_Si"), for: .normal)
                }
            }
            else{
                cell.yesAndNobutton.setImage(UIImage(named: "ToggleSwitch_No"), for: .normal)
            }
      //  }
        
        cell.yesAndNobutton.tag = indexPath.row
        cell.yesAndNobutton.addTarget(self, action: #selector(yesAndNobuttonTapped(_:)), for: .touchUpInside)
        
        
        
        cell.titleLabel.text = data["consentListName"] as? String
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            
        }
    }
    
    @objc func yesAndNobuttonTapped(_ sender: UIButton) {
        let rowIndex = sender.tag
        let data = profilePrivacyData[rowIndex]
        
        // Determine the new state
        let isOn = sender.currentImage == UIImage(named: "ToggleSwitch_No")
        let new = isOn ? 1 : 0
        
        // Update the button image based on the new state
        DispatchQueue.main.async {

            var img = UIImage()
            if PatientLanguagePreference.isEnglishForLocalizedAssets() {
                img = UIImage(named: "ToggleSwitch_Yes")!
            }else {
                img = UIImage(named: "ToggleSwitch_Si")!
            }
            
            let newImage = new == 1 ? img : UIImage(named: "ToggleSwitch_No")
            sender.setImage(newImage, for: .normal)
            
            // Show the toast activity
            self.view.showToastActivity()
            
            // Retrieve the user info and update the patient privacy contents
            guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
                fatalError("Unable to found Application Shared Info")
            }
            
            // Make the network call to update the patient privacy contents
            self.updatePatientPrivacyContents(
                plId: userInfo.patientLocationID,
                patientId: userInfo.patientID,
                clientId: userInfo.clientID,
                bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken,
                flag: new,
                consentListId: data["consentListId"] as! Int
            )
        }
    }
}

