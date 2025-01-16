//
//  Discovery.swift
//  CalmscientIOS
//
//  Created by mac on 19/05/24.
//

import Foundation
import UIKit
@available(iOS 16.0, *)
class Discovery: ViewController,UITableViewDelegate,UITableViewDataSource {
    
    private var takingControlResponse:TakingControlIndexResponse?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var customSegmentedControl: CustomSegmentedControl!

    var courseLists: [[String: Any]] = []
    var index: [[String: Any]] = []
   
    var button_name = ["Basic knowledge","Make a plan","Summary","Drink tracker", "Event tracker","Watch tutorial again"]
    override func viewDidLoad() {
        
        super.viewDidLoad()
       // self.view.showToastActivity()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationItem.leftBarButtonItem?.isHidden = false
        tableView.register(UINib(nibName: "AlcholFreeCell", bundle: nil), forCellReuseIdentifier: "AlcholFreeCell")
        tableView.register(UINib(nibName: "CustomCheckboxCell", bundle: nil), forCellReuseIdentifier: "CustomCheckboxCell")
        tableView.register(UINib(nibName: "ResourceCell", bundle: nil), forCellReuseIdentifier: "ResourceCell")
        tableView.register(UINib(nibName: "CustomButton", bundle: nil), forCellReuseIdentifier: "CustomButton")
        
        tableView.register(CustomHeaderView.self, forHeaderFooterViewReuseIdentifier: "CustomHeaderView")

        customSegmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        customSegmentedControl.setupLabels()
        updateView()
//        self.navigationController?.isNavigationBarHidden = false
        

        //nav bar back button start
        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)

