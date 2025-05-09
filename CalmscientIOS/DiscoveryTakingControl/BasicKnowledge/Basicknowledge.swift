//
//  Bsicknowledge.swift
//  CalmscientIOS
//
//  Created by mac on 01/06/24.
//

import Foundation
import Foundation
import UIKit
@available(iOS 16.0, *)
class Basicknowledge: ViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var completeButton: CapsuleButton1!

    var basicData2: [[String: Any]] = []

        override func viewDidLoad() {
            super.viewDidLoad()

            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            tableView.register(UINib(nibName: "CustomCheckboxCell", bundle: nil), forCellReuseIdentifier: "CustomCheckboxCell")
            tableView.estimatedRowHeight = 104.0
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
            
            let selectedLanguageID = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            let title = selectedLanguageID == 1 ? "Complete" : "Finalizar"
            completeButton.setTitle(title, for: .normal)
            completeButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14)

        }

    override func viewWillAppear(_ animated: Bool) {
        
        getBasicKnowledgeQuestions()
//        completeButton.updateTitleForLanguage()

    }
    
    @objc func backButtonOverrideAction() {

        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "TakingControlIndex") as? TakingControlIndex
        vc?.title = AppHelper.getLocalizeString(str: "Taking control")
        vc?.initialSegmentIndex = 0
        
        self.navigationController?.pushViewController(vc!, animated: true)
        
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return basicData2.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCheckboxCell", for: indexPath) as! CustomCheckboxCell
        let newData = basicData2[indexPath.row]
        cell.customLabel.text = newData["sectionName"] as? String
     
        if let isCompleted = newData["isCompleted"] as? Int {
            cell.checkBox.isHidden = isCompleted != 1 // Hide if not completed
        } else {
            cell.checkBox.isHidden = true // Hide if `isCompleted` is not found or not an Int
        }

       cell.separatorInset = .zero
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let next = UIStoryboard(name: "BasicStandardDrink", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "BasicStandardDrink") as? BasicStandardDrink
            let newData = basicData2[indexPath.row]
            vc?.sectionID1 = newData["sectionId"] as? Int
            vc?.title =  AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }else if(indexPath.row == 1){
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "USGuideLineForDrinkingVC") as? USGuideLineForDrinkingVC
            let newData = basicData2[indexPath.row]
            vc?.sectionID2 = newData["sectionId"] as? Int
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if(indexPath.row == 2){
            let next = UIStoryboard(name: "Moderation", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "Moderation") as? Moderation
            vc?.title =  AppHelper.getLocalizeString(str: "Basic Knowledge")
            let newData = basicData2[indexPath.row]
            vc?.sectionID3 = newData["sectionId"] as? Int
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if(indexPath.row == 3){
            let next = UIStoryboard(name: "BasicknowledgeVideo", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "BasicknowledgeVideo") as? BasicknowledgeVideo
            let newData = basicData2[indexPath.row]
            vc?.sectionID4 = newData["sectionId"] as? Int
            vc?.title =  AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if(indexPath.row == 4){
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "ConsequenceVC") as? ConsequenceVC
            let newData = basicData2[indexPath.row]
            vc?.sectionID5 = newData["sectionId"] as? Int
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if(indexPath.row == 5){
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "HoldYourLiquorVC") as? HoldYourLiquorVC
            let newData = basicData2[indexPath.row]
            vc?.sectionID7 = newData["sectionId"] as? Int
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if(indexPath.row == 6){
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "MyDrinkingHabitVC") as? MyDrinkingHabitVC
            _ = basicData2[indexPath.row]
            
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    
    //MARK: - Basic Knowledge API Call
    
    func getBasicKnowledgeQuestions () {
        
        self.view.showToastActivity()
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Any] = [
            "plId": userInfo.patientLocationID,
            "patientId": userInfo.patientID,
            "clientId": userInfo.clientID,
            "assessmentId": 1
        ]

        APIService.DBasicKQAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            self.getresponseforBasicKnowAPI(response: response)
        }
        
    }
    
    //MARK: - Basic Knowledge API Response
    
    func getresponseforBasicKnowAPI(response: Any) {
        
        DispatchQueue.main.async {
            self.view.hideToastActivity()
        }
        
        
        if let responseDict = response as? [String: Any],
           let indexArray = responseDict["index"] as? [[String: Any]] {
            
            print("Response from Basic Knowledge API:", indexArray)
            basicData2 = indexArray
            tableView.reloadData()
            
        } else {
            print("Unsupported response type:", type(of: response))
        }
    }
    
    //MARK: - Complete Button Pressed
    
    @IBAction func completeButtonPressed(_ sender: Any) {
//        self.navigationController?.popViewController(animated: true)
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "TakingControlIndex") as? TakingControlIndex
        vc?.title = AppHelper.getLocalizeString(str: "Taking control")
        vc?.initialSegmentIndex = 0
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    

}
