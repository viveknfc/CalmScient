//
//  UserIntroDayFeedbackViewController.swift
//  HealthApp
//
//  Created by KA on 26/02/24.
//

import UIKit
import SwiftyJSON

enum UserEntryDayFeedbackTableCell:String {
    case UserMoodHoursCell = "UserMoodHoursCell"
    case UserIntroSleepCell = "UserIntroSleepCell"
    case UserEntryTimeSpendCell = "UserEntryTimeSpendCell"
    case UserEntryMedicineCell = "UserEntryMedicineCell"
    case UserEntryJournalCell = "UserEntryJournalCell"
    
    func getCellIdentifier() -> String {
        switch self {
        case .UserMoodHoursCell, .UserEntryTimeSpendCell:
            return "UserIntroSelectionTableCell"
        case .UserIntroSleepCell:
            return "UserEntrySleepHoursCell"
        case .UserEntryMedicineCell, .UserEntryJournalCell:
            return "UserEntryYesOrNoCell"
        }
    }
    
    func getCellHeight() -> CGFloat {
        switch self {
        case .UserMoodHoursCell:
            return 170
        case .UserIntroSleepCell:
            return 120
        case .UserEntryTimeSpendCell:
            return 160
        case .UserEntryMedicineCell:
            return 140
        case .UserEntryJournalCell:
            return 180
        }
    }
}

@available(iOS 16.0, *)
@available(iOS 16.0, *)
class UserIntroDayFeedbackViewController: ViewController {

    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var savebutton: LinearGradientButton!
    @IBOutlet weak var skipButton: BorderShadowButton!
    @IBOutlet weak var feedbackTableView: UITableView!
    var afternoonVC = false
    var titleString = UserDefaults.standard.string(forKey: "titleString") ?? "V"
    
    private let GoodMorningTitle = "Good morning!"
    private let GoodAfternoonTitle = "Good afternoon!"
    private let GoodEveningTitle = "Good evening!"
    
    private let userDayWiseData:UserStartupScreenDayData? = UserStartupScreenDayData.getStartUpScreenData()
    
    var object: JSON = JSON.null
    var selectedCell: Int?
    var slpHours: String?
    var mediTaken: String?
    var journalText: String?
    
    
    fileprivate var cellData:[UserEntryDayFeedbackTableCell] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        savebutton.cornerRadius = (skipButton.frame.size.height / 2) - 1
        self.navigationController?.isNavigationBarHidden = true
        savebutton.setAttributedTitleWithGradientDefaults(title: "Save")
        skipButton.cornerRadius = (skipButton.frame.size.height / 2) - 1
        skipButton.setAttributedTitleWithGradientDefaults(title: "Skip")
        screenTitleLabel.font = UIFont(name: Fonts().lexendMedium, size: 20)
        feedbackTableView.register(UINib(nibName: "UserIntroSelectionTableCell", bundle: nil), forCellReuseIdentifier: "UserIntroSelectionTableCell")
        feedbackTableView.register(UINib(nibName: "UserEntryYesOrNoCell", bundle: nil), forCellReuseIdentifier: "UserEntryYesOrNoCell")
        feedbackTableView.register(UINib(nibName: "UserEntrySleepHoursCell", bundle: nil), forCellReuseIdentifier: "UserEntrySleepHoursCell")
        feedbackTableView.dataSource = self
        feedbackTableView.delegate = self
        feedbackTableView.separatorStyle = .none
        skipButton.layer.borderWidth = 2
        skipButton.layer.borderColor = UIColor(named: "AppThemeColor")?.cgColor
        skipButton.layer.masksToBounds = true
        skipButton.layer.cornerRadius = skipButton.frame.height/2 - 2
        cellData = prepareCellData()
        if let dayTimeValue = userDayWiseData?.dayTimeValue {
            switch dayTimeValue {
            case .Morning, .Afternoon:
                let morningGreet = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Hello" : "Hola"
                self.screenTitleLabel.text = "\(morningGreet) \(titleString)!"//AppHelper.getLocalizeString(str: GoodMorningTitle)
//            case .Afternoon:
//                self.screenTitleLabel.text = AppHelper.getLocalizeString(str: GoodAfternoonTitle)
            case .Evening:
                let eveGreet = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Good evening" : "¡Buenas noches"
                self.screenTitleLabel.text = "\(eveGreet) \(titleString)!"//AppHelper.getLocalizeString(str: GoodEveningTitle)
            }
        }
        
