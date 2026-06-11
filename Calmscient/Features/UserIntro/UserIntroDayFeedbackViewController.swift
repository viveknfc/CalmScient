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
            return 160
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
    var hideSkipButton: Bool = false
  
    @IBOutlet weak var skipButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var saveButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var mainTableTop: NSLayoutConstraint!
    
    
    @IBOutlet weak var feedbackTableView: UITableView!
    var afternoonVC = false
    var titleString = UserDefaults.standard.string(forKey: "titleString") ?? "V"
    
    private let GoodMorningTitle = "Good morning!"
    private let GoodAfternoonTitle = "Good afternoon!"
    private let GoodEveningTitle = "Good evening!"
    
    var GreetingTitle: String?
    var alertText: String?
    
    private let userDayWiseData:UserStartupScreenDayData? = UserStartupScreenDayData.getStartUpScreenData()
    
    var object: JSON = JSON.null

    var slpHours: String?
    var mediTaken: String?
    var journalText: String?
    
    var isJournalClearedByUser = false
    
    var SpendTime1: [Int]?{
        didSet {
            feedbackTableView.reloadData()
        }
    }
    
    var selectedCell: Int? {
        didSet {
            feedbackTableView.reloadData()
        }
    }


    
    var plId: Int = ApplicationSharedInfo.shared.loginResponse?.patientLocationID ?? 0
    var clientId: Int = ApplicationSharedInfo.shared.loginResponse?.clientID ?? 0
    var patientId: Int = ApplicationSharedInfo.shared.loginResponse?.patientID ?? 0
    var currentTime: String?
  
    fileprivate var cellData:[UserEntryDayFeedbackTableCell] = []
    
    let sleepData = ["3","4","5","6","7","8","9","10","11"]
    let spendOptions = ["FAMILY", "FRIENDS", "WORKMATES", "OTHERS", "ALONE"]
    
    var medicineFlagString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        skipButton.isHidden = hideSkipButton
        if hideSkipButton {
            skipButtonHeight.constant = 0
            saveButtonBottom.constant = 0
        } else {
            skipButtonHeight.constant = 45
            saveButtonBottom.constant = 16
        }
        
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
                let morningGreet = "Hello".localized
                GreetingTitle = "\(morningGreet) \(titleString)!"
            case .Evening:
                let eveGreet = "Good evening".localized
                GreetingTitle = "\(eveGreet) \(titleString)!"
            }
        }
        
        alertText = "Please fill all mandatory fields.".localized
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Allow table view cell selection
        view.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
       
        self.screenTitleLabel.text = GreetingTitle
        self.screenTitleLabel.isHidden = false
        mainTableTop.constant = 24
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        let sampleTime = Date()
        print("the fetching time in local is ", sampleTime)

        fetchDateTime() //for userintro in scene delegate

        currentTime = DayFeedbackSessionLogic.apiTimestamp(from: sampleTime)
        setupLanguage()
        
        if TokenManager.shared.isTokenExpired() {
             print("Token expired, refreshing...")
            TokenManager.shared.refreshAccessToken(from: self) { success in
                 DispatchQueue.main.async {
                     if success {
                         print("Token refreshed, proceeding with API call")
                         self.fetchAPIFunc()
                     } else {
                         print("Token refresh failed")
//                         self.view.showToast(message: "Token refresh failed")
                         // Handle failure (e.g., logout user, show alert)
                         
                         UserDefaults.standard.set(0, forKey: "rememberMe")
                         
                         UserDefaultsHelper.clearLoginDetailsFromUserDefaults()
                         ApplicationSharedInfo.shared.loginResponse = nil
                         ApplicationSharedInfo.shared.tokenResponse = nil

                             if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                 if #available(iOS 16.0, *) {
                                     let navController = LoginHostingController.loginNavigationRoot()
                                     sceneDelegate.changeRootViewController(to: navController)
                                 }
                             }

                         
                     }
                 }
             }
         } else {
             print("Token is still valid, proceeding with API call")
             fetchAPIFunc()
         }

        
        // Check if we are coming from the home dashboard
          if let viewControllers = self.navigationController?.viewControllers, viewControllers.count > 1 {
              let previous = viewControllers[viewControllers.count - 2]
              var fromHomeDashboard = previous is HomeTabDashboardViewController
              if #available(iOS 16.0, *) {
                  fromHomeDashboard = fromHomeDashboard || previous is HomeDashboardHostingController
              }
              if fromHomeDashboard {
                  // If the previous view controller is the HomeDashboard, show the navigation bar
                  self.navigationController?.isNavigationBarHidden = false
                  title = GreetingTitle
                  self.screenTitleLabel.isHidden = true
                  mainTableTop.constant = -18
              } else {
                  self.screenTitleLabel.isHidden = false
                  self.screenTitleLabel.text = GreetingTitle
                  mainTableTop.constant = 24
              }
          }
        else {
                // Default case: show the label and set its text
                self.screenTitleLabel.isHidden = false
                self.screenTitleLabel.text = GreetingTitle
                mainTableTop.constant = 24
            }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DayFeedbackEveningReminderScheduler.cancelEveningReminder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Make sure to reset the navigation bar visibility when leaving this view controller
        // This is especially important if you want to ensure the state is consistent when navigating back
        self.navigationController?.isNavigationBarHidden = true
        DayFeedbackEveningReminderScheduler.refreshSchedulingIfNeeded()
    }
    
    //MARK: - For Journal Text View
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        // Calculate the visible area
        let keyboardHeight = keyboardFrame.height
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        feedbackTableView.contentInset = contentInset
        feedbackTableView.scrollIndicatorInsets = contentInset

        if let activeTextView = view.findFirstResponder() as? UITextView {
              if let cell = activeTextView.findSuperview(ofType: UITableViewCell.self),
                 let indexPath = feedbackTableView.indexPath(for: cell) {
                  // Calculate the position to ensure the text view is just above the keyboard
                  let rect = feedbackTableView.rectForRow(at: indexPath)
                  let visibleHeight = feedbackTableView.frame.height - keyboardHeight
                  let targetOffset = rect.origin.y - visibleHeight //+ rect.height + 10 // Adjust offset for padding
                  
                  if feedbackTableView.contentOffset.y < targetOffset {
                      feedbackTableView.setContentOffset(CGPoint(x: 0, y: targetOffset), animated: true)
                  }
              }
          }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        feedbackTableView.contentInset = .zero
        feedbackTableView.scrollIndicatorInsets = .zero
    }

    
    //MARK: - Fetch Mood Screen Data from API
    
    func fetchAPIFunc() {
        
        let params:[String:Any] = ["patientLocationId": plId, "clientId": clientId, "patientId": patientId, "time": currentTime!]
        print("the input param for fetch api is", params)
        feedbackTableView.showToastActivity()
        APIService.FetchMoodScreenDataAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse?.accessToken ?? "", acces: false, parameterPlacement: "body") {  [self] response in
            // Your closure code here
            getresponseforFetchMoodDataAPI(response: response) {
                self.feedbackTableView.hideToastActivity()
            }
            
        }
    }
    
    //MARK: - Fetch API Response
    
    func getresponseforFetchMoodDataAPI(response:AnyObject, completion: @escaping () -> Void) {
        
        if let responseString = response as? String {
            print("Response received from Fetch API calling is", responseString)
            
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Error",
                                                        message: "Failed to fetch data. Would you like to retry?",
                                                        preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
                    self.viewWillAppear(true)
                }))
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                self.present(alertController, animated: true)
            }
            
        }
        else if let responseDict = response as? [String: Any] {
            
            do {
                let responseData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                let loginResponse = try JSONDecoder().decode(UserStartupScreenDayData.self, from: responseData)

                if let answersList = loginResponse.startupAnswersDtoList, !answersList.isEmpty {
                    print("data not empty")
                    
                    for answer in answersList {
                          switch answer.activitySection {
                          case "Mood Monitor":
                              selectedCell = (Int(answer.activityResponse?.first ?? "-1") ?? 0) - 1
                          case "Sleep Hours":
//                              slpHours = String((Int(answer.activityResponse) ?? 0) - 1)
                              
                              if let index = sleepData.firstIndex(of: answer.activityResponse?.first ?? "-1") {
                                  slpHours = String(index)
                              } else {
                                  slpHours = "0" // Default value if not found
                              }
                              
                          case "Medication":
                              mediTaken = answer.activityResponse?.first
                          case "Journal":
                              journalText = answer.activityResponse?.first
                          case "SpendTime":
                              let fetchedAnswers: [String] = answer.activityResponse?.compactMap { String($0) } ?? []
                              SpendTime1 = fetchedAnswers.compactMap { spendOptions.firstIndex(of: $0).map { $0 + 1 } }//answer.activityResponse?.compactMap { Int($0) }
                              print("the fetching answers for time spend is :\(String(describing: SpendTime1))")
                          default:
                              break
                          }
                      }
                                            
                } else {
                    print("data empty")
                }

            }
            catch {
               print("Failed to decode UserStartupScreenDayData:", error)
           }
 
            DispatchQueue.main.async {
                self.feedbackTableView.reloadData()
            }
            
        }
        else {
            print("Unsupported response type:", type(of: response))
        }
        
        completion()

    }
    
    //END
    
    
    func setupLanguage() {
        
        skipButton.setAttributedTitleWithGradientDefaults(title: AppHelper.getLocalizeString(str: "Skip"))
        savebutton.setAttributedTitleWithGradientDefaults(title: AppHelper.getLocalizeString(str: "Save"))
        
        }
    private func prepareCellData() -> [UserEntryDayFeedbackTableCell] {
        guard let userDayWiseData = self.userDayWiseData, let dayTime = userDayWiseData.dayTimeValue else {
            return []
        }
        switch dayTime {
        case .Morning, .Afternoon:
            UserDefaults.standard.set(true, forKey: "Morning")
//            return [.UserMoodHoursCell,.UserEntryTimeSpendCell,.UserEntryMedicineCell,.UserEntryJournalCell]
            return [.UserMoodHoursCell,.UserIntroSleepCell,.UserEntryMedicineCell, .UserEntryJournalCell]
//        case .Afternoon:
//            return [.UserMoodHoursCell]
        case .Evening:
            UserDefaults.standard.set(false, forKey: "Morning")
//            return [.UserMoodHoursCell,.UserIntroSleepCell,.UserEntryMedicineCell, .UserEntryJournalCell]
            return [.UserMoodHoursCell,.UserEntryTimeSpendCell,.UserEntryMedicineCell,.UserEntryJournalCell]
        }
    }
    
    @IBAction func didClickOnSaveButton(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let userDayWiseData = self.userDayWiseData, let dayTime = userDayWiseData.dayTimeValue else {
            return
        }
        
        for cell in feedbackTableView.visibleCells {
            
            if let cell = cell as? UserIntroSelectionTableCell {
                        userDayWiseData.moodAnswer =  cell.getUpdatedData4MoodId()
                        userDayWiseData.timeSpendAnswer = cell.getUpdatedData4SpendHours1()
                    } else if let cell = cell as? UserEntrySleepHoursCell {
                        let updatedSleepHours = cell.getUpdatedData() ?? 1
                        print("the updatedSleepHours is", updatedSleepHours)

                        if updatedSleepHours > 0 && updatedSleepHours <= sleepData.count {
                            let sleepAns = sleepData[updatedSleepHours - 1]
                            userDayWiseData.sleepAnswer = Int(sleepAns)
                        } 
                        else if updatedSleepHours <= 0 || updatedSleepHours > sleepData.count {
                            showGeneralAlert(
                                image: UIImage(named: "InfoIcon"),
                                imageSize: CGSize(width: 60, height: 60),
                                title: alertText ?? "",
                                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                                okAction: {},
                                dismissAction: {}
                            )
                            return
                        }

                        
                        
                    } else if let cell = cell as? UserEntryYesOrNoCell {
                        let journalEntry = cell.getUpdatedJournalData()
                        userDayWiseData.medicineAnswer = cell.getUpdatedToggleData()
                        print("the medicine answer is",userDayWiseData.medicineAnswer ?? "NA")
                        userDayWiseData.journalAnswer = journalEntry
                    }
        }
        
        print("Mood ID: \(userDayWiseData.moodAnswer ?? -1), Sleep Hours: \(userDayWiseData.sleepAnswer ?? -2), Medicine Flag: \(userDayWiseData.medicineAnswer ?? "None"), Journal: \(userDayWiseData.journalAnswer ?? "None"), Spend Hours: \(userDayWiseData.timeSpendAnswer?.first ?? "")")

        
        let answers = PatientLog()
        
        
        switch dayTime {
        case .Morning, .Afternoon:
            
            guard let moodId = userDayWiseData.moodAnswer,
                          let sleepHours = userDayWiseData.sleepAnswer,
                          let journal = userDayWiseData.journalAnswer, !journal.isEmpty else {
                
            
                
                showGeneralAlert(
                    image: UIImage(named: "InfoIcon"),
                    imageSize: CGSize(width: 60, height: 60),
                    title: alertText ?? "",
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
                    let medicineFlag = userDayWiseData.medicineAnswer
                    medicineFlagString = userDayWiseData.medicineAnswer
                    answers.moodId = moodId
                    answers.sleepHours = sleepHours
                    answers.medicineFlag = Int(medicineFlag ?? "") ?? 0
                    answers.journal = journal
                    answers.activityDate = currentTime!

        case .Evening:
            
            guard let moodId = userDayWiseData.moodAnswer,
                         let spendTime = userDayWiseData.timeSpendAnswer, !spendTime.isEmpty,
                         let journal = userDayWiseData.journalAnswer, !journal.isEmpty else {
                
              
                
                showGeneralAlert(
                    image: UIImage(named: "InfoIcon"),
                    imageSize: CGSize(width: 60, height: 60),
                    title: alertText ?? "",
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
            
            let spendTimeMapped = spendTime.compactMap { item -> String? in
                if let index = Int(item), index > 0, index <= spendOptions.count {
                    return spendOptions[index - 1] // subtract 1 because array is 0-indexed
                } else {
                    return nil
                }
            }
            
                let medicineFlag = userDayWiseData.medicineAnswer
                medicineFlagString = userDayWiseData.medicineAnswer
               answers.moodId = moodId
               answers.medicineFlag = Int(medicineFlag ?? "") ?? 0
               answers.spendTime = spendTimeMapped//spendTime
               answers.journal = journal
               answers.activityDate = currentTime!
            
            print("the answer of spent time is \(answers.spendTime)")

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
                        
                        self.fetchDateTime()
                        if self.userDayWiseData?.dayTimeValue == .Evening {
                            DayFeedbackEveningReminderScheduler.cancelEveningReminder()
                        }
                        
                        self.showSuccessAlert(
                            successContent: AppHelper.getLocalizeString(str: "You saved your mood successfully")
                        ) {
                            print("alert shown")
                               if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                   guard let window = sceneDelegate.window else { return }
                                   let homeController = UIStoryboard(name: "AppTabBar", bundle: nil).instantiateViewController(withIdentifier: "AppMainTabViewController") as! AppMainTabViewController
//                                   homeController.isInitalView = (self.medicineFlagString == "0")
                                   homeController.isInitalView = ((self.medicineFlagString ?? "0") == "0")
                                   print("the medicineFlagString",self.medicineFlagString ?? "none")
                                   print("the initial view value is",homeController.isInitalView)
                                   window.rootViewController = homeController
                                   window.makeKeyAndVisible()
                               }
                               DayFeedbackEveningReminderScheduler.refreshSchedulingIfNeeded()
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
    
    //MARK: - Fetch Date and TIme
    
    func fetchDateTime() {
        DayFeedbackSessionLogic.recordLastSessionPeriod()
    }
    
    @IBAction func didClickOnSkipButton(_ sender: BorderShadowButton) {
        
        if let sceneDelegate = UIApplication.shared.connectedScenes
            .first?.delegate as? SceneDelegate {
            guard let window = sceneDelegate.window else { return }
            let homeController = UIStoryboard(name: "AppTabBar", bundle: nil).instantiateViewController(withIdentifier: "AppMainTabViewController") as! AppMainTabViewController

            homeController.isInitalView = false
 
            window.rootViewController = homeController
            window.makeKeyAndVisible()
        }

        DayFeedbackEveningReminderScheduler.refreshSchedulingIfNeeded()
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
            cell.isFromAPISetup = true 
            cell.selectedIndex = ((selectedCell ?? -1))
            cell.apiSelectedIndex = ((selectedCell ?? -1))
            cell.spendHoursAnswer1 = (SpendTime1 ?? []).map { String($0) }
            
            print("the spend hours answer received is : \(String(describing: SpendTime1))")
            
            cell.isFromAPISetup = false
            
            cell.delegate = self
            cell.updateUIWithCellInstance(instance: userDayWiseData, cellType: cellType)
            return cell
        case .UserIntroSleepCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.getCellIdentifier(), for: indexPath) as? UserEntrySleepHoursCell else {
                return UITableViewCell()
            }

            cell.updateUIWithCellInstance(instance: userDayWiseData, cellType: cellType, slpHrs: Int(slpHours ?? "") ?? -1)
            return cell
        case .UserEntryMedicineCell, .UserEntryJournalCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.getCellIdentifier(), for: indexPath) as? UserEntryYesOrNoCell else {
                return UITableViewCell()
            }
            
            cell.instance = userDayWiseData
            
            if let mediTaken = mediTaken, !mediTaken.isEmpty {
                cell.toggleValue = mediTaken == "No" ? 0 : 1
                cell.toggleImageView.tag = mediTaken == "No" ? -1 : 1
//                feedbackTableView.reloadRows(at: [indexPath], with: .automatic)
            }
            if !isJournalClearedByUser, let journalText = journalText, !journalText.isEmpty {
                
                cell.journalTextView.text = journalText
            } else {
                cell.journalTextView.text = ""
            }
            cell.updateUIWithCellInstance(instance: userDayWiseData, cellType: cellType)
            cell.configureJournalView(isJournalView: cellType == .UserEntryJournalCell)
            return cell
        }
//        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = cellData[indexPath.row]
        return cellType.getCellHeight()
    }
    
   
    
}

extension UIView {
    // Find the first responder in the view hierarchy
    func findFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }
        for subview in subviews {
            if let firstResponder = subview.findFirstResponder() {
                return firstResponder
            }
        }
        return nil
    }

    // Find the nearest superview of a specific type
    func findSuperview<T: UIView>(ofType type: T.Type) -> T? {
        var currentSuperview = self.superview
        while let superview = currentSuperview {
            if let matchingSuperview = superview as? T {
                return matchingSuperview
            }
            currentSuperview = superview.superview
        }
        return nil
    }
}

