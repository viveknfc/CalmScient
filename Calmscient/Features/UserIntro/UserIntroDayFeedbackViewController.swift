//
//  UserIntroDayFeedbackViewController.swift
//  HealthApp
//
//  Created by KA on 26/02/24.
//

import UIKit
import SwiftyJSON

// 1. Add new case to enum
enum UserEntryDayFeedbackTableCell: String {
    case UserMoodHoursCell = "UserMoodHoursCell"
    case UserFocusHoursCell = "UserFocusHoursCell"  // ADD THIS — second mood question
    case UserIntroSleepCell = "UserIntroSleepCell"
    case UserEntryTimeSpendCell = "UserEntryTimeSpendCell"
    case UserEntryMedicineCell = "UserEntryMedicineCell"
    case UserEntryJournalCell = "UserEntryJournalCell"

    func getCellIdentifier() -> String {
        switch self {
        case .UserMoodHoursCell, .UserFocusHoursCell, .UserEntryTimeSpendCell:
            return "UserIntroSelectionTableCell"  // reuses same cell XIB
        case .UserIntroSleepCell:
            return "UserEntrySleepHoursCell"
        case .UserEntryMedicineCell, .UserEntryJournalCell:
            return "UserEntryYesOrNoCell"
        }
    }

    func getCellHeight() -> CGFloat {
        switch self {
        case .UserMoodHoursCell, .UserFocusHoursCell:
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
    var mediTaken2: String?      // ADD THIS
    var isJournalClearedByUser = false
    var medicineFlagString2: String?   // ADD THISprepareCellData
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
    
    // ADD THIS - for focus mood question
       var selectedCell2: Int? {
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
                let morningGreet = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Hello" : "Hola"
                GreetingTitle = "\(morningGreet) \(titleString)!"
            case .Evening:
                let eveGreet = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Good evening" : "¡Buenas noches"
                GreetingTitle = "\(eveGreet) \(titleString)!"
            }
        }
        
        let language = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        if language == 1 {
            alertText = "Please fill all mandatory fields."
        } else {
            alertText = "Por favor, completa todos los campos obligatorios."
        }
        
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
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Specify the desired format
        let sampleTime = Date()
        print("the fetching time in local is ", sampleTime)
        
        fetchDateTime() //for userintro in scene delegate
        
        currentTime = dateFormatter.string(from: sampleTime)
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
                         
                         let next = UIStoryboard(name: "LoginVC", bundle: nil)
                         UserDefaults.standard.set(0, forKey: "rememberMe")
                         
                         UserDefaultsHelper.clearLoginDetailsFromUserDefaults()
                         ApplicationSharedInfo.shared.loginResponse = nil
                         ApplicationSharedInfo.shared.tokenResponse = nil

                             if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                                 let newViewController = next.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                                 let navController = UINavigationController(rootViewController: newViewController)
                                 sceneDelegate.changeRootViewController(to: navController)
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
              // If we have more than one view controller in the stack, we're coming from a previous screen (likely the home screen)
              if viewControllers[viewControllers.count - 2] is HomeTabDashboardViewController {
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
        // ✅ Reset stale answers before fetching fresh data
         userDayWiseData?.journalAnswer = nil
         userDayWiseData?.medicineAnswer = nil
         userDayWiseData?.moodAnswer = nil
         userDayWiseData?.focusAnswer = nil
         userDayWiseData?.sleepAnswer = nil
         userDayWiseData?.timeSpendAnswer = nil
         
         // reset local fetch vars too
         journalText = nil
         mediTaken = nil
         slpHours = nil
         selectedCell = nil
         selectedCell2 = nil
         SpendTime1 = nil
         isJournalClearedByUser = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Make sure to reset the navigation bar visibility when leaving this view controller
        // This is especially important if you want to ensure the state is consistent when navigating back
        self.navigationController?.isNavigationBarHidden = true
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
    
    //
    
//    func getresponseforFetchMoodDataAPI(response:AnyObject, completion: @escaping () -> Void) {
//
//        if let responseString = response as? String {
//            print("Response received from Fetch API calling is", responseString)
//
//            DispatchQueue.main.async {
//                let alertController = UIAlertController(title: "Error",
//                                                        message: "Failed to fetch data. Would you like to retry?",
//                                                        preferredStyle: .alert)
//
//                alertController.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in
//                    self.viewWillAppear(true)
//                }))
//
//                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//
//                self.present(alertController, animated: true)
//            }
//
//        }
//        else if let responseDict = response as? [String: Any] {
//
//            do {
//                let responseData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
//                let loginResponse = try JSONDecoder().decode(UserStartupScreenDayData.self, from: responseData)
//
//                if let answersList = loginResponse.startupAnswersDtoList, !answersList.isEmpty {
//                    print("data not empty")
//
//                    for answer in answersList {
//                           switch answer.activitySection {
//
//                               // Replace the Mood Monitor case:
//                               case "Mood Monitor":
//                                   selectedCell = (Int(answer.activityResponse?.first ?? "-1") ?? 0) - 2
//
//                           case "Focus":
//                               selectedCell2 = (Int(answer.activityResponse?.first ?? "-1") ?? 0) - 1
//
//                          case "Sleep Hours":
////                              slpHours = String((Int(answer.activityResponse) ?? 0) - 1)
//                              if let index = sleepData.firstIndex(of: answer.activityResponse?.first ?? "-1") {
//                                  slpHours = String(index)
//                              } else {
//                                  slpHours = "0" // Default value if not found
//                              }
//
//                          case "Medication":
//                              mediTaken = answer.activityResponse?.first
//                               print(answer.activityResponse)
//                          case "Journal":
//                              journalText = answer.activityResponse?.first
//                          case "SpendTime":
//                              let fetchedAnswers: [String] = answer.activityResponse?.compactMap { String($0) } ?? []
//                              SpendTime1 = fetchedAnswers.compactMap { spendOptions.firstIndex(of: $0).map { $0 + 1 } }//answer.activityResponse?.compactMap { Int($0) }
//                              print("the fetching answers for time spend is :\(String(describing: SpendTime1))")
//                          default:
//                              break
//                          }
//                      }
//
//                } else {
//                    print("data empty")
//                }
//
//            }
//            catch {
//               print("Failed to decode UserStartupScreenDayData:", error)
//           }
//
//            DispatchQueue.main.async {
//                self.feedbackTableView.reloadData()
//            }
//
//        }
//        else {
//            print("Unsupported response type:", type(of: response))
//        }
//
//        completion()
//
//    }
    func getresponseforFetchMoodDataAPI(response: AnyObject, completion: @escaping () -> Void) {

        if let responseString = response as? String {
            print("Response received from Fetch API calling is", responseString)
            DispatchQueue.main.async {
                let alertController = UIAlertController(
                    title: "Error",
                    message: "Failed to fetch data. Would you like to retry?",
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
                    self.viewWillAppear(true)
                })
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self.present(alertController, animated: true)
            }

        } else if let responseDict = response as? [String: Any] {

            do {
                let responseData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                let loginResponse = try JSONDecoder().decode(UserStartupScreenDayData.self, from: responseData)

                if let answersList = loginResponse.startupAnswersDtoList, !answersList.isEmpty {
                    print("data not empty")

                    // Deduplicate: keep only the FIRST occurrence of each activitySection
                    var seenSections = Set<String>()
                    let dedupedAnswers = answersList.filter { answer in
                        seenSections.insert(answer.activitySection).inserted
                    }

                    for answer in dedupedAnswers {
                        switch answer.activitySection {

                        case "Mood Monitor":
                            // optionTypeID is 1-based → subtract 1 for 0-based selectedIndex
                            selectedCell = (Int(answer.activityResponse?.first ?? "-1") ?? 0) - 1

                        case "Focus":
                            selectedCell2 = (Int(answer.activityResponse?.first ?? "-1") ?? 0) - 1

                        case "Sleep Hours":
                            if let index = sleepData.firstIndex(of: answer.activityResponse?.first ?? "-1") {
                                slpHours = String(index)
                            } else {
                                slpHours = "0"
                            }

                        case "Medication":
                            mediTaken = answer.activityResponse?.first
                            print("Medication response:", answer.activityResponse ?? [])

                        case "Journal":
                            let rawJournal = answer.activityResponse?.first ?? ""
                            // Accept any non-empty text including numeric (server may store count or real text)
                            // Only reject empty
                            journalText = rawJournal.isEmpty ? nil : rawJournal
                            print("Journal response raw:", rawJournal)

                        case "SpendTime":
                            let fetchedAnswers: [String] = answer.activityResponse?.compactMap { String($0) } ?? []
                            SpendTime1 = fetchedAnswers.compactMap { spendOptions.firstIndex(of: $0).map { $0 + 1 } }
                            print("SpendTime fetched:", SpendTime1 ?? [])

                        default:
                            break
                        }
                    }

                } else {
                    print("data empty")
                }

            } catch {
                print("Failed to decode UserStartupScreenDayData:", error)
            }

            DispatchQueue.main.async {
                self.feedbackTableView.reloadData()
            }

        } else {
            print("Unsupported response type:", type(of: response))
        }

        completion()
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
    // 2. Update prepareCellData() — add UserMoodHoursCell2, REMOVE UserEntryMedicineCell2
    private func prepareCellData() -> [UserEntryDayFeedbackTableCell] {
        guard let userDayWiseData = self.userDayWiseData, let dayTime = userDayWiseData.dayTimeValue else {
            return []
        }
        switch dayTime {
        case .Morning, .Afternoon:
            UserDefaults.standard.set(true, forKey: "Morning")
            return [.UserMoodHoursCell, .UserFocusHoursCell, .UserIntroSleepCell, .UserEntryMedicineCell, .UserEntryJournalCell]

        case .Evening:
            UserDefaults.standard.set(false, forKey: "Morning")
            return [.UserMoodHoursCell, .UserFocusHoursCell, .UserEntryTimeSpendCell, .UserEntryMedicineCell, .UserEntryJournalCell]
        }
    }
    
    @IBAction func didClickOnSaveButton(_ sender: UIButton) {
        self.view.endEditing(true)
        guard let userDayWiseData = self.userDayWiseData, let dayTime = userDayWiseData.dayTimeValue else {
            return
        }
        
        for cell in feedbackTableView.visibleCells {
//            if let cell = cell as? UserIntroSelectionTableCell {
//                if cell.tag == 2001 {
//                    userDayWiseData.moodAnswer = cell.getUpdatedData4MoodId()
//                    
//                } else if cell.tag == 2002 {
//                    // Use same getter — it reads cell.selectedIndex which is
//                    // correctly set to selectedCell2 for this cell
//                    userDayWiseData.focusAnswer = cell.getUpdatedData4FocusId()
//                }else if let cell = cell as? UserEntrySleepHoursCell {
//                    let updatedSleepHours = cell.getUpdatedData() ?? 1
//                    print("the updatedSleepHours is", updatedSleepHours)
//                    
//                    if updatedSleepHours > 0 && updatedSleepHours <= sleepData.count {
//                        let sleepAns = sleepData[updatedSleepHours - 1]
//                        userDayWiseData.sleepAnswer = Int(sleepAns)
//                    } 
//                    else if updatedSleepHours <= 0 || updatedSleepHours > sleepData.count {
//                        showGeneralAlert(
//                            image: UIImage(named: "InfoIcon"),
//                            imageSize: CGSize(width: 60, height: 60),
//                            title: alertText ?? "",
//                            okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
//                            okAction: {},
//                            dismissAction: {}
//                        )
//                        return
//                    }
                if let cell = cell as? UserIntroSelectionTableCell {
                    if cell.tag == 2001 {
                        userDayWiseData.moodAnswer = cell.getUpdatedData4MoodId()
                    } else if cell.tag == 2002 {
                        userDayWiseData.focusAnswer = cell.getUpdatedData4FocusId()
                    }
                } else if let cell = cell as? UserEntrySleepHoursCell {
                    let updatedSleepHours = cell.getUpdatedData() ?? 1
                    if updatedSleepHours > 0 && updatedSleepHours <= sleepData.count {
                        userDayWiseData.sleepAnswer = Int(sleepData[updatedSleepHours - 1])
                    } else {
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
                    if cell.tag == 1001 {
                        userDayWiseData.medicineAnswer = cell.getUpdatedToggleData()
                    } else if cell.tag == 1003 {
                        userDayWiseData.journalAnswer = cell.getUpdatedJournalData()
                    }
                }
            
                    
                    
                    
//                } else if let cell = cell as? UserEntryYesOrNoCell {
//                    //                        let journalEntry = cell.getUpdatedJournalData()
//                    //                        userDayWiseData.medicineAnswer = cell.getUpdatedToggleData()
//                    //                        print("the medicine answer is",userDayWiseData.medicineAnswer ?? "NA")
//                    //                        userDayWiseData.journalAnswer = journalEntry
//                    if cell.tag == 1001 {
//                        userDayWiseData.medicineAnswer = cell.getUpdatedToggleData()
//                        print("medicine answer captured:", userDayWiseData.medicineAnswer ?? "nil")
//                    } else if cell.tag == 1003 {
//                        userDayWiseData.journalAnswer = cell.getUpdatedJournalData()
//                    }
//                }
            
        }
        print("Mood: \(userDayWiseData.moodAnswer ?? -1), Focus: \(userDayWiseData.focusAnswer ?? -1)")

        print("Mood ID: \(userDayWiseData.moodAnswer ?? -1),   focus ID: \(userDayWiseData.focusAnswer ?? -1), Sleep Hours: \(userDayWiseData.sleepAnswer ?? -2), Medicine Flag: \(userDayWiseData.medicineAnswer ?? "None"), Journal: \(userDayWiseData.journalAnswer ?? "None"), Spend Hours: \(userDayWiseData.timeSpendAnswer?.first ?? "")")

        
        let answers = PatientLog()
        
        
        switch dayTime {
        case .Morning, .Afternoon:
            
            guard let moodId = userDayWiseData.moodAnswer, let focusId = userDayWiseData.focusAnswer,
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
                    answers.focusId = focusId
                    answers.sleepHours = sleepHours
            switch medicineFlag {
            case "1", "Yes":               answers.medicineFlag = 1
            case "0", "No":                answers.medicineFlag = 0
            case "2", "Not yet", "NotYet": answers.medicineFlag = 2
            default:                       answers.medicineFlag = 0
            }
                    answers.journal = journal
                    answers.activityDate = currentTime!

        case .Evening:
            
            guard let moodId = userDayWiseData.moodAnswer,let focusId = userDayWiseData.focusAnswer,
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
               answers.focusId = focusId
            switch medicineFlag {
            case "1", "Yes":               answers.medicineFlag = 1
            case "0", "No":                answers.medicineFlag = 0
            case "2", "Not yet", "NotYet": answers.medicineFlag = 2
            default:                       answers.medicineFlag = 0
            }
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
        
        print("payload: ----- \(answers)")
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
                        
                        self.showSuccessAlert() {
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
        let now = Date()

        // Extract Date (yyyy-MM-dd)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: now)

        // Extract Time (HH:mm:ss)
        let timeFormatter = DateFormatter()
        timeFormatter.timeZone = TimeZone.current
        timeFormatter.dateFormat = "HH:mm:ss"
        let timeString = timeFormatter.string(from: now)

        // Save in UserDefaults
        UserDefaults.standard.set(dateString, forKey: "savedDate")
        UserDefaults.standard.set(timeString, forKey: "savedTime")
    }
    
    //MARK: - Save Alert View
    
    func showSuccessAlert(completion: @escaping () -> Void) {
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        // Create a semi-transparent background view
        let backgroundView = UIView(frame: window.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add the background view to the main view
        window.addSubview(backgroundView)
        
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
        
        // Animate the appearance of the alert
            backgroundView.alpha = 0
            successAlert.alpha = 0
            UIView.animate(withDuration: 0.3) {
                backgroundView.alpha = 1
                successAlert.alpha = 1
            }
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
            
        case .UserMoodHoursCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.getCellIdentifier(), for: indexPath) as? UserIntroSelectionTableCell else {
                return UITableViewCell()
            }
            cell.isFromAPISetup = true
            cell.selectedMoodIndex = selectedCell ?? -1
            cell.apiSelectedIndex = selectedCell ?? -1
            cell.spendHoursAnswer1 = (SpendTime1 ?? []).map { String($0) }
            cell.isFromAPISetup = false
            cell.delegate = self
            cell.tag = 2001  // Tag for first mood cell
            cell.updateUIWithCellInstance(instance: userDayWiseData, cellType: cellType)
            return cell
            
        case .UserFocusHoursCell:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: cellType.getCellIdentifier(), for: indexPath
            ) as? UserIntroSelectionTableCell else {
                return UITableViewCell()
            }
            cell.isFromAPISetup = true
            cell.selectedFocusIndex = selectedCell2 ?? -1
            cell.apiSelectedIndex = selectedCell2 ?? -1
            // ❌ REMOVE spendHoursAnswer1 assignment here — not relevant to focus cell
            cell.isFromAPISetup = false
            cell.delegate = self
            cell.tag = 2002
            cell.updateUIWithCellInstance(instance: userDayWiseData, cellType: cellType)
            return cell
            // 3. In cellForRowAt — handle UserMoodHoursCell2 same as UserMoodHoursCell
        case .UserEntryTimeSpendCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.getCellIdentifier(), for: indexPath) as? UserIntroSelectionTableCell else {
                return UITableViewCell()
            }
            cell.isFromAPISetup = true
            cell.selectedIndex = (selectedCell ?? -1)
            cell.apiSelectedIndex = (selectedCell ?? -1)
            cell.spendHoursAnswer1 = (SpendTime1 ?? []).map { String($0) }
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
            //        case .UserEntryMedicineCell, .UserEntryJournalCell:
            //            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.getCellIdentifier(), for: indexPath) as? UserEntryYesOrNoCell else {
            //                return UITableViewCell()
            //            }
            //
            //            cell.instance = userDayWiseData
            //
            //            if let mediTaken = mediTaken, !mediTaken.isEmpty {
            //                cell.toggleValue = mediTaken == "No" ? 0 : 1
            //                cell.toggleImageView.tag = mediTaken == "No" ? -1 : 1
            ////                feedbackTableView.reloadRows(at: [indexPath], with: .automatic)
            //            }
            //            if !isJournalClearedByUser, let journalText = journalText, !journalText.isEmpty {
            //
            //                cell.journalTextView.text = journalText
            //            } else {
            //                cell.journalTextView.text = ""
            //            }
            //            cell.updateUIWithCellInstance(instance: userDayWiseData, cellType: cellType)
            //            cell.configureJournalView(isJournalView: cellType == .UserEntryJournalCell)
            //            return cell
            //        }
            //        return UITableViewCell()
        case .UserEntryMedicineCell, .UserEntryJournalCell:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: cellType.getCellIdentifier(), for: indexPath) as? UserEntryYesOrNoCell else {
                return UITableViewCell()
            }
            
            cell.instance = userDayWiseData
            cell.updateUIWithCellInstance(instance: userDayWiseData, cellType: cellType)
            cell.configureJournalView(isJournalView: cellType == .UserEntryJournalCell)
            
            // Pre-fill medicine answer AFTER configureJournalView so buttons are visible
            if cellType == .UserEntryMedicineCell {
                cell.tag = 1001
                if let mediTaken = mediTaken, !mediTaken.isEmpty {
                    switch mediTaken {
                    case "1", "Yes":                cell.toggleValue = 1
                    case "0", "No":                 cell.toggleValue = 0
                    case "2", "Not yet", "NotYet":  cell.toggleValue = 2
                    default:                        cell.toggleValue = nil
                    }
                }
            
            } else if cellType == .UserEntryJournalCell {
                cell.tag = 1003
                // ✅ Always use journalText (from API fetch), not instance.journalAnswer
                if !isJournalClearedByUser, let journalText = journalText, !journalText.isEmpty {
                    cell.journalTextView.text = journalText
                    cell.textCount.text = "\(journalText.count)/2000"
                } else {
                    cell.journalTextView.text = ""
                    cell.textCount.text = "0/2000"
                }
                // ✅ Sync instance so textViewDidChange stays consistent
                cell.instance.journalAnswer = cell.journalTextView.text.isEmpty ? nil : cell.journalTextView.text
            }
            
            return cell
        }
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
        func didChangeSelectedIndex(forTag tag: Int, selectedIndex: Int) {
            if tag == 2001 {
                selectedCell = selectedIndex
                userDayWiseData?.setMoodAnswer(byIndex: selectedIndex)
                // Show journal clear alert only for mood change
                if let journalText = journalText, !journalText.isEmpty {
                    showCustomClearJournalAlert(forTag: tag)
                } else {
                    print("No journal data to clear")
                }
            } else if tag == 2002 {
                selectedCell2 = selectedIndex
                userDayWiseData?.setFocusAnswer(byIndex: selectedIndex)
                // Show separate alert for focus change
                if let journalText = journalText, !journalText.isEmpty {
                    showCustomClearJournalAlert(forTag: tag)
                } else {
                    print("No journal data to clear")
                }
            }
        }

        func showCustomClearJournalAlert(forTag tag: Int) {
            let subtitle = tag == 2001
                ? AppHelper.getLocalizeString(str: "Would you like to update your mood?")
                : AppHelper.getLocalizeString(str: "Would you like to update your focus?")
            

            self.showGeneralAlertYesNo(
                image: UIImage(named: "question2"),
                imageSize: CGSize(width: 60, height: 60),
                title: "",
                subTitle: subtitle,
                okButtonTitle: AppHelper.getLocalizeString(str: "YES"),
                cancelButtonTitle: AppHelper.getLocalizeString(str: "NO"),
                okAction: {
                    self.journalText = nil
                    self.isJournalClearedByUser = true
                    self.clearJournalDataInCell()
                    print("Journal data cleared")
                },
                cancelAction: {
                    print("Journal data not cleared")
                },
                subtitleFontSize: 14
            )
        }

        func clearJournalDataInCell() {
            if let journalIndex = cellData.firstIndex(of: .UserEntryJournalCell) {
                feedbackTableView.reloadRows(at: [IndexPath(row: journalIndex, section: 0)], with: .automatic)
            }
        }
    
}



