//
//  MySmokingHabitVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 12/03/25.
//

import UIKit

class MySmokingHabitVC: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var smokingTableView: UITableView!
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    var selectedRowIndex : Int?
    var sectionID6: Int?
    
    var data: [(String, UIImage, [String], Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        smokingTableView.register(UINib(nibName: "VivTableViewCell", bundle: nil), forCellReuseIdentifier: "VivCustomCell")

            // Set the delegate and data source
        smokingTableView.delegate = self
        smokingTableView.dataSource = self
        // Do any additional setup after loading the view.
        
        rebuildLocalizedData()
        
        completeButton.setTitle("Complete".localized, for: .normal)
        completeButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        rebuildLocalizedData()
        smokingTableView.reloadData()
        completeButton.setTitle("Complete".localized, for: .normal)
        if let indexPath = smokingTableView.indexPathForSelectedRow {
            smokingTableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    private func rebuildLocalizedData() {
        let check = UIImage(named: "check") ?? UIImage()
        let keys: [(String, String)] = [
            ("smoking_habit_stage_thinking_title", "smoking_habit_stage_thinking_body"),
            ("smoking_habit_stage_ready_title", "smoking_habit_stage_ready_body"),
            ("smoking_habit_stage_quitting_title", "smoking_habit_stage_quitting_body"),
            ("smoking_habit_stage_smokefree_title", "smoking_habit_stage_smokefree_body")
        ]
        var newData = keys.map { titleKey, bodyKey -> (String, UIImage, [String], Bool) in
            (titleKey.localized, check, [bodyKey.localized], false)
        }
        if let sel = selectedRowIndex, sel < newData.count {
            for idx in newData.indices {
                var row = newData[idx]
                row.3 = (idx == sel)
                newData[idx] = row
            }
        }
        data = newData
    }

    
    @IBAction func yesButtonPressede(_ sender: Any) {
        
        guard selectedRowIndex != nil else {
            
            let alertText = "Please select the stage that applies to you.".localized
            
            showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: alertText,
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {
                    print("Retry action triggered")
                },
                dismissAction: {
                    print("Dismiss action triggered")
                }
            )
            return
        }
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Specify the desired format
        let currentDate = Date()
        let formattedDate = dateFormatter.string(from: currentDate)
        
        let params: [String: Any] = [
                "patientId": userInfo.patientID,
                "entry": data[selectedRowIndex ?? 0].0,
                "plId": userInfo.patientLocationID,
                "clientId": userInfo.clientID,
                "entryType": "discovery_exercise",
                "createdAt": formattedDate
                // Add other necessary parameters here
            ]

        print("the Yes Button in My Smoking Habit API call params", params)
        
        self.view.showToastActivity()
        
        APIService.AddJournalAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") {  [self] response in
            print(response)
            self.view.hideToastActivity()
            if let responseDict = response as? [String: Any],
               let responseMessage = responseDict["responseMessage"] as? String {
                print(responseMessage)
                self.showSuccessAlert(successContent: responseMessage, centreImage: nil, okButtonAction: {
                    
                })
            }

            
        }
        
    }
    
    
    @IBAction func completeButtonPresseed(_ sender: Any) {
        
        guard selectedRowIndex != nil else {
            
            let alertText = "Please select the stage that applies to you.".localized
            
            showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: alertText,
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {
                    print("Retry action triggered")
                },
                dismissAction: {
                    print("Dismiss action triggered")
                }
            )
            return
        }

        
        showGeneralAlert(
            title: "We will guide you to create a strategic plan in Taking control full version.".localized,
            okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
            okAction: {
                self.completeButtonAPICall()
            },
            showDismissButton: false
        )

    }
    
    //MARK: - Table Delegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VivCustomCell", for: indexPath) as! VivCustomTableViewCell

        // Get the data for the row
        let (heading, image, subtasks, isSelected) = data[indexPath.row]

        // Configure the cell
        cell.configureCell1(heading: heading, image: image, subtasks: subtasks,isSelected: isSelected)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8 // Adjust as needed
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8 // Adjust as needed
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("table row selected")
        selectedRowIndex = indexPath.row
        
        for (i, _) in data.enumerated() {
            if i == indexPath.row {
                print(data[i].3)
                data[i].3 = true
            }
            else{
                data[i].3 = false
            }
        }
        
        DispatchQueue.main.async {
            tableView.reloadData()
        }
        
    }

    //MARK: - Complete Button API Call
    
    func completeButtonAPICall() {
        self.view.showToastActivity()
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Any] = [
            "isCompleted":1,
            "patientId": userInfo.patientID,
            "sectionId":sectionID6 ?? 0
        ]

        APIService.SUpdateBasicKAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            self.getresponseforBasicKnowAPI(response: response)
        }
    }
    
    //MARK: - Complete Button API Response
    
    func getresponseforBasicKnowAPI(response: Any) {
        self.view.hideToastActivity()
        
        if let responseDict = response as? [String: Any] {
            
            print("Response from Basic standard complete button:", responseDict)
            self.navigationController?.popViewController(animated: true)
            
        } else {
            print("Unsupported response type:", type(of: response))
        }
    }
    


}