        // Create a UIButton
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonOverrideAction), for: .touchUpInside)

        // Set constraints to adjust the size
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 26).isActive = true // Set desired width
        backButton.heightAnchor.constraint(equalToConstant: 26).isActive = true // Set desired height

        // Create a UIBarButtonItem using the UIButton
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        //end

    }
    
    override func viewDidAppear(_ animated: Bool) {
        customSegmentedControl.setupLabels()
    }
    
    @objc func backButtonOverrideAction() {
        print("Back button tapped")
        // Perform the action you want here
        let vcz = UIStoryboard(name: "DiscoveryMainDashboard", bundle: nil).instantiateViewController(withIdentifier: "DiscoveryMainViewController") as! DiscoveryMainViewController

        self.navigationController?.pushViewController(vcz, animated: true)

        
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
            
        }
        
       self.tableView.showToastActivity()
        getAlcoholDrinks(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            print("courseLists==\(json)")
                            self.tableView.hideToastActivity()
                            self.courseLists = json["courseLists"] as! [[String : Any]]
                            self.index = json["index"] as! [[String : Any]]
                            print(index)
                            let skipTutorialFlag = self.courseLists[5]["skipTutorialFlag"]
                            print("skipTutorialFlag===\(skipTutorialFlag ?? "")")
                           
                            tableView.dataSource = self
                            tableView.delegate = self
                            self.tableView.reloadData()
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
        customSegmentedControl.setupLabels()
        tableView.reloadData()
        self.title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "Taking control" : "Tomando el control"
       // self.view.showToastActivity()
    }
    
    @objc func segmentChanged(_ sender: CustomSegmentedControl) {
        if sender.selectedIndex == 0 {
            
        }
        updateView()
    }
    @objc func clicked(_ sender: UIButton) {
        
    }
    func updateView() {

    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2: return courseLists.count
        case 3: return 1
        case 4: return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlcholFreeCell", for: indexPath) as! AlcholFreeCell
                    cell.leftBox.layer.cornerRadius = 10
                    cell.leftTitle.text = AppHelper.getLocalizeString(str: "Now")

                    let sectionData = index[indexPath.section]
                    if let nowValue = sectionData["now"] as? Int {
                        
                        cell.leftValue.text = "\(nowValue) \(AppHelper.getLocalizeString(str: "days"))"
                    } else {
                        
                        cell.leftValue.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "0 days" :"0 Días"
                    }
           
                    cell.rightTitle.text =  AppHelper.getLocalizeString(str: "Monthly goal")
                    if let goalValue = sectionData["goal"] as? Int {
                        
                        cell.rightValue.text = "\(goalValue) \(AppHelper.getLocalizeString(str: "days"))"
                    } else {
                        cell.rightValue.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "0 days" :"0 Días"
                    }

                    cell.rightBox.layer.cornerRadius = 10
                    cell.selectionStyle = .none
                    return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AlcholFreeCell", for: indexPath) as! AlcholFreeCell
                    cell.leftBox.layer.cornerRadius = 10
                    cell.leftTitle.text = AppHelper.getLocalizeString(str: "Now")

                    let sectionData = index[indexPath.section]
                    if let nowValue = sectionData["now"] as? Int {
                        
                        cell.leftValue.text = "\(nowValue) \(UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "counts" :"conteos")"
                        
                    } else {
                        cell.leftValue.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "0 counts" : "0 conteos"
                    }
           
                    cell.rightTitle.text =  AppHelper.getLocalizeString(str: "Monthly goal")
                    if let goalValue = sectionData["goal"] as? Int {
                        
                        cell.rightValue.text = "\(goalValue) \(UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "counts" :"conteos")"
                    } else {
                        cell.rightValue.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "0 counts" : "0 conteos"
                    }

                    cell.rightBox.layer.cornerRadius = 10
                    cell.selectionStyle = .none
                    return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCheckboxCell", for: indexPath) as! CustomCheckboxCell
            cell.selectionStyle = .none
            let course = courseLists[indexPath.row]
            
            cell.customLabel.text = "   \(course["courseName"] ?? "")"
            
//            if course["isEnable"] as! Int == 1 {
//                cell.enableButton()
//            } else {
//                cell.disableButton()
//            }
        
            
           // let imageName = course["isEnable"] as! Int  == 1 ? "check" : "uncheck_circle"
            //       cell.checkBox.setImage(UIImage(named: imageName), for: .normal)
            
//            cell.main_view.layer.borderWidth = 2
//            cell.main_view.layer.borderColor = UIColor(named: "AppBorderColor")?.cgColor
//            cell.main_view.layer.cornerRadius = cell.main_view.frame.height / 3.5
//            cell.main_view.layer.masksToBounds = true

            let isEnable = course["isEnable"] as? Int
            if isEnable == 1 {
                cell.main_view.layer.borderWidth = 2
                cell.main_view.layer.borderColor = UIColor(named: "AppBorderColor")?.cgColor
              //  cell.main_view.layer.cornerRadius = cell.main_view.frame.height / 3.5
                cell.main_view.layer.masksToBounds = true
                cell.customLabel.textColor =  UIColor(named: "AppBorderColor")
                cell.isUserInteractionEnabled = true
                cell.main_view.alpha = 1
               
            } else {
               // cell.checkBox.isEnabled = true // Hide if `isCompleted` is not found or not an Int
                cell.main_view.layer.borderWidth = 2
                cell.main_view.layer.borderColor = UIColor(named: "AppLightTextColor")?.cgColor
                cell.customLabel.textColor =  UIColor(named: "AppLightTextColor")
                //cell.main_view.layer.cornerRadius = cell.main_view.frame.height / 3.5
                cell.main_view.layer.masksToBounds = true
                cell.isUserInteractionEnabled = false
                cell.main_view.alpha = 0.3
            }
            
            
            let isCompleted = course["isCompleted"] as? Int
            if isCompleted == 1 {
                cell.checkBox.isHidden = false // Hide if not completed
            } else {
                cell.checkBox.isHidden = true // Hide if `isCompleted` is not found or not an Int
            }

           cell.separatorInset = .zero
            //                cell.buttons.addTarget(self, action: #selector(self.clicked(_:)), for: .touchUpInside)
            // Configure the cell as needed
            
            
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCell", for: indexPath) as! ResourceCell
            cell.selectionStyle = .none
            cell.videoImageView.image = UIImage(named: "Mask", in: nil, with: nil)
            cell.headLable.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?   "Work your strengths" : "Aprovecha tus fortalezas"
            cell.resourcesLbl.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Resources" : "Recursos"
                   
            cell.descriptionLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?   "Do something you're good at to build self-confidence, then tackle a tougher task." : "Haz algo en lo que seas bueno para aumentar tu autoconfianza, y luego enfrenta una tarea más difícil."
            // Configure the cell as needed
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CustomButton", for: indexPath) as! CustomButton
            cell.selectionStyle = .none
            cell.button.setTitle(AppHelper.getLocalizeString(str:"Need to talk with someone?"), for: .normal)
            cell.button.titleLabel?.font =  UIFont(name: Fonts().lexendMedium, size: 18)

            cell.button.addTarget(self, action: #selector(Discovery.needToTalkButtonClicked(_:)), for: .touchUpInside)
            return cell
        default:
            return UITableViewCell()
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 || section == 4 || section == 4 {
            return nil // Hide headers for sections 2 and 3
        }
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CustomHeaderView") as! CustomHeaderView
        
        switch section {
        case 0:
            header.setText(UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Alcohol free days" : "Días sin alcohol.")
        case 1:
            header.setText(UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Drink Counts" : "Conteo de bebidas.")
        default:
            header.setText("")
        }
        return header
    }
    
    // Set the height for the header
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 || section == 4 || section == 3  {
            return 0 // Hide headers for sections 2 and 3
        }
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 2:
            return 70 // 7 buttons * 45 height + spacing
        case 4:
            return 60 // Adjust the height as needed
        default:
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 2){
//            guard let course = courseLists[indexPath.row] else {
//                return
//            }
            let course = courseLists[indexPath.row]["courseId"]
            let courseName = courseLists[indexPath.row]["courseName"]
            print(course!)
            print(courseName!)
            
            //Basic knowledge id == 10
            if(course as! Int == 3){
                let next = UIStoryboard(name: "Basicknowledge", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "Basicknowledge") as? Basicknowledge
                vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
                self.navigationController?.pushViewController(vc!, animated: true)
            } else if (course as! Int == 5) {
                let next = UIStoryboard(name: "SummaryViewController", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "SummaryViewController") as? SummaryViewController
                vc?.title = AppHelper.getLocalizeString(str: "Summary")
                self.navigationController?.pushViewController(vc!, animated: true)
            } else if (course as! Int == 6) {
                let next = UIStoryboard(name: "DrinksTrackerViewController", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "DrinksTrackerViewController") as? DrinksTrackerViewController
                vc?.title = AppHelper.getLocalizeString(str: "Drink tracker")
               
                self.navigationController?.pushViewController(vc!, animated: true)
            } else if (course as! Int == 7) {
                let next = UIStoryboard(name: "EventsTrackersViewController", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "EventsTrackersViewController") as? EventsTrackersViewController
                vc?.title =  AppHelper.getLocalizeString(str: "Events tracker")
                self.navigationController?.pushViewController(vc!, animated: true)
            } else if (course as! Int == 1) {
                    let next = UIStoryboard(name: "TakingControllIntro", bundle: nil)
                    let vc = next.instantiateViewController(withIdentifier: "TakingControllIntro") as? TakingControllIntro
                    vc?.title = AppHelper.getLocalizeString(str: "Taking control introduction")
                    self.navigationController?.pushViewController(vc!, animated: true)
            }
            else if (course as! Int == 4) {
                let next = UIStoryboard(name: "MakePlan", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "MakePlan") as? MakePlan
                vc?.title =  AppHelper.getLocalizeString(str: "Make a plan")
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            else if (course as! Int == 2) {
                let next = UIStoryboard(name: "HowToUseViewController", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "HowToUseViewController") as? HowToUseViewController
                vc?.title =  AppHelper.getLocalizeString(str: "How to use")
                self.navigationController?.pushViewController(vc!, animated: true)
            }
        }
    }
    @objc func needToTalkButtonClicked(_ sender: UIButton) {
        let next = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController
                vc?.title = "Emergency resource"
                self.navigationController?.pushViewController(vc!, animated: true)
        }
    fileprivate func getTakingControlIndexResponse() {
        self.view.showToastActivity()
        var prepareRequestBodyParams:[String:Any] = [:]
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            return
        }
        
        prepareRequestBodyParams["patientId"] = loginResponse.patientID
        prepareRequestBodyParams["clientId"] = loginResponse.clientID
        prepareRequestBodyParams["plId"] = loginResponse.patientLocationID
        
        let questonariesRequest = TakingControlIndexRequestForm(prepareRequestBodyParams)
        guard let requestURL = questonariesRequest.getURLRequest() else {
            self.view.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }
        NetworkAPIRequest.sendRequest(request: requestURL) { [weak self](response: TakingControlIndexResponse?, failureResponse: FailureResponse?, error: Error?) in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.view.hideToastActivity()
                if let _ = error {
                    self.view.showToast(message: "An Unknown error occured. Please check with Admin")
                } else if let response = response {
                    self.takingControlResponse = response
                    self.tableView.reloadData()
                } else if let failureResponse = failureResponse {
                    self.view.showToast(message: failureResponse.statusResponse.responseMessage)
                    print(("failureResponse===\(failureResponse.statusResponse.responseMessage)"))
                }
            }
        }
    }
    func getAlcoholDrinks(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL

        guard let url = URL(string: "\(baseURLString)patients/api/v1/takingControl/getTakingControlIndex") else {
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
            "plId": plId,
            "patientId": patientId,
            "clientId": clientId,
          
        ]
        print("payload==\(payload)")
   
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
               // print("Response JSON: \(jsonResponse)")
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



