//
//  Smoking Control.swift
//  CalmscientIOS
//
//  Created by NFC User on 28/11/24.
//

import Foundation
import UIKit

class SmokingControl: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var leftBox: UIView!
    @IBOutlet weak var rightBox: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resourceTableView: UITableView!
    var basicData2: [Course]?
    
    var resourceData: [(String, String, UIImage)] = []
    
    override func viewDidLoad() {
        leftBox.layer.cornerRadius = 12
        leftBox.layer.masksToBounds = true
        
        rightBox.layer.cornerRadius = 12
        rightBox.layer.masksToBounds = true
        
        resourceData = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? eresourceData : sresourceData
        
        tableView.register(UINib(nibName: "IndexBasicTableCell", bundle: nil), forCellReuseIdentifier: "smokingBasicCell")

        resourceTableView.register(UINib(nibName: "SomkingIndexResourceCell", bundle: nil), forCellReuseIdentifier: "SmokingResourceCell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        resourceTableView.delegate = self
        resourceTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        TakingControlData ()
        
    }
    
    let data = [("Basic knowledge", UIImage(named: "check") ?? UIImage()), ("Make a plan", UIImage(named: "check") ?? UIImage()), ("Stay focused", UIImage(named: "check") ?? UIImage()), ("My progress", UIImage(named: "check") ?? UIImage())]
    
    let eresourceData = [("Breathing exercises", "Let’s use breathing exercises to support your journey. They help reduce stress and cravings, and provide a calming distraction..", UIImage(named: "BreathingTechnic") ?? UIImage()), ("Managing anxiety course", "Anxiety can trigger drinking and smoking, but healthy coping strategies help you to stay strong", UIImage(named: "img1") ?? UIImage()), ("Screenings", "Let’s set a goal to screen for depression, anxiety, and alcohol and smoking regularly, as these can support your success", UIImage(named: "Screening_Cell") ?? UIImage())] //("Work your strengths", "Do something you're good at to build self-confidence, then tackle a tougher task.", UIImage(named: "Maskgroup") ?? UIImage())
    
    let sresourceData = [("Ejercicios de respiración", "Usemos ejercicios de respiración para apoyar tu viaje. Ayudan a reducir el estrés, los antojos, y proporcionan calma.", UIImage(named: "BreathingTechnic") ?? UIImage()), ("Curso de manejo de la ansiedad", "La ansiedad puede desencadenar el consumo de alcohol y tabaco, pero hay estrategias saludables que pueden ayuda", UIImage(named: "img1") ?? UIImage()), ("Evaluaciones", "Establezcamos metas para analizar la depresión, ansiedad, alcohol y tabaco de forma regular, esto puede apoyar tu éxito", UIImage(named: "Screening_Cell") ?? UIImage())] //("Work your strengths", "Do something you're good at to build self-confidence, then tackle a tougher task.", UIImage(named: "Maskgroup") ?? UIImage()),
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return basicData2?.count ?? 0 //data.count
        } else if tableView == self.resourceTableView {
            return resourceData.count
        }
        return 0

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.tableView {
                  let cell = tableView.dequeueReusableCell(withIdentifier: "smokingBasicCell", for: indexPath) as! SmokingBasicIndexTableCell
            
                cell.selectionStyle = .none
                  
            // Fetch course object
            let course = basicData2?[indexPath.row]
            
            // Assign course name to cell text
            cell.cellContentText.text = course?.courseName

            // Set checkmark image based on completion status
            if course?.isCompleted == 1 {
                cell.ticckImage.image = UIImage(named: "check")
            } else {
                cell.ticckImage.image = nil
            }

            // Configure cell appearance for the first item
            if indexPath.row == 0 {
                cell.configureCell(isActive: true)
            } else {
                cell.configureCell(isActive: false)
            }
                  
                  return cell
              } else if tableView == self.resourceTableView {
                  let cell = tableView.dequeueReusableCell(withIdentifier: "SmokingResourceCell", for: indexPath) as! SmokingIndexResourceTableViewCell
                  
                  cell.selectionStyle = .none
                  
                  let content = resourceData[indexPath.row].0
                  let desc = resourceData[indexPath.row].1
                  let image = resourceData[indexPath.row].2
                  
                  cell.headLabel.text = content
                  cell.desc.text = desc
                  cell.rightImage.image = image
                  
                  return cell
              }
              
              return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.tableView {
                   return 60
               } else if tableView == self.resourceTableView {
                   return 180 // Default row height
               }
               return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10 // Adjust as needed
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10 // Adjust as needed
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.tableView {
            if indexPath.row == 0 {
                print("first row clicked")
                let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "SmokingBasicVc") as? SmokingBasicVc
                vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
                self.navigationController?.pushViewController(vc!, animated: true)
                
            } else {
                let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
                if let customAlertVC = storyboard.instantiateViewController(withIdentifier: "FullComingSoonVC") as? FullComingSoonVC {
                    customAlertVC.modalPresentationStyle = .overFullScreen
                    customAlertVC.modalTransitionStyle = .crossDissolve
                    self.present(customAlertVC, animated: true, completion: nil)
                }
            }
        } else if tableView == self.resourceTableView {
            print("resource table clicked")
            if indexPath.row == 0 {
                let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
                let destinationVC = storyboard.instantiateViewController(withIdentifier: "BreathingTechnique") as! BreathingTechnique
                self.navigationController?.pushViewController(destinationVC, animated: true)
            } else if indexPath.row == 1 {
                let next = UIStoryboard(name: "ManagingAnxietyBeginScreen", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "ManagingAnxietyBeginScreen") as? ManagingAnxietyBeginScreen
                self.navigationController?.pushViewController(vc!, animated: true)
            } else if indexPath.row == 2 {
                let next = UIStoryboard(name: "ScreeningListVC", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "ScreeningListVC") as? ScreeningListVC
                vc?.isComingFromParticularVC = true
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        }
        
    }
    
    //MARK: - Need to talk button
    
    @IBAction func needToTalkButtonClicked(_ sender: Any) {
        let next = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController
                vc?.title = "Emergency resource"
                self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    //MARK: - Basic Knowledge API Call
    
    func TakingControlData () {
        
        self.view.showToastActivity()
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Any] = [
            "plId": userInfo.patientLocationID,
            "clientId": userInfo.clientID,
            "patientId": userInfo.patientID,
            "date": ""
        ]

        APIService.SGetTakingControlAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            self.getresponseforTakingControlAPI(response: response)
        }
        
    }
    
    //MARK: - Basic Knowledge API Response
    
    func getresponseforTakingControlAPI(response: Any) {
        
        if let responseDict = response as? [String: Any],
           let indexArray = responseDict["courseLists"] as? [[String: Any]] {
            
            print("Response from Smoking Taking Control API:", indexArray)
            
            do {
                // Convert dictionary array to JSON data
                let jsonData = try JSONSerialization.data(withJSONObject: indexArray, options: [])
                
                // Decode JSON data into an array of Course objects
                let decodedCourses = try JSONDecoder().decode([Course].self, from: jsonData)
                
                // Assign the decoded courses to your variable
                basicData2 = decodedCourses
                
            } catch {
                print("Error decoding course list: \(error)")
            }
            
        } else {
            print("Unsupported response type:", type(of: response))
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.view.hideToastActivity()
            }
        }
    }

    
}

