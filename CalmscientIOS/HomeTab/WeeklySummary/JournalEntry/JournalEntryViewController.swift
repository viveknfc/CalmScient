//
//  JournalEntryViewController.swift
//  CalmscientIOS
//
//  Created by BVK on 19/07/24.
//

import UIKit

class JournalEntryViewController: ViewController,UITextFieldDelegate, JournalEntryEditViewActions, NewPickerViewDelegate, UISheetPresentationControllerDelegate {
    func didSelectDate(_ date: Date, indexPath: IndexPath?) {
        let calendar = Calendar.current
        let resetDate = calendar.startOfDay(for: date)
        
        // Format the selected date as a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        dateFormatter.locale = Locale(identifier: "en_US")  // Set the locale
        dateFormatter.timeZone = TimeZone.current

        let formattedDate = dateFormatter.string(from: resetDate)
        print("The formatted date is:", formattedDate)
        print("The selected date is:", date)
        
        journalDataFunc(date: formattedDate)
    }
    
    func didDismissPicker() {
        removeDimmingView()
    }
    
    
  
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var discoveryButton: UIButton!
    @IBOutlet weak var dailyButton: UIButton!
    @IBOutlet weak var quizButton: UIButton!
    @IBOutlet weak var calenderButton: UIButton!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var journalTableView: UITableView!
    @IBOutlet weak var needToTalkButton: LinearGradientButton!
    @IBOutlet weak var calendarCloseBtn: UIButton!
    
    @IBOutlet weak var calenderBGView: UIView!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var calendarDoneBtn: UIButton!
    var quizData: [[String: Any]] = []
    var filteredQuizData: [[String: Any]] = []
    var dailyData: [[String: Any]] = []
    var filtereddailyData: [[String: Any]] = []
    var discoverData: [[String: Any]] = []
    var filtereddiscoverData: [[String: Any]] = []
    var totalData: [[String: Any]] = []
    var buttonTag : Int = 1
    var dateString : String = ""
    var dateString1 : String = ""
    @IBOutlet var pickerBackView: UIView!
    var nomedications = UILabel()
    var nomedications1 = UILabel()
    var nomedications2 = UILabel()
    
    var minmax = Bool()
    var expandedIndexPaths: Set<IndexPath> = []
    
    var dimmingView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerView.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())
        needToTalkButton.setAttributedTitleWithGradientDefaults(title: AppHelper.getLocalizeString(str:"Need to talk with someone?"))
        
        searchTF.placeholder = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Search" : "Buscar"
        self.navigationController?.isNavigationBarHidden = false
        calenderButton.layer.cornerRadius = calenderButton.frame.height/2

        searchTF.delegate = self
        searchTF.layer.cornerRadius = 18
        searchTF.layer.borderColor = UIColor.lightGray.cgColor
        searchTF.layer.masksToBounds = true
        searchTF.layer.borderWidth = 1
        
        searchTF.layer.shadowColor = UIColor.black.cgColor
        searchTF.layer.shadowOpacity = 0.2
        searchTF.layer.shadowRadius = 3.0
        searchTF.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        // Adding inner padding for text alignment
        searchTF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: searchTF.frame.height))
        searchTF.leftViewMode = .always
        
