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

        self.navigationItem.leftBarButtonItem = nil
        
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

            self.navigationController?.pushViewController(vc!, animated: true)
            
        } else if indexPath.row == 1 {
            
            let next = UIStoryboard(name: "CourseViewController", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "CoursesViewController") as? CoursesViewController
            vc?.title =  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "Changing your response to stress" : "Cambiando tu respuesta al estrés"
            vc?.courseID = 3
            self.navigationController?.pushViewController(vc!, animated: true)
            
        } else {
            
            getTakingControlIndexAPICalling()
            
        }
        
    }
    
}

@available(iOS 16.0, *)
extension DiscoveryMainViewController {
    
    //MARK: - GetTakingControlIndexAPICalling
    
        func getTakingControlIndexAPICalling() {
            self.view.showToastActivity()
            guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
                fatalError("Unable to found Application Shared Info")
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let currentDateString = formatter.string(from: Date())
            
            let params: [String: Any] = [
                    "patientId": userInfo.patientID,
                    "plId": userInfo.patientLocationID,
                    "clientId": userInfo.clientID,
                    "date": currentDateString
                ]
            
            print("the Taking control API call params", params)
            
            APIService.getTakingControlIndexAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
                
                self.view.hideToastActivity()
                self.parsetheDrinkingResponse(response: response)
            }
        }
        
    //MARK: - Parsing the Response
        
        func parsetheDrinkingResponse(response: AnyObject) {
            self.view.hideToastActivity()

            if let responseString = response as? String {
                print("Response received from Get Drinking Data API calling is", responseString)
            } else if let responseDict = response as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                    let data = try JSONDecoder().decode(DrinkingTakingControlResponse.self, from: jsonData)

                    // Access skipTutorialFlag from the first CourseList
                    if let firstCourse = data.courseLists?.first {
                        let skipTutorial = firstCourse.skipTutorialFlag ?? 0
                        print("First course's skipTutorialFlag is: \(skipTutorial)")
                        
                        if skipTutorial == 1  {
                            
                            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
                            let vc = next.instantiateViewController(withIdentifier: "TakingControlIndex") as? TakingControlIndex
                            vc?.title = AppHelper.getLocalizeString(str: "Taking control")
                            vc?.initialSegmentIndex = 0
                            
                            self.navigationController?.pushViewController(vc!, animated: true)
                            
        
                        } else {
                            
                            let next = UIStoryboard(name: "TakingControllIntro", bundle: nil)
                            let vc = next.instantiateViewController(withIdentifier: "TakingControllIntro") as? TakingControllIntro
                            self.navigationController?.pushViewController(vc!, animated: true)
                            
                        }
                    }

                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else {
                print("Unsupported response type:", type(of: response))
            }
        }
    
}

