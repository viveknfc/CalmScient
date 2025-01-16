//
//  MonthsViewController.swift
//  CalmscientIOS
//
//  Created by BVK on 28/06/24.
//

import UIKit

@available(iOS 16.0, *)
class MonthsViewController: UIViewController,UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var monthlyDrinkCounButton: UIButton!
    @IBOutlet weak var monthsScrollview: UIScrollView!
    var numbers: [Int] = Array(1...10)
    @IBOutlet var numberView: UIView!
    @IBOutlet weak var suggestedCountLable: UILabel!
    @IBOutlet weak var selectedCountView: UIView!
    @IBOutlet weak var suggestedCountView: UIView!
    @IBOutlet weak var calenderView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var numbersPickeView: UIPickerView!
    var suggestedMonthlyDrinkCount : Int = 0
    var drinksCount : Int = 0
    var goalTarget : Int = 0
    var calendarView = UICalendarView()
    var selectedMonths: [String] = []
    var selectedDates: [String] = []
    var payload: [String: Any] = [:]
    var selectedNumber: Int? // To store the selected number

    @IBOutlet weak var errorSubView: UIView!
    var calendarSelection: UICalendarSelectionMultiDate?
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet var errorALertMainView: UIView!
    
    @IBOutlet weak var goodJobLabel: UITextView!
    
    @IBOutlet weak var errorCloseButton: UIButton!
    @IBOutlet weak var monthlyCountLabel: UILabel!
    
    @IBOutlet weak var actualDrinksCountLabel: UILabel!
    
    @IBOutlet weak var howMuchLabel: UILabel!
    
    @IBOutlet weak var setButton: LinearGradientButton!
    
    @IBOutlet weak var errorDismissButton: UIButton!
    
    @IBOutlet weak var errorChangeGoalButton: LinearGradientButton!
    
    @IBOutlet weak var congratulationsSeeIntoButton: UIButton!
    @IBOutlet weak var congratulationsDescriptionLabel: UILabel!
    @IBOutlet weak var congratulationLabel: UILabel!
    @IBOutlet weak var congratulationSubView: UIView!
    @IBOutlet var congratulationView: UIView!
    
    @IBOutlet var bulbPopUpMainView: UIView!
    
    @IBOutlet weak var bulbPopUpSubView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        setupCalendarView()
        setShadow()
        
        numberView.backgroundColor = UIColor.white
        numberView.layer.borderColor = UIColor.lightGray.cgColor
        numberView.layer.borderWidth = 1
        
        numberView.translatesAutoresizingMaskIntoConstraints = false
        
        
        numbersPickeView.delegate = self
        numbersPickeView.dataSource = self
        
        
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(numberView)
            
            // Add constraints
            NSLayoutConstraint.activate([
                numberView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                numberView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                numberView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                numberView.heightAnchor.constraint(equalToConstant: 200)
            ])
        }
        
        numberView.isHidden = true
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
            
        }
        
        self.view.showToastActivity()
        getPatientAlcoholGoal( patientId: userInfo.patientID,bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            self.view.hideToastActivity()
                            print("getPatientAlcoholGoal===\(json)")
                            suggestedMonthlyDrinkCount = json["suggestedMonthlyDrinkCount"] as! Int
                            suggestedCountLable.text = String(suggestedMonthlyDrinkCount)
                            selectedDates = (json["dates"] as Any) as! [String]
                            
                            
                           
                            let numberOfDays = getCurrentMonthNumberOfDays()
                            let dayscount = (numberOfDays ?? 0) - selectedDates.count
                            drinksCount = json["drinkCount"] as! Int
                            
                            let title1 = String(drinksCount)
                            monthlyDrinkCounButton.setTitle(title1, for: .normal)
                            let attributes: [NSAttributedString.Key: Any] = [
                                   .font: UIFont(name: "Helvetica-Bold", size: 40)!,
                                   .foregroundColor: UIColor(named: "6E6BB3ColorOnly") as Any
                               ]
                               let attributedTitle = NSAttributedString(string: title1, attributes: attributes)
                               monthlyDrinkCounButton.setAttributedTitle(attributedTitle, for: .normal)
                            initializeCalendarSelection()
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
            
            // Do any additional setup after loading the view.
        }
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        updateTakingControlIndex( plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            print(json)
                            
                            self.view.hideToastActivity()
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
    
    @IBAction func congratulationSeeIntroButtonAction(_ sender: Any) {
        congratulationView.isHidden = true
        let next = UIStoryboard(name: "Discovery", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "Discovery") as? Discovery
        vc?.title = "Taking Control"
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func bulbButtonAction(_ sender: Any) {
       bulbPopUpViewAppear()
    }
    @IBAction func bulbPopupcloseButtonAction(_ sender: Any) {
        bulbPopUpMainView.isHidden = true
    }
    @IBAction func congratulationCloseButtonAction(_ sender: Any) {
        congratulationView.isHidden = true
    }
    @IBAction func errorCloseButtonAction(_ sender: Any) {
        errorALertMainView.isHidden = true
    }
    
    @IBAction func errorDismissButtonAction(_ sender: Any) {
        errorALertMainView.isHidden = true
        numberView.isHidden = true
    }
    
    @IBAction func errorChangeGoalButtonAction(_ sender: Any) {
        errorALertMainView.isHidden = true
        numberView.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
    }
    func bulbPopUpViewAppear(){
        bulbPopUpMainView.isHidden = false
        bulbPopUpSubView.layer.cornerRadius = 10
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(bulbPopUpMainView)
            
            bulbPopUpMainView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                bulbPopUpMainView.topAnchor.constraint(equalTo: window.topAnchor),
                bulbPopUpMainView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                bulbPopUpMainView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                bulbPopUpMainView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])
        }
    }
    func congratulationViewAppear(){
        numberView.isHidden = true
        congratulationView.isHidden = false
        congratulationSubView.layer.cornerRadius = 10
        congratulationsSeeIntoButton.layer.cornerRadius = 20
        congratulationsSeeIntoButton.layer.borderColor = UIColor(named: "AppThemeColor")?.cgColor
        congratulationsSeeIntoButton.layer.borderWidth = 1
        congratulationView.translatesAutoresizingMaskIntoConstraints = false
        congratulationLabel.font = UIFont(name: Fonts().lexendMedium, size: 19)
        congratulationsDescriptionLabel.font = UIFont(name: Fonts().lexendLight, size: 16)
        congratulationsDescriptionLabel.numberOfLines = 15
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(congratulationView)
            
            congratulationView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                congratulationView.topAnchor.constraint(equalTo: window.topAnchor),
                congratulationView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                congratulationView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                congratulationView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
            ])
        }
    }
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        self.title = AppHelper.getLocalizeString(str:"Taking Control")
        goodJobLabel.text = AppHelper.getLocalizeString(str: "Good job!")
        monthlyCountLabel.text = AppHelper.getLocalizeString(str: "Your suggested" )
        actualDrinksCountLabel.text = AppHelper.getLocalizeString(str:"Your monthly Drinks count")
        howMuchLabel.text = AppHelper.getLocalizeString(str: "Now, lets's decide how much you drink")
       // setButton.titleLabel?.text = AppHelper.getLocalizeString(str: "Set")
        }
    
    func getCurrentMonthNumberOfDays() -> Int? {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Find the range of days in the current month
        if let range = calendar.range(of: .day, in: .month, for: currentDate) {
            return range.count
        }
        
        return nil
    }
    @IBAction func monthlyDrinksButtonAction(_ sender: Any) {
        numberView.isHidden = false
        numbersPickeView.delegate = self
        numbersPickeView.dataSource = self
    }
    func initializeCalendarSelection() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        var componentsArray: [DateComponents] = []
        
        for dateString in selectedDates {
            if let date = dateFormatter.date(from: dateString) {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: date)
                componentsArray.append(components)
            }
        }
        
        DispatchQueue.main.async {
            guard let calendarSelection = self.calendarSelection else {
                print("calendarSelection is nil")
                return
            }
            calendarSelection.selectedDates = componentsArray
            // self.calendarView.reloadDecorations(forDateComponents: componentsArray, animated: true)
        }
    }
    private func setupCalendarView() {
        let calendarView = UICalendarView()
        let gregorianCalendar = Calendar(identifier: .gregorian)
        calendarView.calendar = gregorianCalendar
        //        calendarView.locale = Locale(identifier: "zh_TW")
        calendarView.fontDesign = .default
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        self.calenderView.addSubview(calendarView)
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: calenderView.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            calendarView.trailingAnchor.constraint(equalTo: calenderView.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            calendarView.centerYAnchor.constraint(equalTo: calenderView.safeAreaLayoutGuide.centerYAnchor),
        ])
        calendarView.backgroundColor = UIColor(named: "lightF2F2F2Color")
        calendarView.layer.cornerCurve = .continuous
        calendarView.layer.cornerRadius = 10.0
        calendarView.tintColor = UIColor(named: "AppThemeColor")
        
        calendarView.delegate = self
        //        calendarView.wantsDateDecorations = true
        calendarView.availableDateRange = DateInterval.init(start: Date.now, end: Date.distantFuture)
        calendarSelection = UICalendarSelectionMultiDate(delegate: self)
        calendarView.selectionBehavior = calendarSelection
        calendarView.isUserInteractionEnabled = false
        
        
        
        let blankHeaderView = UIView()
                blankHeaderView.translatesAutoresizingMaskIntoConstraints = false
                blankHeaderView.backgroundColor = UIColor.white // Change color if needed
        calendarView.addSubview(blankHeaderView)
                
                NSLayoutConstraint.activate([
                    blankHeaderView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor),
                    blankHeaderView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor),
                    blankHeaderView.topAnchor.constraint(equalTo: calendarView.topAnchor),
                    blankHeaderView.heightAnchor.constraint(equalToConstant: 50) // Set height as needed
                ])
        
        
        let monthLabel = UILabel()
                monthLabel.translatesAutoresizingMaskIntoConstraints = false
                monthLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
                monthLabel.textColor = .black
                
                // Get the current month name
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMMM"
                monthLabel.text = dateFormatter.string(from: Date())
                
                blankHeaderView.addSubview(monthLabel)
                
                NSLayoutConstraint.activate([
                    monthLabel.leadingAnchor.constraint(equalTo: blankHeaderView.leadingAnchor, constant: 16),
                    monthLabel.centerYAnchor.constraint(equalTo: blankHeaderView.centerYAnchor)
                ])
        
        
    }
    @IBAction func closeClicked(_ sender: Any) {
        numberView.isHidden = true
    }
    
    @IBAction func doneClicked(_ sender: Any) {
        numberView.isHidden = true
        if goalTarget > suggestedMonthlyDrinkCount
        {
            //showAlertView()
            errorALertMainView.isHidden = false
            errorSubView.layer.cornerRadius = 10
            errorDismissButton.layer.cornerRadius = 20
            errorDismissButton.layer.borderColor = UIColor(named: "AppThemeColor")?.cgColor
            errorDismissButton.layer.borderWidth = 1
            errorALertMainView.translatesAutoresizingMaskIntoConstraints = false
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.addSubview(errorALertMainView)
                
                errorALertMainView.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    errorALertMainView.topAnchor.constraint(equalTo: window.topAnchor),
                    errorALertMainView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                    errorALertMainView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                    errorALertMainView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
                ])
            }

        }
    }
    func errorAlertViewAppear(){
        numberView.isHidden = true
        if goalTarget > suggestedMonthlyDrinkCount
        {
            //showAlertView()
            errorALertMainView.isHidden = false
            errorSubView.layer.cornerRadius = 10
            errorDismissButton.layer.cornerRadius = 20
            errorDismissButton.layer.borderColor = UIColor(named: "AppThemeColor")?.cgColor
            errorDismissButton.layer.borderWidth = 1
            errorALertMainView.translatesAutoresizingMaskIntoConstraints = false
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.addSubview(errorALertMainView)
                
                errorALertMainView.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    errorALertMainView.topAnchor.constraint(equalTo: window.topAnchor),
                    errorALertMainView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                    errorALertMainView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                    errorALertMainView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
                ])
            }

        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        numberView.isHidden = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        numberView.isHidden = true
    }
    func getPatientAlcoholGoal(patientId: Int, bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/takingControl/getPatientAlcoholGoal") else {
            print("Invalid URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        
        
        let payload: [String: Any] = [
            "patientId": patientId,
        ]
        print(payload)
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            //    print(jsonData)
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
    func showAlertView() {
           let alertView = CustomAlertView1()
           alertView.translatesAutoresizingMaskIntoConstraints = false
           
           view.addSubview(alertView)
           
           NSLayoutConstraint.activate([
               alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
               alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
               alertView.widthAnchor.constraint(equalToConstant: 300),
               alertView.heightAnchor.constraint(equalToConstant: 200)
           ])
           
           alertView.dismissButton.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
           alertView.changeGoalButton.addTarget(self, action: #selector(changeGoal), for: .touchUpInside)
           alertView.closeButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
       }
       
       @objc func dismissAlert() {
           
           if let alertView = view.subviews.first(where: { $0 is CustomAlertView1 }) {
               alertView.removeFromSuperview()
           }
       }
    @objc func dismissAction() {
        self.view.showToastActivity()
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
            
        }
        saveGoalSetupMakeAPlan(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            self.view.hideToastActivity()
                            print("saveMonthsDrinksjson===\(json)")
                            
                            if let alertView = view.subviews.first(where: { $0 is CustomAlertView1 }) {
                                alertView.removeFromSuperview()
                            }
                            self.view.showToast(message: "Saved Goal Setup Make A plan")
                            let next = UIStoryboard(name: "Discovery", bundle: nil)
                            let vc = next.instantiateViewController(withIdentifier: "Discovery") as? Discovery
                            vc?.title = "Taking Control"
                            self.navigationController?.pushViewController(vc!, animated: true)
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
       
       @objc func changeGoal() {
           print("Change goal action triggered")
          
           dismissAlert()
       }
    func saveGoalSetupMakeAPlan(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/takingControl/saveGoalSetupMakeAPlan") else {
            print("Invalid URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        
       

        if suggestedMonthlyDrinkCount == goalTarget {
            
            payload = [
                "pvcFlag": "U",
                "patientId": patientId,
                "clientId": clientId,
                "plId": plId,
                "goalTarget": goalTarget

            ]
            print(payload)
        }
        else{
            payload = [
                "pvcFlag": "I",
                "patientId": patientId,
                "clientId": clientId,
                "plId": plId,
                "goalTarget": goalTarget
            ]
            print(payload)
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            //    print(jsonData)
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
    func updateTakingControlIndex(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void){
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/takingControl/updateTakingControlIndex") else {
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
            
           
            "patientId": patientId,
            "clientId": clientId,
            "plId":plId,
            "courseId":4,
            "isCompleted":1
            
        ]
        
        
        print("payload\(payload)")
        // Convert the payload to JSON data
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
                print("Response JSON: \(jsonResponse)")
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
    @IBAction func forwardButtonAction(_ sender: Any) {
    }
    @IBAction func backwardButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func setButtonAction(_ sender: Any) {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
            
        }
//        if goalTarget > suggestedMonthlyDrinkCount
//        {
//          //  showAlertView()
//        }
//        else{
            self.view.showToastActivity()
            saveGoalSetupMakeAPlan(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
                switch result {
                case .success(let data):
                    // Convert data to JSON object and print it
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            DispatchQueue.main.async { [self] in
                                self.view.hideToastActivity()
                                print("saveMonthsDrinksjson===\(json)")
//                                self.view.showToast(message: "Saved Goal Setup Make A Plan")
//                                let next = UIStoryboard(name: "Discovery", bundle: nil)
//                                let vc = next.instantiateViewController(withIdentifier: "Discovery") as? Discovery
//                                vc?.title = "Taking Control"
//                                self.navigationController?.pushViewController(vc!, animated: true)
                                congratulationViewAppear()
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
            
       // }
    }
    private func setShadow() {
        calenderView.layer.cornerRadius = 10
        calenderView.layer.shadowColor = UIColor.gray.cgColor
        calenderView.layer.shadowOffset = CGSize(width: 2, height: 2)
        calenderView.layer.shadowOpacity = 0.5
        calenderView.layer.shadowRadius = 2.0
        calenderView.layer.masksToBounds = false
        
        suggestedCountView.layer.cornerRadius = 10
        suggestedCountView.layer.shadowColor = UIColor.gray.cgColor
        suggestedCountView.layer.shadowOffset = CGSize(width: 2, height: 2)
        suggestedCountView.layer.shadowOpacity = 0.5
        suggestedCountView.layer.shadowRadius = 2.0
        suggestedCountView.layer.masksToBounds = false
        
        selectedCountView.layer.cornerRadius = 10
        selectedCountView.layer.shadowColor = UIColor.gray.cgColor
        selectedCountView.layer.shadowOffset = CGSize(width: 2, height: 2)
        selectedCountView.layer.shadowOpacity = 0.5
        selectedCountView.layer.shadowRadius = 2.0
        selectedCountView.layer.masksToBounds = false
        
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
           return 1 // Number of columns
       }
       
       func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
           return numbers.count // Number of rows
       }
       
       // MARK: - UIPickerViewDelegate
       
       func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
           return "\(numbers[row])" // Display the number as the title
       }
       
       func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
           // Handle the selection
           let selectedNumber = numbers[row]
           print("Selected number: \(selectedNumber)")
           
           let numberOfDays = getCurrentMonthNumberOfDays()
           
           //let dayscount = (numberOfDays ?? 0) - selectedDates.count
           
           if drinksCount == 0{
               let dayscount = (numberOfDays ?? 0) - selectedDates.count
               goalTarget = dayscount * selectedNumber
           }
           else {
               goalTarget = drinksCount * selectedNumber
           }
           let newtitle = String(goalTarget)
           monthlyDrinkCounButton.setTitle(newtitle, for: .normal)
           
           let attributes: [NSAttributedString.Key: Any] = [
                  .font: UIFont(name: "Helvetica-Bold", size: 40)!,
                  .foregroundColor: UIColor(named: "6E6BB3ColorOnly") as Any
              ]
              let attributedTitle = NSAttributedString(string: newtitle, attributes: attributes)
              monthlyDrinkCounButton.setAttributedTitle(attributedTitle, for: .normal)
       }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
@available(iOS 16.0, *)
extension MonthsViewController: UICalendarViewDelegate {
    //    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
    //        let font = UIFont.systemFont(ofSize: 10)
    //        let configuration = UIImage.SymbolConfiguration(font: font)
    //        let image = UIImage(systemName: "star.fill", withConfiguration: configuration)?.withRenderingMode(.alwaysOriginal)
    //        return .image(image)
    //    }
}

@available(iOS 16.0, *)
extension MonthsViewController: UICalendarSelectionSingleDateDelegate {
    @available(iOS 16.0, *)
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        print("Selected Date:",dateComponents ?? "No selection")
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
        return true
    }
}

@available(iOS 16.0, *)
extension MonthsViewController: UICalendarSelectionMultiDateDelegate {
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didSelectDate dateComponents: DateComponents) {
        print("Selected Date:",dateComponents)
    }
    
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didDeselectDate dateComponents: DateComponents) {
        print("De-Selected Date:",dateComponents)
    }
    
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, canSelectDate dateComponents: DateComponents) -> Bool {
        return true
    }
    
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, canDeselectDate dateComponents: DateComponents) -> Bool {
        return true
    }
    
}