//        // Optional: Add a light gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = searchTF.bounds
        gradientLayer.colors = [UIColor.white.withAlphaComponent(0).cgColor, UIColor.white.withAlphaComponent(0).cgColor]
        searchTF.layer.insertSublayer(gradientLayer, at: 0)

        
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 40))
           let magnifyingGlass = UIImageView(image: UIImage(systemName: "magnifyingglass"))
           magnifyingGlass.tintColor = .gray
           magnifyingGlass.contentMode = .center
           magnifyingGlass.frame = CGRect(x: 0, y: 10, width: 20, height: 20) // Center the image
           iconContainer.addSubview(magnifyingGlass)

        searchTF.rightView = iconContainer
        searchTF.rightViewMode = .always
        calendarDoneBtn.setTitle(AppHelper.getLocalizeString(str: "Done"), for: .normal)
        calendarCloseBtn.setTitle(AppHelper.getLocalizeString(str: "Close"), for: .normal)
        
        calenderBGView.layer.cornerRadius = 18
        calenderBGView.layer.masksToBounds = true
        calenderBGView.layer.borderColor = UIColor.gray.cgColor
        calenderBGView.layer.borderWidth = 1
        
        journalTableView.register(UINib(nibName: "quizTableViewCell", bundle: nil), forCellReuseIdentifier: "quizTableViewCell")
        journalTableView.delegate = self
        journalTableView.dataSource = self
        journalTableView.reloadData()

        
        pickerBackView.backgroundColor = UIColor(named: "whiteAndBlack")
        pickerBackView.layer.borderWidth = 1

        pickerBackView.translatesAutoresizingMaskIntoConstraints = false
        
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(pickerBackView)
            NSLayoutConstraint.activate([
                pickerBackView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                pickerBackView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                pickerBackView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                pickerBackView.heightAnchor.constraint(equalToConstant: 200)
            ])
        }
        
        pickerBackView.isHidden = true
        
        
        nomedications.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "No data for this date" : "No hay datos para esta fecha"
        nomedications.textColor = UIColor(named: "medicationscelldefaulttextcolor")
        nomedications.textAlignment = .center
        nomedications.font = UIFont.boldSystemFont(ofSize: 17)

              
        view.addSubview(nomedications)

        nomedications.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
                    nomedications.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    nomedications.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
        self.nomedications.isHidden = true
        
        nomedications1.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "No data for this date" : "No hay datos para esta fecha"
        nomedications1.textColor = UIColor(named: "medicationscelldefaulttextcolor")
        nomedications1.textAlignment = .center
        nomedications1.font = UIFont.boldSystemFont(ofSize: 17)

              
        view.addSubview(nomedications1)

        nomedications1.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
                    nomedications1.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    nomedications1.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
        self.nomedications1.isHidden = true
        
        
        nomedications2.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "No data for this date" : "No hay datos para esta fecha"
        nomedications2.textColor = UIColor(named: "medicationscelldefaulttextcolor")
        nomedications2.textAlignment = .center
        nomedications2.font = UIFont.boldSystemFont(ofSize: 17)

              
        view.addSubview(nomedications2)

        nomedications2.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
                    nomedications2.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    nomedications2.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                ])
        self.nomedications2.isHidden = true
        
        
        
        self.view.showToastActivity()
        
        let currentDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy" // Adjust the format as needed
                 dateString = dateFormatter.string(from: currentDate)
        
        print("dateString===\(dateString)")
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        getJournalEntryData(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, fromDate: "",entry: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            print("getJournalEntryData===\(json)")

                            self.view.hideToastActivity()
                            
                            if let quiz1 = json["quiz"] as? [[String: Any]] {
                                self.quizData = quiz1
                                print("self.quizData==\(self.quizData)")
                                self.filteredQuizData = self.quizData
                                if self.filteredQuizData.isEmpty {
                                    self.nomedications.isHidden = false
                                }
                                else{
                                    self.nomedications.isHidden = true
                                }
                                self.journalTableView.reloadData()

                            } else {
                                print("providerDetails key is missing or not a dictionary")
                            }
                            if let dailyJournal1 = json["dailyJournal"] as? [[String: Any]] {
                                self.dailyData = dailyJournal1
//                                print("self.dailyData==\(self.dailyData)")
//                                self.filtereddailyData = self.dailyData
                                
                                // Print sno values before sorting
                                let beforeSorting = self.dailyData.compactMap { $0["sno"] as? Int }
//                                print("Before Sorting: \(beforeSorting)")

                                // Sort the data
                                self.filtereddailyData = self.dailyData.sorted { (dict1, dict2) in
                                    if let sno1 = dict1["sno"] as? Int, let sno2 = dict2["sno"] as? Int {
                                        return sno1 > sno2 // Descending order
                                    }
                                    return false
                                }

                                // Print sno values after sorting
                                let afterSorting = self.filtereddailyData.compactMap { $0["sno"] as? Int }
//                                print("After Sorting: \(afterSorting)")


                            } else {
                                print("providerDetails key is missing or not a dictionary")
                            }
                            if let discoveryExercises1 = json["discoveryExercises"] as? [[String: Any]] {
                                self.discoverData = discoveryExercises1
                                self.filtereddiscoverData = self.discoverData
                                print("self.discoverData==\(self.discoverData)")


                            } else {
                                print("providerDetails key is missing or not a dictionary")
                            }
                            
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
        let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            let title1 = languageId == 1 ? "Quiz" : "Prueba"
            quizButton.setTitle(title1, for: .normal)
        let title2 = languageId == 1 ? "Daily journal" : "diario"
        dailyButton.setTitle(title2, for: .normal)
        
        let title3 = languageId == 1 ? "Discovery Excercise" : "Ejercicio de descubrimiento"
        discoveryButton.setTitle(title3, for: .normal)
        
        quizButton.isSelected = true
        addButton.isHidden = true
        styleButton(discoveryButton)
        styleButton(dailyButton)
        styleButton(quizButton)
        
        minmax = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false  // Ensures taps propagate to the table view
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func styleButton(_ button: UIButton) {
        button.layer.cornerRadius = button.frame.height / 2 // Capsule style
        button.layer.masksToBounds = true
        button.setTitleColor(UIColor.white, for: .normal) // Text color
        button.titleLabel?.font = UIFont(name: Fonts().lexendRegular, size: 13)
        button.layer.borderWidth = 1.0 // Optional: Add border
        button.layer.borderColor = UIColor.lightGray.cgColor // Optional: Border color
        updateButtonAppearance(button)
    }
    
    private func updateButtonAppearance(_ button: UIButton) {
        if button.isSelected {
            button.backgroundColor = #colorLiteral(red: 0.431372549, green: 0.4196078431, blue: 0.7019607843, alpha: 1)
            button.setTitleColor(UIColor.white, for: .normal) // Text color when selected
            button.layer.borderColor = #colorLiteral(red: 0.9098039216, green: 0.9058823529, blue: 0.9568627451, alpha: 1) // Border color when selected
            button.layer.borderWidth = 2.0
        } else {
            button.backgroundColor = UIColor.clear
            button.setTitleColor(UIColor.black, for: .normal) // Text color when not selected
            button.layer.borderColor = UIColor.black.cgColor // Border color when selected
            button.layer.borderWidth = 1.0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false

        //setupLanguage()
        
        let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            let title1 = languageId == 1 ? "Quiz" : "Prueba"
            quizButton.setTitle(title1, for: .normal)
        let title2 = languageId == 1 ? "Daily Journals" : "diario"
        dailyButton.setTitle(title2, for: .normal)
        
        let title3 = languageId == 1 ? "Discovery Excercise" : "Ejercicio de descubrimiento"
        discoveryButton.setTitle(title3, for: .normal)
    }
    override func viewDidDisappear(_ animated: Bool) {
        pickerBackView.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        pickerBackView.isHidden = true
    }
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        
        needToTalkButton.setAttributedTitleWithGradientDefaults(title: AppHelper.getLocalizeString(str:"Need to talk with someone?"))
      
       

        }
    
    //MARK: - Add Button Pressed
    
    @IBAction func addButtonPressed(_ sender: Any) {
        print("add button of journal pressed")
        showEditJournalView()
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
           textField.rightViewMode = .never // Hide the magnifying glass
       }

       func textFieldDidEndEditing(_ textField: UITextField) {
           if textField.text?.isEmpty ?? true {
               textField.rightViewMode = .always // Show the magnifying glass again
           }
       }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
            filterAndSortData(with: currentText)
            return true
        }
    func filterAndSortData(with searchText: String) {
        if buttonTag == 1{
            if searchText.isEmpty {
                filteredQuizData = quizData
            } else {
                filteredQuizData = quizData.filter { event in
                    if let title = event["title"] as? String {
                        return title.lowercased().contains(searchText.lowercased())
                    }
                    return false
                }
            }
            
            filteredQuizData.sort { (event1, event2) -> Bool in
                guard let title1 = event1["title"] as? String, let title2 = event2["title"] as? String else {
                    return false
                }
                return title1 < title2
            }
            
            journalTableView.reloadData()
        }
        if buttonTag == 2 {
            if searchText.isEmpty {
                filtereddailyData = dailyData
            } else {
                filtereddailyData = dailyData.filter { event in
                    if let title = event["entry"] as? String {
                        return title.lowercased().contains(searchText.lowercased())
                    }
                    return false
                }
            }
            
            filtereddailyData.sort { (event1, event2) -> Bool in
                guard let title1 = event1["entry"] as? String, let title2 = event2["entry"] as? String else {
                    return false
                }
                return title1 < title2
            }
            
            journalTableView.reloadData()
            
        }
        if buttonTag == 3 {
            if searchText.isEmpty {
                filtereddiscoverData = discoverData
            } else {
                filtereddiscoverData = discoverData.filter { event in
                    if let title = event["entry"] as? String {
                        return title.lowercased().contains(searchText.lowercased())
                    }
                    return false
                }
            }
            
            filtereddiscoverData.sort { (event1, event2) -> Bool in
                guard let title1 = event1["entry"] as? String, let title2 = event2["entry"] as? String else {
                    return false
                }
                return title1 < title2
            }
            
            journalTableView.reloadData()
        }
       }
    @IBAction func needToTalkAction(_ sender: Any) {
        let next = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
               let vc = next.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController
               vc?.title = "Emergency resource"
               self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @IBAction func closeButtonClicked(_ sender: Any) {
      //  calenderBackGroundView.removeFromSuperview()
        pickerBackView.isHidden = true

    }
    
    //MARK: - Journal Data Entry API Call
    
    func journalDataFunc(date: String) {
        self.view.showToastActivity()
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        let params:[String:Any] = ["patientLocationId": userInfo.patientLocationID, "clientId": userInfo.clientID, "patientId": userInfo.patientID, "fromDate": date, "entry":""]
        print("the input param for fetch api is", params)

        APIService.JournalDataAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") {  [self] response in
            // Your closure code here
            getresponseforJournalDataAPI(response: response)
            
        }
    }
    
    //MARK: - Journal API Response
    
    func getresponseforJournalDataAPI(response:AnyObject)->() {
        
        if let responseString = response as? String {
            print("Response received from Fetch API calling is", responseString)
        }
        else if let responseDict = response as? [String: Any] {
            if let quiz1 = responseDict["quiz"] as? [[String: Any]] {
                self.quizData = quiz1

                self.filteredQuizData = self.quizData
                if self.filteredQuizData.isEmpty {
                    self.nomedications.isHidden = false
                }
                else{
                    self.nomedications.isHidden = true
                }
                self.journalTableView.reloadData()
                   }
            
            if let dailyJournal1 = responseDict["dailyJournal"] as? [[String: Any]] {
                self.dailyData = dailyJournal1

                self.filtereddailyData = self.dailyData

                self.journalTableView.reloadData()
            }
            
            if let discoveryExercises1 = responseDict["discoveryExercises"] as? [[String: Any]] {
                self.discoverData = discoveryExercises1
                self.filtereddiscoverData = self.discoverData

                self.journalTableView.reloadData()
            }
            self.view.hideToastActivity()
        }
        else {
            print("Unsupported response type:", type(of: response))
        }
    }
    
    //END
    
    @IBAction func okButtomClicked(_ sender: Any) {
        pickerBackView.isHidden = true
        let selectedDate = datePickerView.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateString1 = dateFormatter.string(from: selectedDate)
    //  print(dateString)
        
        self.view.showToastActivity()
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        getJournalEntryData(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, fromDate: dateString1,entry: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            print("getJournalEntryData===\(json)")

                            self.view.hideToastActivity()
                            
                            if let quiz1 = json["quiz"] as? [[String: Any]] {
                                self.quizData = quiz1
                               // print("self.quizData==\(self.quizData)")
                                self.filteredQuizData = self.quizData
                                if self.filteredQuizData.isEmpty {
                                    self.nomedications.isHidden = false
                                }
                                else{
                                    self.nomedications.isHidden = true
                                }
                                self.journalTableView.reloadData()

                            } else {
                                print("providerDetails key is missing or not a dictionary")
                            }
                            if let dailyJournal1 = json["dailyJournal"] as? [[String: Any]] {
                                self.dailyData = dailyJournal1

                                self.filtereddailyData = self.dailyData

                                self.journalTableView.reloadData()
                            } else {
                                print("providerDetails key is missing or not a dictionary")
                            }
                            if let discoveryExercises1 = json["discoveryExercises"] as? [[String: Any]] {
                                self.discoverData = discoveryExercises1
                                self.filtereddiscoverData = self.discoverData

                                self.journalTableView.reloadData()
                            } else {
                                print("providerDetails key is missing or not a dictionary")
                            }
                            
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
    }
    @IBAction func calenderButtonTapped(_ sender: Any) {
//        datePickerView.tintColor = UIColor.green
//        self.view.bringSubviewToFront(pickerBackView)
//        print("calenderButtonTapped")
//        pickerBackView.isHidden = false
        
        let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "newPickerViewVC") as? newPickerViewVC else {
            fatalError("Could not instantiate view controller with identifier 'newPickerViewVC'")
        }
        vc.delegate = self
        
        // Add dimming view
        if let window = UIApplication.shared.windows.first(where: \.isKeyWindow) {
            let dimmingView = UIView(frame: window.bounds)
            dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            window.addSubview(dimmingView)
            self.dimmingView = dimmingView
        }
        
        // Configure bottom sheet presentation
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    let customDetent = UISheetPresentationController.Detent.custom { _ in
                        return 270 // Desired height
                    }
                    sheet.detents = [customDetent]
                } else {
                    sheet.detents = [.medium()]
                }
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                sheet.delegate = self
            }
        }
        
        vc.isModalInPresentation = true

        self.present(vc, animated: true, completion: nil)
        
    }
    
    private func removeDimmingView() {
        dimmingView?.removeFromSuperview()
        dimmingView = nil
    }
    
    @IBAction func quizButtonTapped(_ sender: Any) {
        buttonTag = 1
        journalTableView.register(UINib(nibName: "quizTableViewCell", bundle: nil), forCellReuseIdentifier: "quizTableViewCell")
        journalTableView.delegate = self
        journalTableView.dataSource = self
        journalTableView.reloadData()
        
        [discoveryButton, dailyButton].forEach { $0?.isSelected = false }
        quizButton.isSelected = true
        [discoveryButton, dailyButton, quizButton].forEach { button in
               updateButtonAppearance(button!)
           }

        searchTF.text = ""
        self.nomedications1.isHidden = true
        self.addButton.isHidden = true
        self.nomedications2.isHidden = true
        if self.filteredQuizData.isEmpty {
            self.nomedications.isHidden = false
        }
        else{
            self.nomedications.isHidden = true
        }
        self.journalTableView.reloadData()
    }
    @IBAction func dailyButtonTapped(_ sender: Any) {
        buttonTag = 2
        journalTableView.register(UINib(nibName: "JournalEntryExpandedTableCell", bundle: nil), forCellReuseIdentifier: "JournalEntryExpandedTableCell")
        journalTableView.register(UINib(nibName: "JournalEntryCollapsedTableCell", bundle: nil), forCellReuseIdentifier: "JournalEntryCollapsedTableCell")
        journalTableView.delegate = self
        journalTableView.dataSource = self
        journalTableView.reloadData()
        
        [discoveryButton, quizButton].forEach { $0?.isSelected = false }
        dailyButton.isSelected = true
        [discoveryButton, dailyButton, quizButton].forEach { button in
               updateButtonAppearance(button!)
           }

        searchTF.text = ""
        self.nomedications.isHidden = true
        self.nomedications2.isHidden = true
        self.addButton.isHidden = false
        if self.dailyData.isEmpty {
            self.nomedications1.isHidden = false
        }
        else{
            self.nomedications1.isHidden = true
        }
        self.journalTableView.reloadData()
        
    }
    @IBAction func discoveryButtonTapped(_ sender: Any) {
        buttonTag = 3
        journalTableView.register(UINib(nibName: "JournalEntryExpandedTableCell", bundle: nil), forCellReuseIdentifier: "JournalEntryExpandedTableCell")
        journalTableView.delegate = self
        journalTableView.dataSource = self
        journalTableView.reloadData()
        
        [dailyButton, quizButton].forEach { $0?.isSelected = false }
        discoveryButton.isSelected = true
        [discoveryButton, dailyButton, quizButton].forEach { button in
               updateButtonAppearance(button!)
           }
        
        searchTF.text = ""
        self.nomedications.isHidden = true
        self.nomedications1.isHidden = true
        self.addButton.isHidden = true
        if self.discoverData.isEmpty {
            self.nomedications2.isHidden = false
        }
        else{
            self.nomedications2.isHidden = true
        }
        self.journalTableView.reloadData()
    }
    func getJournalEntryData(plId: Int, patientId: Int, clientId: Int, fromDate: String,entry: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard let url = URL(string: "\(baseURLString)patients/api/v1/patientDetails/getPatientJournalByPatientIdForMobile") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        // Define the JSON payload
        let payload: [String: Any] = [
            "patientLocationId":plId ,
            "fromDate": fromDate,
            "patientId": patientId,
            "clientId": clientId,
            "entry":entry
        ]
        
        print("payload\(payload)")
        // Convert the payload to JSON data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            //print(jsonData)
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
            
            // If needed, handle the response here
            completion(.success(data))
        }
        
        // Start the data task
        task.resume()
    }
    
    //MARK: - For Journal Edit View
    
    fileprivate var editJournalBackGroundView:UIView?
    fileprivate var successAlertBackGroundView:UIView?
    
    fileprivate lazy var editJournalView:JournalEntryEditView = {
        let journalEntryEditView = JournalEntryEditView(frame: .zero)
        journalEntryEditView.journalEntryEditActionDelegate = self
        return journalEntryEditView
    }()
    
    fileprivate lazy var successAlertView:CustomImageAlertView = {
        let successAlertView = CustomImageAlertView(frame: .zero)
//        deleteAlertView.contentLabel.text = "Journal entry data is updated successfully."
//        deleteAlertView.titleLabel.text = "Success"
        successAlertView.cancelButton.isHidden = true
        successAlertView.okButton.isHidden = true
        return successAlertView
    }()
    
    fileprivate func showEditJournalView() {
        editJournalBackGroundView = UIView(frame: .zero)
        editJournalBackGroundView?.frame = self.view.frame
        editJournalBackGroundView?.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        editJournalBackGroundView?.addSubview(editJournalView)
        editJournalView.translatesAutoresizingMaskIntoConstraints = false
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.navigationController?.navigationBar.layer.zPosition = -1
            self.view.addSubview(self.editJournalBackGroundView!)
            self.editJournalView.journalTextView.becomeFirstResponder()
        }, completion: nil)
        editJournalView.layer.cornerRadius = 5
        editJournalView.layer.masksToBounds = true
        editJournalView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        editJournalView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        editJournalView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        editJournalView.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.5).isActive = true
    }
    
    func closeAction() {
        UIView.transition(with: self.view, duration: 0.25, options: .transitionCrossDissolve, animations: {
            self.editJournalView.removeFromSuperview()
            self.editJournalView.journalTextView.text = ""
            self.editJournalBackGroundView?.removeFromSuperview()
            self.editJournalBackGroundView = nil
            self.navigationController?.navigationBar.layer.zPosition = 0
            
        },completion: nil)
    }
    
    func saveAction(updatedText: String) {
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Any] = [
                "patientId": userInfo.patientID,
                "entry": updatedText,
                "plId": userInfo.patientLocationID,
                "clientId": userInfo.clientID
                // Add other necessary parameters here
            ]
        
        print("the add Journal API call params", params)
        
        self.view.showToastActivity()
        
        APIService.AddJournalAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") {  [self] response in
            // Your closure code here
            getresponseforAddJournalAPI(response: response)
            
            DispatchQueue.main.async {
                UIView.transition(with: self.view, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    self.editJournalView.journalTextView.text = ""
                    self.editJournalView.removeFromSuperview()
                    self.editJournalBackGroundView?.removeFromSuperview()
                    self.editJournalBackGroundView = nil
                    self.navigationController?.navigationBar.layer.zPosition = 0
                    
                }, completion: {_ in

                })
            }
            
        }
   
    }
    
    //MARK: - Add Journal API Response
    
    func getresponseforAddJournalAPI(response:AnyObject)->() {
        self.view.hideToastActivity()
        if let responseString = response as? String {
            print("Response received from Add Journal API calling is", responseString)
        } else if let responseDict = response as? [String: Any] {
            
            if let responseMessage = responseDict["responseMessage"] as? String {
                print("Response Message:", responseMessage)
                
                self.showSuccessAlert(successContent: responseMessage, okButtonAction: {
                    print("OK button tapped!")
                    self.refreshDailyJournalData()
                })

            }
            
        } else {
            print("Unsupported response type:", type(of: response))
        }
    }
    
    //End
    
    //MARK: - Get Journal Data API Call
    
    func refreshDailyJournalData() {
        self.view.showToastActivity()
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Any] = [
                "patientId": userInfo.patientID,
                "entry": "",
                "patientLocationId": userInfo.patientLocationID,
                "clientId": userInfo.clientID,
                "fromDate": ""
            ]
        
        print("the Get Journal API call params", params)
        
        APIService.GetJournalDataAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") {  [self] response in
            // Your closure code here
            getresponseforGetJournalDataAPI(response: response)
        }
        
    }
    //MARK: - Get Journal Data API Response
    
    func getresponseforGetJournalDataAPI(response:AnyObject)->() {
        self.view.hideToastActivity()
        if let responseString = response as? String {
            print("Response received from Get Journal Data API calling is", responseString)
        }
        else if let responseDict = response as? [String: Any] {

            // Extract the `dailyJournal` key
                   if let dailyJournal = responseDict["dailyJournal"] as? [[String: Any]] {
                       print("Daily Journal Data:")
                       for entry in dailyJournal {
                           print(entry)
                       }
                       
                       self.dailyData = dailyJournal
                       
                       // Sort the data
                       self.filtereddailyData = self.dailyData.sorted { (dict1, dict2) in
                           if let sno1 = dict1["sno"] as? Int, let sno2 = dict2["sno"] as? Int {
                               return sno1 > sno2 // Descending order
                           }
                           return false
                       }
                       
//                       self.filtereddailyData = self.dailyData
                       self.journalTableView.reloadData()
                       
                   } else {
                       print("dailyJournal key is missing or not a valid array of dictionaries.")
                   }

           
       } else {
           print("Unsupported response type:", type(of: response))
       }

    }
    
    //END
    
    fileprivate func showSuccessMessageView() {
        successAlertBackGroundView = UIView(frame: .zero)
        successAlertBackGroundView?.frame = self.view.frame
        successAlertBackGroundView?.backgroundColor = UIColor.darkGray.withAlphaComponent(0.8)
        successAlertBackGroundView?.addSubview(successAlertView)
        successAlertView.translatesAutoresizingMaskIntoConstraints = false
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.navigationController?.navigationBar.layer.zPosition = -1
            self.view.addSubview(self.successAlertBackGroundView!)
        }, completion:{_ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.successAlertView.removeFromSuperview()
                    self.successAlertBackGroundView?.removeFromSuperview()
                    self.successAlertBackGroundView = nil
                    self.navigationController?.navigationBar.layer.zPosition = 0
                }, completion: nil)
            })
        } )
        successAlertView.layer.cornerRadius = 10
        successAlertView.layer.masksToBounds = true
        successAlertView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        successAlertView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        successAlertView.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.9).isActive = true
        successAlertView.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.3).isActive = true
    }

}
extension JournalEntryViewController : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if buttonTag == 1 {
            return filteredQuizData.count
    }
        if buttonTag == 2 {
            return filtereddailyData.count
        }
        if buttonTag == 3 {
            return filtereddiscoverData.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        if buttonTag == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "quizTableViewCell", for: indexPath) as! quizTableViewCell
            
            let event = filteredQuizData[indexPath.row]
            
            if let eventName = event["title"] as? String {
                cell.titleLabel.text = eventName
            }
            
            if let completionDateTime = event["completionDateTime"] as? String {
                cell.dateandTimeLabel.text = formatDateTime(completionDateTime)
            }
            if let score = event["score"] as? Int, let total = event["totalScore"] as? Int {
                cell.countLabel.text = "\(score)/\(total)"
                cell.quizProgressBar.progress = Float(score) / Float(total)
            } else {
                cell.countLabel.text = "0"
                cell.quizProgressBar.setProgress(0, animated: true)
            }
            
            return cell
        } 
        else if buttonTag == 2 {
            print("daily jounerel")

            //viv start

            if expandedIndexPaths.contains(indexPath) {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "JournalEntryExpandedTableCell", for: indexPath) as? JournalEntryExpandedTableCell else {
                    return UITableViewCell()
                }
                
                cell.selectionStyle = .none
                let event = filtereddailyData[indexPath.row]
                if let eventName = event["createdAt"] as? String {
                    cell.titleLabel.text = formatDateTime1(eventName)
                }
                if let createdAt = event["entry"] as? String {
                    cell.journalTextLabel.text = createdAt
                }
                cell.cellExpansionClosure = { [weak self] shouldCollapse in
                    guard let self = self else { return }
                    if shouldCollapse {
                        self.expandedIndexPaths.remove(indexPath)
                    }
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "JournalEntryCollapsedTableCell", for: indexPath) as? JournalEntryCollapsedTableCell else {
                    return UITableViewCell()
                }
                cell.selectionStyle = .none
                let event = filtereddailyData[indexPath.row]
                if let eventName = event["createdAt"] as? String {
                    cell.titleLabel.text = formatDateTime1(eventName)
                }
                if let createdAt = event["entry"] as? String {
                    cell.subTitleLabel.text = createdAt
                }
                cell.cellExpansionClosure = { [weak self] shouldExpand in
                    guard let self = self else { return }
                    if shouldExpand {
                        self.expandedIndexPaths.insert(indexPath)
                    }
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                return cell
            }

        }
        else if buttonTag == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "JournalEntryExpandedTableCell", for: indexPath) as! JournalEntryExpandedTableCell
            
            let event = filtereddiscoverData[indexPath.row]
            
            if let createdAt = event["createdAt"] as? String, let title = event["title"] as? String {
                let createdAt1 = formatDateTime1(createdAt)
                cell.titleLabel.text = ("\(createdAt1 ?? "") | \(title)")
            }

           
            if let createdAt = event["entry"] as? String {
                cell.journalTextLabel.text = createdAt
            }
