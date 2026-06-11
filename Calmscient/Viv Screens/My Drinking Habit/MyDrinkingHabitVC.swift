//
//  MyDrinkingHabitVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 10/12/24.
//

import UIKit

class MyDrinkingHabitVC: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var drinkCountCalculatorButton: LinearGradientButton!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedRowIndex : Int?
    var sectionID6: Int?
    
    var data: [(String, UIImage, [String], Bool)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "VivTableViewCell", bundle: nil), forCellReuseIdentifier: "VivCustomCell")

            // Set the delegate and data source
            tableView.delegate = self
            tableView.dataSource = self
        tableView.separatorStyle = .none
        
        data = localizedData

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @IBAction func drinkCountButtonPressed(_ sender: Any) {
        let backItem = UIBarButtonItem()
        backItem.title = "" // Set an empty string for the back button
        self.navigationItem.backBarButtonItem = backItem
        
        if #available(iOS 16.0, *) {
            DrinkingCountNavigation.push(from: self)
        } else {
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "DrinkingCountVC") as? DrinkingCountVC
            vc?.title = AppHelper.getLocalizeString(str: "Drink counts calculator")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
        
    }
    
    static let localizedDataTemplate: [(String, UIImage, [String])] = [
        ("Moderate drinking".localized, UIImage(named: "check") ?? UIImage(), ["Always drink with the moderate drinking standard.".localized, "Can effortlessly commit alcohol free plan for week or month.".localized, "Can choose to drink or not even though people around you are drinking.".localized]),
        ("Moderate everyday drinking".localized, UIImage(named: "check") ?? UIImage(), ["Always drink with the moderate drinking standard but struggles to have alcohol- free day.".localized, "Drink daily as sleep aids or relaxation.".localized, "Expect to have a drink after work or in the evening and get irritated or stressed when you can't have it.".localized]),
        ("Social / weekend binge drinking".localized, UIImage(named: "check") ?? UIImage(), ["Casual drinking turns into doing things that you normal wouldn't do or that go against your judgement while you're sober, such as driving under alcohol influence.".localized, "Often seek the mood-altering effects (the buzz) or using alcohol as a coping mechanism, sometimes in isolation.".localized, "Get defensive when someone tries to limit your consumption or asks you to stop.".localized, "Remember? Binge drinking is: Men - Up to 5 or more drinks within 2 hrs Women - Up to 4 or more drinks within 2 hrs.".localized]),
        ("Problematic drinking".localized, UIImage(named: "check") ?? UIImage(), ["Drinking until drunk.".localized, "Going to work drunk or drinking on the job.".localized, "Driving while drunk or have driven while drunk.".localized, "Getting in trouble with the law or being injured due to drinking.".localized, "Doing something under the influence of alcohol that they would not otherwise do.".localized, "Having problems at school, with social relationships, or with family members because of drinking.".localized, "Using alcohol to decrease anxiety or sadness.".localized, "Lying about or trying to hide drinking habits.".localized, "Needing more alcohol to feel its effects.".localized, "Feeling grouchy, resentful, or unreasonable when not drinking.".localized])
    ]
    
    var localizedData: [(String, UIImage, [String], Bool)] {
        Self.localizedDataTemplate.map { ($0.0, $0.1, $0.2, false) }
    }
    
   

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VivCustomCell", for: indexPath) as! VivCustomTableViewCell

        // Get the data for the row
        let (heading, image, subtasks, isSelected) = data[indexPath.row]

        // Configure the cell
        cell.configureCell(heading: heading, image: image, subtasks: subtasks,isSelected: isSelected)

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
    


}


extension MyDrinkingHabitVC {
    
//MARK: - Button Actions
    
    @IBAction func yesBtnAction() {
        
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

        print("the Yes Button in My Drinking Habit API call params", params)
        
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
    
    @IBAction func nextBtnAction() {
         
        if selectedRowIndex == 0 {
            
            let backItem = UIBarButtonItem()
            backItem.title = "" // Set an empty string for the back button
            self.navigationItem.backBarButtonItem = backItem
            
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "ModerateDrinkingVC") as? ModerateDrinkingVC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            vc?.sectionID = sectionID6
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if selectedRowIndex == 1 {
            
            let backItem = UIBarButtonItem()
            backItem.title = "" // Set an empty string for the back button
            self.navigationItem.backBarButtonItem = backItem
            
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "Modarate2VC") as? Modarate2VC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            vc?.sectionID = sectionID6
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if selectedRowIndex == 2 {
            
            let backItem = UIBarButtonItem()
            backItem.title = "" // Set an empty string for the back button
            self.navigationItem.backBarButtonItem = backItem
            
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "Modarate3VC") as? Modarate3VC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            vc?.sectionID = sectionID6
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if selectedRowIndex == 3 {
            
            let backItem = UIBarButtonItem()
            backItem.title = "" // Set an empty string for the back button
            self.navigationItem.backBarButtonItem = backItem
            
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "Modarate4VC") as? Modarate4VC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            vc?.sectionID = sectionID6
            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
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
        }

        
    }
}
