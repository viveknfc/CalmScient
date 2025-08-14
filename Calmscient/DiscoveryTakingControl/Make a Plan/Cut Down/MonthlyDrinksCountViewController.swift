//
//  MonthlyDrinksCountViewController.swift
//  CalmscientIOS
//
//  Created by BVK on 27/06/24.
//

import UIKit

@available(iOS 16.0, *)
class MonthlyDrinksCountViewController: UIViewController {
    var selectedButtons: Set<UIButton> = []
    var selectedMonths: [String] = []
    var selectedDates: [String] = []
    var dates: [String] = []
    var monthsArray: [String] = []
    var suggestedMonthlyDrinkCount : Int = 0
    var pvcFlag : String = "I"
    var payload: [String: Any] = [:]
    @IBOutlet weak var countsLabel: UILabel!
    @IBOutlet weak var totalAlcoholfreeLabel: UILabel!
    
    @IBOutlet weak var congralatulationsLabel: UITextView!
    @IBOutlet weak var daysLabel: UILabel!


    @IBOutlet weak var monthsView: UIView!
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var calenderBackgroundView: UIView!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var monthlyScrollView: UIScrollView!
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec", "All"]
           var buttons: [UIButton] = []
    
    var calendarView = UICalendarView()

    var calendarSelection: UICalendarSelectionMultiDate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCalendarView()


        setShadow()
        setUpMonths()
        monthlyScrollView.layoutIfNeeded()
        monthlyScrollView.isScrollEnabled = true

        monthlyScrollView.contentSize = CGSize(width: self.view.bounds.width, height: self.contentView.frame.size.height)

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
                           