@available(iOS 16.0, *)
extension UserIntroDayFeedbackViewController: UserIntroSelectionDelegate {
    func didChangeSelectedIndex() {
        if let journalText = journalText, !journalText.isEmpty {
            showCustomClearJournalAlert()
        } else {
            // No journal text to clear, proceed without alert
            print("No journal data to clear")
        }
    }
    
    func showCustomClearJournalAlert() {
        // Show the custom alert with Yes/No options
        self.showGeneralAlertYesNo(
            image: UIImage(named: "question2"),
            imageSize: CGSize(width: 60, height: 60),
            title: "", //Clear Journal Data
            subTitle: AppHelper.getLocalizeString(str: "Would you like to update your mood?"),
            okButtonTitle: AppHelper.getLocalizeString(str: "YES"),
            cancelButtonTitle: AppHelper.getLocalizeString(str: "NO"),
            okAction: {
                // Clear the journal text when the user selects Yes
                self.journalText = nil
                self.isJournalClearedByUser = true
                self.clearJournalDataInCell()
                print("Journal data cleared")
            }, cancelAction: {
                // Simply print that the journal is not cleared
                print("Journal data not cleared")
            }, subtitleFontSize: 14
        )
    }
    
    func clearJournalDataInCell() {
        // Reload the journal cell to clear its content
        if let journalIndex = cellData.firstIndex(of: .UserEntryJournalCell) {
            feedbackTableView.reloadRows(at: [IndexPath(row: journalIndex, section: 0)], with: .automatic)
        }
    }
}