        if (UserDefaults.standard.value(forKey: "rememberMe") as? Int == 1) {
            refreshAPIFunc()
        }
        
        
       
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
        fetchAPIFunc()
    }
    
    //MARK: - Fetch Mood Screen Data from API
    
    func fetchAPIFunc() {
        let params:[String:Any] = ["patientLocationId": 4, "clientId": 1, "patientId": 4, "time": "2025-01-17 12:02"]
        print("the input param for fetch api is", params)
        self.view.showToastActivity()
        APIService.FetchMoodScreenDataAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") {  [self] response in
            // Your closure code here
            getresponseforFetchMoodDataAPI(response: response)
            
        }
    }
    
    //MARK: - Fetch API Response
    
    func getresponseforFetchMoodDataAPI(response:AnyObject)->() {
        
        self.view.hideToastActivity()
        if let responseString = response as? String {
            print("Response received from Fetch API calling is", responseString)
        }
        else if let responseDict = response as? [String: Any] {
            
            do {
                let responseData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                let loginResponse = try JSONDecoder().decode(UserStartupScreenDayData.self, from: responseData)
                
                print("the fetch API response is",loginResponse.startupAnswersDtoList?[0].activityResponse ?? "")
                selectedCell = 1
                slpHours = loginResponse.startupAnswersDtoList?[1].activityResponse ?? "0"
                mediTaken = loginResponse.startupAnswersDtoList?[2].activityResponse ?? "0"
                journalText = loginResponse.startupAnswersDtoList?[3].activityResponse ?? "NA"
                
                feedbackTableView.reloadData()
            }
            catch {
               print("Failed to decode UserStartupScreenDayData:", error)
           }
 
            
        }
        else {
            print("Unsupported response type:", type(of: response))
        }
        
    }
    
    //END
    
    
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
                
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
               
            }
        
        skipButton.setAttributedTitleWithGradientDefaults(title: AppHelper.getLocalizeString(str: "Skip"))
        savebutton.setAttributedTitleWithGradientDefaults(title: AppHelper.getLocalizeString(str: "Save"))
        
        }
    private func prepareCellData() -> [UserEntryDayFeedbackTableCell] {
        guard let userDayWiseData = self.userDayWiseData, let dayTime = userDayWiseData.dayTimeValue else {
            return []
        }
        switch dayTime {
        case .Morning, .Afternoon:
            return [.UserMoodHoursCell,.UserIntroSleepCell,.UserEntryMedicineCell, .UserEntryJournalCell]
//        case .Afternoon:
//            return [.UserMoodHoursCell]
        case .Evening:
//            return [.UserMoodHoursCell,.UserIntroSleepCell,.UserEntryMedicineCell, .UserEntryJournalCell]
            return [.UserMoodHoursCell,.UserEntryTimeSpendCell,.UserEntryMedicineCell,.UserEntryJournalCell]
        }
    }
    
    @IBAction func didClickOnSaveButton(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let userDayWiseData = self.userDayWiseData, let dayTime = userDayWiseData.dayTimeValue else {
            return
        }
        let answers = PatientLog()
        switch dayTime {
        case .Morning, .Afternoon:
            answers.moodId = userDayWiseData.moodAnswer ?? 5
            answers.sleepHours = userDayWiseData.sleepAnswer ?? 8
            answers.medicineFlag = Int(userDayWiseData.sleepAnswer ?? 0)
            answers.journal = userDayWiseData.journalAnswer ?? ""
//        case .Afternoon:
//            answers.moodId = userDayWiseData.moodAnswer ?? 5
        case .Evening:
            answers.moodId = userDayWiseData.moodAnswer ?? 5
            answers.sleepHours = userDayWiseData.sleepAnswer ?? 8
            answers.medicineFlag = Int(userDayWiseData.sleepAnswer ?? 0)
            answers.spendTime = userDayWiseData.timeSpendAnswer ?? ""
            answers.journal = userDayWiseData.journalAnswer ?? ""
        }
        
        self.view.showToastActivity()
        guard let requestForm = SaveUserStartupScreenDetailsRequestForm(answers) else {
            self.view.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }
        guard let requestURL = requestForm.getURLRequest() else {
            self.view.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }
        NetworkAPIRequest.sendRequest(request: requestURL) { [weak self](response: ResponseDetails?, failureResponse: FailureResponse?, error: Error?) in
            DispatchQueue.main.async {
                self?.view.hideToastActivity()
                guard let self = self else {
                    return
                }
                if let err = error {
                    self.view.showToast(message: err.localizedDescription)
                } else if let response = response {
                    if response.responseCode == 200 {
                        
                        self.showSuccessAlert() {
                            print("alert shown")
                               if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                   guard let window = sceneDelegate.window else { return }
                                   let homeController = UIStoryboard(name: "AppTabBar", bundle: nil).instantiateViewController(withIdentifier: "AppMainTabViewController") as! AppMainTabViewController
                                   window.rootViewController = homeController
                                   window.makeKeyAndVisible()
                               }
                           }
                        
                    } else {
                        self.view.showToast(message: response.responseMessage)
                    }
                } else if let failureResponse = failureResponse {
                    self.view.showToast(message: failureResponse.statusResponse.responseMessage)
                }
            }
        }
    }
    
    //MARK: - Refresh Token API Call
    
    func refreshAPIFunc() {
        let params:[String:String] = ["refreshToken": ApplicationSharedInfo.shared.tokenResponse?.refreshToken ?? ""]
        print("the input param for refresh token is", params)
        self.view.showToastActivity()
        APIService.refreshAPICalling(self, params: params, method: "POST", accessToken: "", acces: false, parameterPlacement: "header") {  [self] response in
            // Your closure code here
            getresponseforRefreshAPI(response: response)
            
        }
    }
    
    func getresponseforRefreshAPI(response:AnyObject)->() {
        self.view.hideToastActivity()
        if let responseString = response as? String {
            print("Response received from refresh API calling is", responseString)
        } else if let responseDict = response as? [String: Any] {
            do {
                // Convert the dictionary to Data
                let responseData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                
                // Decode the Data into LoginResponse
                let loginResponse = try JSONDecoder().decode(TokenResponse.self, from: responseData)
                print("Decoded LoginResponse:", loginResponse.scope)
                
                // Store token response
                ApplicationSharedInfo.shared.tokenResponse = loginResponse
            } catch {
                print("Failed to decode LoginResponse:", error)
            }
        } else {
            print("Unsupported response type:", type(of: response))
        }
    }
    
    //MARK: - Save Alert View
    
    func showSuccessAlert(completion: @escaping () -> Void) {
        // Create a semi-transparent background view
        let backgroundView = UIView(frame: self.view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add the background view to the main view
        self.view.addSubview(backgroundView)
        
        // Create the alert view
        let successAlert = SuccessAlertView()
        successAlert.translatesAutoresizingMaskIntoConstraints = false
        successAlert.okButtonAction = {
            backgroundView.removeFromSuperview() // Remove the background view
            successAlert.removeFromSuperview()  // Remove the alert view
            completion()
        }
        
        // Add the alert view to the background view
        backgroundView.addSubview(successAlert)
        
        // Set Auto Layout constraints for the alert view
        NSLayoutConstraint.activate([
            successAlert.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
            successAlert.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
            successAlert.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            successAlert.heightAnchor.constraint(equalToConstant: 300)
        ])
    }

    
    @IBAction func didClickOnSkipButton(_ sender: BorderShadowButton) {
        
        let isFirstTime = !UserDefaults.standard.bool(forKey: "hasSkippedBefore")
        
        if let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate {
            guard let window = sceneDelegate.window else { return }
            let homeController = UIStoryboard(name: "AppTabBar", bundle: nil).instantiateViewController(withIdentifier: "AppMainTabViewController") as! AppMainTabViewController

            homeController.isInitalView = isFirstTime
            UserDefaults.standard.set(true, forKey: "hasSkippedBefore")
 
            window.rootViewController = homeController
            window.makeKeyAndVisible()
        }

    }
    
}