                            selectedDates = (json["dates"] as Any) as! [String]
                            monthsArray = (json["months"] as Any) as! [String]
                            print("monthsArray\(monthsArray)")
                            countsLabel.text = String(selectedDates.count)
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
    }
    
    @IBAction func downBackButttonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
    }
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        
        congralatulationsLabel.text = AppHelper.getLocalizeString(str: "Congratulations text")
        daysLabel.text = AppHelper.getLocalizeString(str: "days")
        totalAlcoholfreeLabel.text = AppHelper.getLocalizeString(str:"   Your total alcohol free days are")
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
            }
        }
    @IBAction func forwardArrowAction(_ sender: Any) {
        
            
//            guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
//                fatalError("Unable to found Application Shared Info")
//                
//            }
//            if selectedDates.count == 0
//            {
//                self.view.showToast(message: "Please select atleast one date")
//            }
//            else{
//                self.view.showToastActivity()
//                saveMonthsDrinks(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
//                    switch result {
//                    case .success(let data):
//                        // Convert data to JSON object and print it
//                        do {
//                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                                DispatchQueue.main.async { [self] in
//                                    self.view.hideToastActivity()
//                                    print("saveMonthsDrinksjson===\(json)")
//                                    let next = UIStoryboard(name: "MonthsViewController", bundle: nil)
//                                    let vc = next.instantiateViewController(withIdentifier: "MonthsViewController") as? MonthsViewController
//                                    vc?.title = "Make a Plan"
//                                    self.navigationController?.pushViewController(vc!, animated: true)
//                                }
//                                
//                            } else {
//                                print("Unable to convert data to JSON")
//                            }
//                        } catch {
//                            print("Error converting data to JSON: \(error)")
//                        }
//                    case .failure(let error):
//                        print("Error: \(error)")
//                    }
//                }
//                
//            }
                
        let next = UIStoryboard(name: "MonthsViewController", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "MonthsViewController") as? MonthsViewController
        vc?.title = AppHelper.getLocalizeString(str: "Make a plan")
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func backwardArrowAction(_ sender: Any) {
    }
    private func setupCalendarView() {
           print("Setting up calendar view")
           let gregorianCalendar = Calendar(identifier: .gregorian)
           calendarView.calendar = gregorianCalendar
           calendarView.fontDesign = .default
           calendarView.translatesAutoresizingMaskIntoConstraints = false
           calenderBackgroundView.addSubview(calendarView)
           
           NSLayoutConstraint.activate([
               calendarView.leadingAnchor.constraint(equalTo: calenderBackgroundView.safeAreaLayoutGuide.leadingAnchor, constant: 0),
               calendarView.trailingAnchor.constraint(equalTo: calenderBackgroundView.safeAreaLayoutGuide.trailingAnchor, constant: 0),
               calendarView.centerYAnchor.constraint(equalTo: calenderBackgroundView.safeAreaLayoutGuide.centerYAnchor),
           ])
           
           calendarView.backgroundColor = UIColor(named: "NextAppointmentsCellBackgroundColor")

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
        
        
           calendarView.layer.cornerCurve = .continuous
           calendarView.layer.cornerRadius = 10.0
        calendarView.tintColor = UIColor(named: "6E6BB3ColorOnly")
           
           calendarView.delegate = self
           calendarView.availableDateRange = DateInterval(start: Date(), end: Date.distantFuture)
           calendarSelection = UICalendarSelectionMultiDate(delegate: self)
           calendarView.selectionBehavior = calendarSelection

       }
    
    private func setUpMonths() {
        // Title Label
        let titleLabel = UILabel()
        titleLabel.text = "Apply same alcohol free days for following months"
        titleLabel.numberOfLines = 4
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        monthsView.addSubview(titleLabel)
        
        // Constraints for Title Label with 5-point gap at the top
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: monthsView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: monthsView.leadingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(equalTo: monthsView.trailingAnchor)
        ])
        
        // Grid layout
        let gridLayout = UIStackView()
        gridLayout.axis = .vertical
        gridLayout.alignment = .center
        gridLayout.distribution = .equalSpacing
        gridLayout.spacing = 5
        gridLayout.translatesAutoresizingMaskIntoConstraints = false
        monthsView.addSubview(gridLayout)
        
        // Get the current month
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        let currentMonth = dateFormatter.string(from: Date())
        
        // Create buttons for each month
        var currentRowStackView: UIStackView?

        for (index, month) in months.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(month, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.backgroundColor = .white
            button.layer.cornerRadius = 10
            button.layer.shadowColor = UIColor.gray.cgColor
            button.layer.shadowOffset = CGSize(width: 2, height: 2)
            button.layer.shadowOpacity = 0.5
            button.translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: 80).isActive = true
            button.heightAnchor.constraint(equalToConstant: 50).isActive = true
            button.addTarget(self, action: #selector(monthButtonTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            
            // If the button is the current month, set it as selected and disable interaction
            if month == currentMonth {
                button.backgroundColor = UIColor(named: "6E6BB3ColorOnly")
                button.isUserInteractionEnabled = false
                selectedButtons.insert(button)
                selectedMonths.append(month)
            }
            
            // Create new row every 4 buttons
            if index % 4 == 0 {
                currentRowStackView = UIStackView()
                currentRowStackView?.axis = .horizontal
                currentRowStackView?.alignment = .center
                currentRowStackView?.distribution = .equalSpacing
                currentRowStackView?.spacing = 5
                currentRowStackView?.translatesAutoresizingMaskIntoConstraints = false
                gridLayout.addArrangedSubview(currentRowStackView!)
            }
            
            currentRowStackView?.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            gridLayout.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5), // Add 5-point gap between the label and grid
            gridLayout.leadingAnchor.constraint(equalTo: monthsView.leadingAnchor),
            gridLayout.trailingAnchor.constraint(equalTo: monthsView.trailingAnchor),
            gridLayout.bottomAnchor.constraint(equalTo: monthsView.bottomAnchor, constant: -10) // Add 5-point gap at the bottom
        ])
    }

