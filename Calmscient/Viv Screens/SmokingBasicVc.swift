//
//  SmokingBasicVc.swift
//  CalmscientIOS
//
//  Created by NFC User on 27/12/24.
//

import UIKit

class SmokingBasicVc: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    
    var data: [String] = []
    var isCompleted: [Int] = []
    var sectionId: [Int] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        tableView.register(UINib(nibName: "CustomCheckboxCell", bundle: nil), forCellReuseIdentifier: "CustomCheckboxCell")
        tableView.rowHeight = UITableView.automaticDimension
        
        completeButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getBasicKnowledgeQuestions ()
        title = "Basic knowledge"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCheckboxCell", for: indexPath) as! CustomCheckboxCell
        let newData = data[indexPath.row]
        let iscom = isCompleted[indexPath.row]
        cell.customLabel.text = newData
        
        if iscom == 1 {
            cell.checkBox.isHidden = false // Hide if not completed
        } else {
            cell.checkBox.isHidden = true // Hide if `isCompleted` is not found or not an Int
        }
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let screenTitle = AppHelper.getLocalizeString(str: "Basic Knowledge")
        if indexPath.row == 0 {
            if #available(iOS 16.0, *) {
                TobaccoNavigation.push(
                    from: self,
                    sectionId: sectionId[indexPath.row],
                    navigationTitle: screenTitle
                )
            }
        }
        else if indexPath.row == 1 {
            if #available(iOS 16.0, *) {
                VapingNavigation.push(
                    from: self,
                    sectionId: sectionId[indexPath.row],
                    navigationTitle: screenTitle
                )
            }
        }
        else if indexPath.row == 2 {
            if #available(iOS 16.0, *) {
                SmokingRelaxNavigation.push(
                    from: self,
                    sectionId: sectionId[indexPath.row],
                    navigationTitle: screenTitle
                )
            }
        }
        else if indexPath.row == 3 {
            if #available(iOS 16.0, *) {
                ChallengingToQuitNavigation.push(
                    from: self,
                    sectionId: sectionId[indexPath.row],
                    navigationTitle: AppHelper.getLocalizeString(str: "Basic Knowledge")
                )
            }
        }
        else if indexPath.row == 4 {
            if #available(iOS 16.0, *) {
                SmokingAffectMentalHealthNavigation.push(
                    from: self,
                    sectionId: sectionId[indexPath.row],
                    navigationTitle: AppHelper.getLocalizeString(str: "Basic Knowledge")
                )
            }
        }
        else if indexPath.row == 5 {
            if #available(iOS 16.0, *) {
                MySmokingHabitNavigation.push(
                    from: self,
                    sectionId: sectionId[indexPath.row],
                    navigationTitle: screenTitle
                )
            }
        }
    }
    

    @IBAction func completeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Basic Knowledge API Call
    
    func getBasicKnowledgeQuestions () {
        
        self.view.showToastActivity()
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Any] = [
            "patientId": userInfo.patientID,
            "clientId": userInfo.clientID,
        ]
        
        print("the input param for the smoking basic is", params)

        APIService.SBasicKQAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            self.getresponseforBasicKnowAPI(response: response)
        }
        
    }
    
    //MARK: - Basic Knowledge API Response
    
    func getresponseforBasicKnowAPI(response: Any) {
        self.view.hideToastActivity()
        
        if let responseDict = response as? [String: Any],
           let indexArray = responseDict["index"] as? [[String: Any]] {
            
            print("Response from Smoking Basic Knowledge API:", indexArray)
            data = indexArray.compactMap { $0["sectionName"] as? String }
            isCompleted = indexArray.compactMap { $0["isCompleted"] as? Int }
            sectionId = indexArray.compactMap { $0["sectionId"] as? Int }
            tableView.reloadData()
            
        } else {
            print("Unsupported response type:", type(of: response))
        }
    }
    

}
