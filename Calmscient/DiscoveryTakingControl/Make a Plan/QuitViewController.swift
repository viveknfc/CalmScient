//
//  QuitViewController.swift
//  CalmscientIOS
//
//  Created by mac on 25/06/24.
//

import Foundation
import UIKit
class QuitViewController: ViewController{
    
    @IBOutlet weak var notifiy_pcp: UIButton!
    @IBOutlet weak var notified_mangment: UIButton!
    @IBOutlet weak var instruction_see: UIButton!
    
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var talkToPrimaryDoc: UILabel!
    
    @IBOutlet weak var talkToPrimaryDoc2: UILabel!
    
    @IBOutlet weak var talkToPrimaryDoc3: UILabel!
    
    
    @IBOutlet weak var letsGetToKnow: UILabel!
    

    var notifyPCPDoctor = 0
    var notifyPCPMedicine = 0
    var isNotifyPcpChecked = false
       var isNotifiedMangmentChecked = false
    var button_name = ["To improve my health","To improve my relationships","To avoid hangovers","To do better at work or in school", "To save money","To lose weight or get fit","To avoid more serious problems","To meet my own personal standards"]
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = false
        notifiy_pcp.layer.borderWidth = 2
        notifiy_pcp.layer.cornerRadius = 20
        notifiy_pcp.layer.borderColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1).cgColor
        
        notified_mangment.layer.borderWidth = 2
        notified_mangment.layer.cornerRadius = 20
        notified_mangment.layer.borderColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1).cgColor
        
        instruction_see.layer.borderWidth = 2
        instruction_see.layer.cornerRadius = 20
        instruction_see.layer.borderColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1).cgColor
        
        notifiy_pcp.titleLabel?.font = UIFont(name: Fonts().lexendRegular, size: 18)
        notified_mangment.titleLabel?.font = UIFont(name: Fonts().lexendRegular, size: 18)
        notifiy_pcp.setTitle(UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Notify to PCP" : "Notificar al médico de atención primaria", for: .normal)
        notified_mangment.setTitle(UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Notify to PCP" : "Notificar al médico de atención primaria", for: .normal)
        
        // Initialization code
        super.viewDidLoad()
        
        
        
        
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
                                print("introData\(introData)")
                                notifyPCPDoctor = introData["notifyPCPDoctor"] as! Int
                                notifyPCPMedicine = introData["notifyPCPMedicine"] as! Int
                                if notifyPCPDoctor == 0{
                                    notifiy_pcp.setImage(UIImage(named: "newCircle11"), for: .normal)
                                }
                                else{
                                    notifiy_pcp.setImage(UIImage(named: "check"), for: .normal)
                                }
                                
                                if notifyPCPMedicine == 0{
                                    notified_mangment.setImage(UIImage(named: "newCircle11"), for: .normal)
                                }
                                else{
                                    notified_mangment.setImage(UIImage(named: "check"), for: .normal)

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
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        setupLanguage()
    }
    
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        
        descriptionLabel.text = AppHelper.getLocalizeString(str: "congralatuateDecision")
        talkToPrimaryDoc.text = AppHelper.getLocalizeString(str: "Talk to your primary care doctor" )
        talkToPrimaryDoc2.text = AppHelper.getLocalizeString(str: "Consider medication management" )
        talkToPrimaryDoc3.text = AppHelper.getLocalizeString(str: "Look for alcohol treatment program" )
        letsGetToKnow.text = AppHelper.getLocalizeString(str: "Now, let's get to know the drink coach features." )
       // instruction_see.titleLabel?.text = AppHelper.getLocalizeString(str: "See the introduction")
        
        instruction_see.setTitle(AppHelper.getLocalizeString(str: "See the introduction"), for: .normal)
        }
    
    @IBAction func linkButtonAction(_ sender: Any) {
        let next = UIStoryboard(name: "FavoritesVideosWebViewController", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "FavoritesVideosWebViewController") as? FavoritesVideosWebViewController
        vc?.favURL = "https://alcoholtreatment.niaaa.nih.gov/"
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func notifyDoctorAction(_ sender: Any) {
        isNotifyPcpChecked.toggle()
                let imageName = isNotifyPcpChecked ? "check" : "newCircle11"
                notifiy_pcp.setImage(UIImage(named: imageName), for: .normal)
        notifyPCPDoctor = isNotifyPcpChecked ? 1 : 0
                print("notifyPCPDoctor: \(notifyPCPDoctor)")
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
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
    func getTakingControlIntroduction(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void){
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
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
    @IBAction func notifyMedicineAction(_ sender: Any) {
        isNotifiedMangmentChecked.toggle()
               let imageName = isNotifiedMangmentChecked ? "check" : "newCircle11"
               notified_mangment.setImage(UIImage(named: imageName), for: .normal)
        notifyPCPMedicine = isNotifiedMangmentChecked ? 1 : 0
                print("notifyPCPMedicine: \(notifyPCPMedicine)")
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
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
    func updateTakingControlIndex(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void){
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/takingControl/sendNotificationToDoctorMakeAPlan") else {
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
            "notifyPCPDoctor": notifyPCPDoctor,
            "notifyPCPMedicine": notifyPCPMedicine
            
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
