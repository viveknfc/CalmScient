//
//  DiscoveryMainViewController.swift
//  CalmscientIOS
//
//  Created by NFC on 01/05/24.
//

import UIKit

@available(iOS 16.0, *)
class DiscoveryMainViewController: UIViewController{
    var tutorialFlag : Int?
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Discovery" : "Descubrir"
        super.viewDidLoad()

        tableView.register(UINib(nibName: "MyMedicalRecordsCell", bundle: nil), forCellReuseIdentifier: "MyMedicalRecordsCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
//        self.navigationController?.navigationItem.leftBarButtonItem?.isHidden = true
        self.navigationItem.leftBarButtonItem = nil
        
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
                                    print("tutorialFlag===\(tutorialFlag ?? 0)")
                                } else {
                                    print("tutorialFlag not found or not an Int")
                                }
                                tableView.reloadData()
                                self.view.hideToastActivity()
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
        // Do any additional setup after loading the view.
        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
                //set image for button
        button.setImage(UIImage(named: "profileIcon.png"), for: UIControl.State.normal)
                //add function for button
       // button.addTarget(self, action: Selector(("profileButtonPressed")), for: UIControl.Event.touchUpInside)
        button.addTarget(self, action: #selector(profileButtonPressed), for: .touchUpInside)
                //set frame
                button.frame = CGRectMake(0, 0, 32, 32)

                let barButton = UIBarButtonItem(customView: button)
                //assign button to navigationbar
                self.navigationItem.rightBarButtonItem = barButton
    }
    
    @objc func profileButtonPressed() {

        let userProfileViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        self.navigationController?.pushViewController(userProfileViewController, animated: true)
        }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.leftBarButtonItem = nil

        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        
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
}

@available(iOS 16.0, *)
extension DiscoveryMainViewController : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMedicalRecordsCell", for: indexPath) as! MyMedicalRecordsCell
        if indexPath.row == 0{
            cell.medicalCellImage.image = UIImage(named: "img1")
            cell.titleTextField.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Managing anxiety" : "Manejar la ansiedad"
        } else if indexPath.row == 1 {
            cell.medicalCellImage.image = UIImage(named: "img2")
            cell.titleTextField.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Changing your response to stress" : "Cambiar tu respuesta al estrés"
        } else {
            cell.medicalCellImage.image = UIImage(named: "img3")
            cell.titleTextField.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Taking control" : "Tomando el control"
        }
        cell.medicalCellImage.contentMode = .center
        cell.cellBottomImageView.isHidden = false
        cell.titleTextField.isHidden = false
        cell.arrowImage.isHidden = false
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 172
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let backItem = UIBarButtonItem()
            backItem.title = "" // Set an empty string for the back button
            self.navigationItem.backBarButtonItem = backItem
            
            let next = UIStoryboard(name: "ManagingAnxietyBeginScreen", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "ManagingAnxietyBeginScreen") as? ManagingAnxietyBeginScreen
            vc?.title = "VManaging Anxiety"
            //vc?.courseID = 2
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if indexPath.row == 1 {
            let next = UIStoryboard(name: "CourseViewController", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "CoursesViewController") as? CoursesViewController
            vc?.title =  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "Changing your response to stress" : "Cambiando tu respuesta al estrés"
            vc?.courseID = 3
            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
            
            if tutorialFlag == 1 {
                let next = UIStoryboard(name: "Discovery", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "Discovery") as? Discovery
                vc?.title = "Taking Control"
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            else if tutorialFlag == 0 {
                print("taking control index pressed")
                
                let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "TakingControlIndex") as? TakingControlIndex
                vc?.title = AppHelper.getLocalizeString(str: "Taking control")
                self.navigationController?.pushViewController(vc!, animated: true)


            }
            else {
//                let next = UIStoryboard(name: "Discovery", bundle: nil)
//                let vc = next.instantiateViewController(withIdentifier: "Discovery") as? Discovery
//                vc?.title = "Taking Control"
//                self.navigationController?.pushViewController(vc!, animated: true)
                
                let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "TakingControlIndex") as? TakingControlIndex
                vc?.title = AppHelper.getLocalizeString(str: "Taking control")
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            
        }
        
    }
    
}