//    private func setUpMonths() {
//        let titleLabel = UILabel()
//        titleLabel.text = "  Apply same alcohol free days for following months"
//        titleLabel.numberOfLines = 2
//        titleLabel.font = UIFont.systemFont(ofSize: 13)
//        titleLabel.textAlignment = .left
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        monthsView.addSubview(titleLabel)
//        
//        NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: monthsView.topAnchor, constant: 10),
//            titleLabel.leadingAnchor.constraint(equalTo: monthsView.leadingAnchor),
//            titleLabel.trailingAnchor.constraint(equalTo: monthsView.trailingAnchor)
//        ])
//        
//        // Create the grid layout
//        let gridLayout = UIStackView()
//        gridLayout.axis = .vertical
//        gridLayout.alignment = .center
//        gridLayout.distribution = .equalSpacing
//        gridLayout.spacing = 2
//        gridLayout.translatesAutoresizingMaskIntoConstraints = false
//        monthsView.addSubview(gridLayout)
//        
//        // Get the current month
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "MMM"
//        let currentMonth = dateFormatter.string(from: Date())
//        
//        // Add buttons to the grid layout
//        var currentRowStackView: UIStackView?
//        
//        for (index, month) in months.enumerated() {
//            let button = UIButton(type: .system)
//            button.setTitle(month, for: .normal)
//            button.setTitleColor(.black, for: .normal)
//            button.backgroundColor = .white
//            button.layer.cornerRadius = 10
//            button.layer.masksToBounds = false
//            button.layer.shadowColor = UIColor.gray.cgColor
//            button.layer.shadowOffset = CGSize(width: 2, height: 2)
//            button.layer.shadowOpacity = 0.5
//            button.translatesAutoresizingMaskIntoConstraints = false
//            button.widthAnchor.constraint(equalToConstant: 40).isActive = true // Decrease the button width
//            button.heightAnchor.constraint(equalToConstant: 40).isActive = true // Set the button height
//            button.addTarget(self, action: #selector(monthButtonTapped(_:)), for: .touchUpInside)
//            buttons.append(button)
//            
//            // Select and disable the current month button
//            if month == currentMonth {
//                button.backgroundColor = UIColor(named: "6E6BB3ColorOnly")
//                button.isUserInteractionEnabled = false
//                selectedButtons.insert(button)
//                selectedMonths.append(month)
//            }
//            
//            if index % 6 == 0 {
//                currentRowStackView = UIStackView()
//                currentRowStackView?.axis = .horizontal
//                currentRowStackView?.alignment = .center
//                currentRowStackView?.distribution = .equalSpacing
//                currentRowStackView?.spacing = 4
//                currentRowStackView?.translatesAutoresizingMaskIntoConstraints = false
//                gridLayout.addArrangedSubview(currentRowStackView!)
//            }
//            
//            currentRowStackView?.addArrangedSubview(button)
//            
//            // Move the "Jan" button 5 points on the x-axis
//            if month == "Jan" || month == "Jul" {
//                button.leadingAnchor.constraint(equalTo: currentRowStackView!.leadingAnchor, constant: 5).isActive = true
//            }
//            if month == "Jun" || month == "Dec" {
//                button.trailingAnchor.constraint(equalTo: currentRowStackView!.trailingAnchor, constant: 15).isActive = true
//            }
//        }
//        
//        // Set up the grid layout constraints
//        NSLayoutConstraint.activate([
//            gridLayout.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
//            gridLayout.leadingAnchor.constraint(equalTo: monthsView.leadingAnchor),
//            gridLayout.trailingAnchor.constraint(equalTo: monthsView.trailingAnchor),
//            gridLayout.bottomAnchor.constraint(equalTo: monthsView.bottomAnchor)
//        ])
//    }

//    private func setUpMonths() {
//           let titleLabel = UILabel()
//           titleLabel.text = "  Apply same alcohol free days for following months"
//           titleLabel.numberOfLines = 0
//           titleLabel.font = UIFont.systemFont(ofSize: 13);  titleLabel.textAlignment = .left
//           titleLabel.translatesAutoresizingMaskIntoConstraints = false
//           monthsView.addSubview(titleLabel)
//        
//
//           NSLayoutConstraint.activate([
//            titleLabel.topAnchor.constraint(equalTo: monthsView.topAnchor,constant: 10),
//               titleLabel.leadingAnchor.constraint(equalTo: monthsView.leadingAnchor),
//               titleLabel.trailingAnchor.constraint(equalTo: monthsView.trailingAnchor)
//           ])
//           
//           // Create the grid layout
//           let gridLayout = UIStackView()
//           gridLayout.axis = .vertical
//           gridLayout.alignment = .fill
//           gridLayout.distribution = .equalSpacing
//           gridLayout.spacing = 2
//           gridLayout.translatesAutoresizingMaskIntoConstraints = false
//           monthsView.addSubview(gridLayout)
//           
//           // Add buttons to the grid layout
//           var currentRowStackView: UIStackView?
//           
//        for (index, month) in months.enumerated() {
//            let button = UIButton(type: .system)
//            button.setTitle(month, for: .normal)
//            button.setTitleColor(.black, for: .normal)
//            button.backgroundColor = .white
//            button.layer.cornerRadius = 10
//            button.layer.masksToBounds = false
//            button.layer.shadowColor = UIColor.gray.cgColor
//            button.layer.shadowOffset = CGSize(width: 2, height: 2)
//            button.layer.shadowOpacity = 0.5
//            button.translatesAutoresizingMaskIntoConstraints = false
//            button.widthAnchor.constraint(equalToConstant: 40).isActive = true // Decrease the button width
//            button.heightAnchor.constraint(equalToConstant: 40).isActive = true // Set the button height
//            button.addTarget(self, action: #selector(monthButtonTapped(_:)), for: .touchUpInside)
//            buttons.append(button)
//           
//            if index % 6 == 0 {
//                currentRowStackView = UIStackView()
//                currentRowStackView?.axis = .horizontal
//                currentRowStackView?.alignment = .fill
//                currentRowStackView?.distribution = .equalSpacing
//                currentRowStackView?.spacing = 5
//                currentRowStackView?.translatesAutoresizingMaskIntoConstraints = false
//                gridLayout.addArrangedSubview(currentRowStackView!)
//            }
//            
//            currentRowStackView?.addArrangedSubview(button)
//            
////            if months.contains(monthsArray) {
////                        button.backgroundColor = UIColor(named: "6E6BB3ColorOnly")
////                    }
//            
//            // Move the "Jan" button 5 points on the x-axis
//            if month == "Jan" {
//                button.leadingAnchor.constraint(equalTo: currentRowStackView!.leadingAnchor, constant: 5).isActive = true
//            }
//            if month == "July" {
//                button.leadingAnchor.constraint(equalTo: currentRowStackView!.leadingAnchor, constant: 5).isActive = true
//            }
//            if month == "Jun" {
//                button.leadingAnchor.constraint(equalTo: currentRowStackView!.trailingAnchor, constant: 15).isActive = true
//            }
//            if month == "Dec" {
//                button.leadingAnchor.constraint(equalTo: currentRowStackView!.trailingAnchor, constant: 15).isActive = true
//            }
//        }
//
//           
//           // Set up the grid layout constraints
//           NSLayoutConstraint.activate([
//               gridLayout.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
//               gridLayout.leadingAnchor.constraint(equalTo: monthsView.leadingAnchor),
//               gridLayout.trailingAnchor.constraint(equalTo: monthsView.trailingAnchor),
//               gridLayout.bottomAnchor.constraint(equalTo: monthsView.bottomAnchor)
//           ])
//       }
    
