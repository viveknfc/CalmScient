//
//  SummaryViewController.swift
//  CalmscientIOS
//
//  Created by NFC Solutions on 6/17/24.
//

import UIKit

class SummaryViewController: ViewController {
    @IBOutlet weak var monthLabel: UILabel!
    
    @IBOutlet var pickerView: UIView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet weak var downArrow: UIButton!
    @IBOutlet weak var summaryTableView: UITableView!
    
    var totalDays : Int?
    var alcoholFreeDays : Int?
    var argumentCounts : Int?
    var accidentCounts : Int?
    var drinkCountAchieved : Int?
    var drinkCountTarget : Int?
    var summaryData: [[String: Any]] = []
   // let names = ["Alcohol-Free", "Argument", "Accident", "Drinks"]
    let names = ["days", "count", "times", "times"]
   
    
    var dateString : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        summaryTableView.register(UINib(nibName: "SummaryTableViewCell", bundle: nil), forCellReuseIdentifier: "SummaryTableViewCell")
        summaryTableView.dataSource = self
        summaryTableView.delegate = self
        summaryTableView.reloadData()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let currentDate = Date()
        dateString = dateFormatter.string(from: currentDate)
        
        let newDateFormatter = DateFormatter()
        newDateFormatter.dateFormat = "MM/dd/yyyy"
        let newCurrentDate = Date()

        let newDateString = newDateFormatter.string(from: newCurrentDate)
        monthLabel.text = newDateString

        
        self.title =  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Summary" :"Resumen"
        //pickerView.frame = CGRect.init(x: 0, y: self.view.bounds.height-550, width: 350, height: 200)
        pickerView.backgroundColor = UIColor(named: "whiteAndBlack")
        pickerView.layer.borderColor = UIColor.lightGray.cgColor
        pickerView.layer.borderWidth = 1

        pickerView.translatesAutoresizingMaskIntoConstraints = false
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(pickerView)
            
            // Add constraints
            NSLayoutConstraint.activate([
                pickerView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                pickerView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                pickerView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                pickerView.heightAnchor.constraint(equalToConstant: 200)
            ])
        }
        
        pickerView.isHidden = true
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        self.view.showToastActivity()
        
        getSummarryData(date: dateString, clientId: userInfo.clientID) { [self] result in
            switch result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            print(json)
                            self.view.hideToastActivity()
//                            guard let newData = json["takingControlSummary"] as? [String: Any] else {
//                                    print("Invalid newData format")
//                                    return
//                                }
//                            self.totalDays = newData["totalDays"] as? Int
//                            self.alcoholFreeDays = newData["alcoholFreeDays"] as? Int
//                            self.argumentCounts = newData["argumentCounts"] as? Int
//                            self.accidentCounts = newData["accidentCounts"] as? Int
//                            self.drinkCountAchieved = newData["drinkCountAchieved"] as? Int
//                            self.drinkCountTarget = newData["drinkCountTarget"] as? Int
                           
                            self.summaryData = json["summaryList"] as! [[String : Any]]
                            self.summaryTableView.reloadData()
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
                           // print(json)
                            
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
//        var image = UIImage(named: "NavigationBack")
//        image = image?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image:image , style: UIBarButtonItem.Style.plain, target: self, action: #selector(backButtonOverrideAction))

    }
//    @objc func backButtonOverrideAction() {
//        pickerView.isHidden = true
//        self.navigationController?.popViewController(animated: true)
//        
//    }
    @IBAction func pickerCloseAction(_ sender: Any) {
        pickerView.isHidden = true
    }
    @IBAction func pickerDoneAction(_ sender: Any) {
        self.pickerView.isHidden = true
        let selectedDate = datePicker.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateString = dateFormatter.string(from: selectedDate)
        monthLabel.text = dateString
        
//        let newDateFormatter = DateFormatter()
//        newDateFormatter.dateFormat = "MMM yyyy"
//        let newDateString = newDateFormatter.string(from: selectedDate)
//        monthLabel.text = newDateString
        self.view.showToastActivity()
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        getSummarryData(date: dateString, clientId: userInfo.clientID) { [self] result in
            switch result {
            case .success(let data):
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                          print(json)
                            self.view.hideToastActivity()
//                            guard let newData = json["summaryList"] as? [String: Any] else {
//                                    print("Invalid newData format")
//                                    return
//                                }
                            self.summaryData = json["summaryList"] as! [[String : Any]]
                            self.summaryTableView.reloadData()

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
    
    @IBAction func dateDropButtonAction(_ sender: Any) {
        self.view.bringSubviewToFront(pickerView)
        datePicker.maximumDate = Date()

        pickerView.isHidden = false
        
    }
    func getSummarryData(date: String,clientId: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/takingControl/getTakingControlSummary") else {
            print("Invalid URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(ApplicationSharedInfo.shared.tokenResponse!.accessToken)", forHTTPHeaderField: "Authorization")
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let payload: [String: Any] = [
            "patientId":userInfo.patientID,
            "date": date,
            "clientId": clientId
        ]
        print("payload\(payload)")
        // Convert the payload to JSON data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            //  print(jsonData)
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
            "courseId":5,
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
}
extension SummaryViewController : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return summaryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryTableViewCell", for: indexPath) as! SummaryTableViewCell
       // cell.summaryTitle.text = names[indexPath.row]
       // cell.daysSublable.text = names[indexPath.row]
        cell.backgroundColor = .clear
        let data1 = summaryData[indexPath.row]
       // cell.summaryTitle.text = data1["iconName"] as? String
        
       
      
        if let eventName = data1["iconName"] as? String {
            cell.summaryTitle.text = eventName
        }
        
        if let imageUrlString = data1["url"] as? String, let url = URL(string: imageUrlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        cell.summaryImageView.image = UIImage(data: data)
                    }
                }
            }
        }
       
//        if let days2 = data1["count"] as? Int{
//            DispatchQueue.main.async {
//                cell.daysLabel.text = String(days2)
//            }
//        }
        if let days1 = data1["count"] as? Int , let totalDays = data1["target"] as? Int {
                              cell.daysLabel.text = String(days1)
                              cell.summaryProgressBar.progress = Float(days1) / Float(totalDays)
                              cell.daysSublable.text =  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "days" : "días"
           
                          } else {
                              cell.daysLabel.text = "0"
                              cell.summaryProgressBar.setProgress(0, animated: true)
                          }
        
//        if let totalCount = data1["quantity"] as? NSNumber {
//            cell.quantityLabel.text  = totalCount.stringValue
//        }
        
        if indexPath.row == 0 {
            cell.daysSublable.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "days" : "días"
               }
        if indexPath.row == 1 {
            cell.daysSublable.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "count" : "contar"
                }
        
        if indexPath.row == 2 {
            cell.daysSublable.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "times" : "veces"
                }
        if indexPath.row == 3 {
            cell.daysSublable.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "times" : "veces"
                }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
}



