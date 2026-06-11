//
//  DiscoveryMainViewController.swift
//  CalmscientIOS
//
//  Created by NFC on 01/05/24.
//

import UIKit

class DiscoveryMainViewController: ViewController {
    var tutorialFlag : Int?
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewDidLoad()
    

        tableView.register(UINib(nibName: "MyMedicalRecordsCell", bundle: nil), forCellReuseIdentifier: "MyMedicalRecordsCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none

        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        
        // Existing profile button
        let profileButton = UIButton(type: .custom)
        profileButton.setImage(UIImage(named: "profileIcon.png"), for: .normal)
        profileButton.addTarget(self, action: #selector(profileButtonPressed), for: .touchUpInside)
        
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileButton.widthAnchor.constraint(equalToConstant: 28),
            profileButton.heightAnchor.constraint(equalToConstant: 28)
        ])

        profileButton.imageView?.contentMode = .scaleAspectFit
        profileButton.contentHorizontalAlignment = .fill
        profileButton.contentVerticalAlignment = .fill

        let profileBarButton = UIBarButtonItem(customView: profileButton)

        // New second button (e.g., settings)
        let settingsButton = UIButton(type: .custom)
        settingsButton.setImage(UIImage(named: "Citation"), for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsButtonPressed), for: .touchUpInside)
        settingsButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        
        settingsButton.imageView?.contentMode = .scaleAspectFit
        settingsButton.contentHorizontalAlignment = .fill
        settingsButton.contentVerticalAlignment = .fill
        
        let settingsBarButton = UIBarButtonItem(customView: settingsButton)

        self.navigationItem.rightBarButtonItems = [profileBarButton, settingsBarButton]
        
    }
    
    @objc func profileButtonPressed() {
        UserDefaults.standard.set(true, forKey: "shouldPopToDis")
        navigationController?.pushViewController(UserProfileHostingController(), animated: true)
    }

    @objc func settingsButtonPressed() {
        CitationWebNavigation.pushSourcesAndCitations(from: navigationController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true

        let titleText = "Discovery".localized

        let titleLabel = UILabel()
        titleLabel.text = titleText
        titleLabel.font = UIFont(name: Fonts().lexendMedium, size: 18)
        titleLabel.textColor = .label // or any color you want
        navigationItem.titleView = titleLabel
        
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setupLanguage() {
        
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
            cell.titleTextField.text = "Managing anxiety".localized
        } else if indexPath.row == 1 {
            cell.medicalCellImage.image = UIImage(named: "img2")
            cell.titleTextField.text = "Changing your response to stress".localized
        } else {
            cell.medicalCellImage.image = UIImage(named: "img3")
            cell.titleTextField.text = "Taking control".localized
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
            
            ManagingAnxietyBeginNavigation.push(from: self)
            
        } else if indexPath.row == 1 {
            
            CoursesNavigation.push(
                courseID: 3,
                title: "Changing your response to stress".localized,
                from: self
            )
            
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
                        
//                        if skipTutorial == 1  { //0
                            
                            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
                            let vc = next.instantiateViewController(withIdentifier: "TakingControlIndex") as? TakingControlIndex
                            vc?.title = AppHelper.getLocalizeString(str: "Taking control")
                            vc?.initialSegmentIndex = 0
                            vc?.moveToIntro = skipTutorial == 0
                            
                            self.navigationController?.pushViewController(vc!, animated: true)
                            
        
//                        } else {
//                            
//                            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
//                            let vc = next.instantiateViewController(withIdentifier: "VTakingControlIntroVC") as? VTakingControlIntroVC
//                            self.navigationController?.pushViewController(vc!, animated: true)
//                            
//                        }
                    }

                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else {
                print("Unsupported response type:", type(of: response))
            }
        }
    
}