//    @objc func monthButtonTapped(_ sender: UIButton) {
//
//        guard let month = sender.title(for: .normal) else { return }
//            
//            if selectedButtons.contains(sender) {
//                sender.backgroundColor = .white
//                selectedButtons.remove(sender)
//                selectedMonths.removeAll { $0 == month }
//            } else {
//                sender.backgroundColor = UIColor(named: "6E6BB3ColorOnly")
//                selectedButtons.insert(sender)
//                selectedMonths.append(month)
//            }
//            
//            if selectedMonths.contains("All") {
//                selectedMonths = months
//            } else {
//                selectedMonths = selectedMonths.filter { $0 != "All" }
//                selectedMonths.removeAll { $0 == month }
//
//            }
//            
//            print("Selected months: \(selectedMonths)")
//        }
    @objc func monthButtonTapped(_ sender: UIButton) {
        guard let month = sender.title(for: .normal) else { return }
        
        let currentMonth = getCurrentMonth()
        
        if month == "All" {
            if selectedButtons.contains(sender) {
                // Deselect all months except the current month
                for button in buttons {
                    guard let buttonTitle = button.title(for: .normal), buttonTitle != currentMonth else { continue }
                    button.backgroundColor = .white
                    selectedButtons.remove(button)
                }
                selectedMonths = [currentMonth]
            } else {
                // Select all months except "All"
                for button in buttons {
                    guard let buttonTitle = button.title(for: .normal), buttonTitle != currentMonth else { continue }
                    button.backgroundColor = UIColor(named: "6E6BB3ColorOnly")
                    selectedButtons.insert(button)
                    if buttonTitle != "All" && !selectedMonths.contains(buttonTitle) {
                        selectedMonths.append(buttonTitle)
                    }
                }
                // Change "All" button color
                sender.backgroundColor = UIColor(named: "6E6BB3ColorOnly")
                selectedButtons.insert(sender)
            }
        } else {
            if selectedButtons.contains(sender) {
                sender.backgroundColor = .white
                selectedButtons.remove(sender)
                selectedMonths.removeAll { $0 == month }
            } else {
                sender.backgroundColor = UIColor(named: "6E6BB3ColorOnly")
                selectedButtons.insert(sender)
                selectedMonths.append(month)
            }
            
            // If any month other than "All" is selected, deselect the "All" button
            if selectedButtons.contains(where: { $0.title(for: .normal) != "All" }) {
                for button in buttons where button.title(for: .normal) == "All" {
                    button.backgroundColor = .white
                    selectedButtons.remove(button)
                }
            }
        }
        
        // Ensure the current month is always in the selectedMonths array
        if !selectedMonths.contains(currentMonth) {
            selectedMonths.append(currentMonth)
        }
        
        print("Selected months: \(selectedMonths)")
    }

    func getCurrentMonth() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM"
        return dateFormatter.string(from: Date())
    }


    private func setShadow() {
        calenderBackgroundView.layer.cornerRadius = 10
        calenderBackgroundView.layer.shadowColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1).cgColor
        calenderBackgroundView.layer.shadowOffset = CGSize(width: 2, height: 2)
        calenderBackgroundView.layer.shadowOpacity = 0.5
        calenderBackgroundView.layer.shadowRadius = 2.0
        calenderBackgroundView.layer.masksToBounds = false
        
        monthsView.layer.cornerRadius = 10
        monthsView.layer.shadowColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1).cgColor
        monthsView.layer.shadowOffset = CGSize(width: 2, height: 2)
        monthsView.layer.shadowOpacity = 0.5
        monthsView.layer.shadowRadius = 2.0
        monthsView.layer.masksToBounds = false
        
        dateView.layer.cornerRadius = 10
        dateView.layer.shadowColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1).cgColor
        dateView.layer.shadowOffset = CGSize(width: 2, height: 2)
        dateView.layer.shadowOpacity = 0.5
        dateView.layer.shadowRadius = 2.0
        dateView.layer.masksToBounds = false
        
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func dateToString(_ dateComponents: DateComponents) -> String? {
        guard let year = dateComponents.year, let month = dateComponents.month, let day = dateComponents.day else {
            return nil
        }
        return String(format: "%02d/%02d/%04d", month, day, year)
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
    func saveMonthsDrinks(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/takingControl/saveAlcoholFreeDay") else {
            print("Invalid URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        if suggestedMonthlyDrinkCount == 0{

            payload = [
                "pvcFlag": "I",
                "goalSetupId": 0,
                "patientId": patientId,
                "clientId": clientId,
                "plId": plId,
                "days": selectedDates,
                "months": selectedMonths
            ]
            print(payload)
        }
        else{
             payload = [
                "pvcFlag": "U",
                "goalSetupId": 0,
                "patientId": patientId,
                "clientId": clientId,
                "plId": plId,
                "days": selectedDates,
                "months": selectedMonths
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
    
    @IBAction func setButtonAction(_ sender: Any) {
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
            
        }
        if selectedDates.count == 0
        {
            self.view.showToast(message: "Please select atleast one date")
        }
        else{
            self.view.showToastActivity()
            saveMonthsDrinks(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
                switch result {
                case .success(let data):
                    // Convert data to JSON object and print it
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            DispatchQueue.main.async { [self] in
                                self.view.hideToastActivity()
                                print("saveMonthsDrinksjson===\(json)")
                                self.view.showToast(message: "Saved Alcohol Free Day")
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
            
    }
}
@available(iOS 16.0, *)
extension MonthlyDrinksCountViewController: UICalendarViewDelegate {
//    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
//        let font = UIFont.systemFont(ofSize: 10)
//        let configuration = UIImage.SymbolConfiguration(font: font)
//        let image = UIImage(systemName: "star.fill", withConfiguration: configuration)?.withRenderingMode(.alwaysOriginal)
//        return .image(image)
//    }
}

@available(iOS 16.0, *)
extension MonthlyDrinksCountViewController: UICalendarSelectionSingleDateDelegate {
    @available(iOS 16.0, *)
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        print("Selected Date:",dateComponents ?? "No selection")
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
        return true
    }
}

@available(iOS 16.0, *)
extension MonthlyDrinksCountViewController: UICalendarSelectionMultiDateDelegate {
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didSelectDate dateComponents: DateComponents) {
        if let dateString = dateToString(dateComponents) {
            selectedDates.append(dateString)
            print("Selected Date:", selectedDates)
            let newCount = suggestedMonthlyDrinkCount + selectedDates.count
            countsLabel.text = String( selectedDates.count)
        }
    }
    
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, didDeselectDate dateComponents: DateComponents) {
        if let dateString = dateToString(dateComponents) {
            if let index = selectedDates.firstIndex(of: dateString) {
                selectedDates.remove(at: index)
                print("De-Selected Date:", selectedDates)
                let newCount = suggestedMonthlyDrinkCount + selectedDates.count
                countsLabel.text = String(selectedDates.count)
            }
        }
    }
    
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, canSelectDate dateComponents: DateComponents) -> Bool {
        return true
    }
    
    func multiDateSelection(_ selection: UICalendarSelectionMultiDate, canDeselectDate dateComponents: DateComponents) -> Bool {
        return true
    }
    
}