//            nomedications.text = filtereddiscoverData.count > 0 ?  "" :  "No data for this date"
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "quizTableViewCell", for: indexPath)
            //cell.textLabel?.text = "Default cell"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        print("Will select row: \(indexPath.row)")
        return indexPath
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        print("Selected row: \(indexPath.row), buttonTag: \(buttonTag)")
        
        if buttonTag == 2 {
            if expandedIndexPaths.contains(indexPath) {
                   expandedIndexPaths.remove(indexPath)
               } else {
                   expandedIndexPaths.insert(indexPath)
               }
               tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        if buttonTag == 3{
            let names = discoverData[indexPath.row] as [String : Any]
            let newUrl = names["url"] as! String
            let title = names["title"] as? String
            print("newUrl===\(newUrl)")
            
            let next = UIStoryboard(name: "FavoritesVideosWebViewController", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "FavoritesVideosWebViewController") as? FavoritesVideosWebViewController
            vc?.favURL = newUrl
            vc?.title = title
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if buttonTag == 1 {
            return 150
        }
        if buttonTag == 2 {
            if expandedIndexPaths.contains(indexPath) {
                        // Dynamic height for expanded cell
                        return UITableView.automaticDimension
                    } else {
                        // Fixed height for non-expanded cells
                        return 98 // Replace with your fixed height
                    }
        }
        if buttonTag == 3 {
            return 98
        }
        return 150
       
    }
    func formatDateTime(_ dateTime: String) -> String? {
           let inputFormatter = DateFormatter()
           inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
           
           let outputFormatter = DateFormatter()
           outputFormatter.dateFormat = "MM/dd/yyyy | hh:mm a"
           
           if let date = inputFormatter.date(from: dateTime) {
               return outputFormatter.string(from: date)
           }
           return nil
       }
    func formatDateTime1(_ dateTime: String) -> String? {
           let inputFormatter = DateFormatter()
           inputFormatter.dateFormat = "yyyy-MM-dd"
           
           let outputFormatter = DateFormatter()
           outputFormatter.dateFormat = "MM/dd/yyyy"
           
           if let date = inputFormatter.date(from: dateTime) {
               return outputFormatter.string(from: date)
           }
           return nil
       }
    func setFormattedCountLabel(score: Int, total: Int) {
           let scoreString = "\(score)"
           let totalString = "\(total)"
           let combinedString = "\(scoreString)|\(totalString)"
           
           let scoreAttributes: [NSAttributedString.Key: Any] = [
               .foregroundColor: UIColor.purple,
               .font: UIFont.systemFont(ofSize: 14)
           ]
           
           let totalAttributes: [NSAttributedString.Key: Any] = [
               .foregroundColor: UIColor.black,
               .font: UIFont.boldSystemFont(ofSize: 18)
           ]
           
           let attributedString = NSMutableAttributedString(string: combinedString)
           attributedString.addAttributes(scoreAttributes, range: NSRange(location: 0, length: scoreString.count))
           attributedString.addAttributes(totalAttributes, range: NSRange(location: scoreString.count + 1, length: totalString.count))
           
       }
    
}

extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