@available(iOS 16.0, *)
extension UserIntroDayFeedbackViewController : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cellData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let userDayWiseData = self.userDayWiseData else {
            return UITableViewCell()
        }
        let cellType = cellData[indexPath.row]
        switch cellType {
        case .UserMoodHoursCell, .UserEntryTimeSpendCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.getCellIdentifier(), for: indexPath) as? UserIntroSelectionTableCell else {
                return UITableViewCell()
            }
            cell.selectedIndex = selectedCell ?? 0
            cell.updateUIWithCellInstance(instance: userDayWiseData, cellType: cellType)
        
        case .UserIntroSleepCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.getCellIdentifier(), for: indexPath) as? UserEntrySleepHoursCell else {
                return UITableViewCell()
            }
            if let slpHours = slpHours, !slpHours.isEmpty {
                cell.selectedIndex = Int(slpHours)!
            }
            cell.updateUIWithCellInstance(instance: userDayWiseData, cellType: cellType)
        case .UserEntryMedicineCell, .UserEntryJournalCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.getCellIdentifier(), for: indexPath) as? UserEntryYesOrNoCell else {
                return UITableViewCell()
            }
            if let mediTaken = mediTaken, !mediTaken.isEmpty {
                cell.toggleImageView.tag = -1
            }
            if let journalText = journalText, !journalText.isEmpty {
                cell.journalTextView.text = journalText
            }
            cell.updateUIWithCellInstance(instance: userDayWiseData, cellType: cellType)
            cell.configureJournalView(isJournalView: cellType == .UserEntryJournalCell)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = cellData[indexPath.row]
        return cellType.getCellHeight()
    }
    
   
    
}
