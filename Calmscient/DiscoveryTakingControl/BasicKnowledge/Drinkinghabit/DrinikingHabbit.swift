//
//  DrinikingHabbit.swift
//  CalmscientIOS
//
//  Created by mac on 06/06/24.
//


import UIKit

@available(iOS 16.0, *)
class DrinikingHabbit: ViewController {
    
    
    @IBOutlet weak var drinkingHabitCollectionView: UICollectionView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var count_view: UIView!
    @IBOutlet weak var count_lbl: UILabel!
    @IBOutlet weak var totalTextLabel: UILabel!
    @IBOutlet weak var countTextLabel: UILabel!
    var drinks: [[String: Any]] = []
    var alcoholData: [[String: Any]] = []
    var totalQuantitySum: Int = 0
    var noOfQuantityAlcohol: Int = 0
    var individualQuantity : NSString = ""
    var optionid : Int?
    var questionnaireId : Int?
    var answerId : Int?
    var basicData: [[String: Any]] = []
    var sectionID66: Int?
    
    var countIncr: String?
 
    override func viewWillAppear(_ animated: Bool) {
        headerLabel.text = AppHelper.getLocalizeString(str: "Now let’s see what drinking habits do you have")
        questionLabel.text = AppHelper.getLocalizeString(str: "What kind of alcohol do you drink each time? and how much?")
        totalTextLabel.text = AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Total")
        countTextLabel.text = AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Count")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "DrinksTrackerCollectionCell", bundle: nil)
        drinkingHabitCollectionView.register(nib, forCellWithReuseIdentifier: "DrinksTrackerCollectionCell")
        drinkingHabitCollectionView.dataSource = self
        drinkingHabitCollectionView.delegate = self
        drinkingHabitCollectionView.reloadData()
        
        count_view.layer.cornerRadius = count_view.frame.size.width / 2
        count_view.layer.masksToBounds = true

//        count_lbl.layer.cornerRadius = count_lbl.frame.size.width / 2
//        count_lbl.layer.masksToBounds = true

        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
            
        }
        
       
        
        self.view.showToastActivity()
        getBasicKnowledgeQuestions(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            self.view.hideToastActivity()
                            self.basicData = json["answersList"] as! [[String : Any]]
                            print("answersList:\(self.basicData)")
                            questionnaireId = self.basicData[1]["questionnaireId"] as? Int
                            
                             answerId = basicData[1]["answerId"] as? Int ?? 0
                            print("Answer ID: \(answerId ?? 0)")
                            
                            
                            let answer = basicData[1]

                            if let options = answer["options"] as? [[String: Any]], let firstOption = options.first {
                                optionid = firstOption["optionId"] as? Int
                                            print("Option ID: \(optionid ?? 0)")
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
        
        
        self.view.showToastActivity()
        getAlcoholDrinks(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            self.view.hideToastActivity()
                            print(json)
                            if let totalCount = json["totalCount"] as? NSNumber {
                                self.count_lbl.text = totalCount.stringValue
                                noOfQuantityAlcohol = Int(truncating: totalCount)
                            }
                            
                            self.drinks = json["drinksList"] as! [[String : Any]]
                            self.drinkingHabitCollectionView.reloadData()
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
        //nav bar back button start
        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)

        // Create a UIButton
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonOverrideAction), for: .touchUpInside)

        // Set constraints to adjust the size
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true // Set desired width
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true // Set desired height

        // Create a UIBarButtonItem using the UIButton
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        //end
    }
    @objc func backButtonOverrideAction() {
           print("Back button tapped")
           // Perform the action you want here
           let next = UIStoryboard(name: "Basicknowledge", bundle: nil)
           let vc = next.instantiateViewController(withIdentifier: "Basicknowledge") as? Basicknowledge
           vc?.title =  AppHelper.getLocalizeString(str: "Basic Knowledge")
   //            vc?.courseID = 3
           self.navigationController?.pushViewController(vc!, animated: true)
           
       }
   
    func getCurrentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: Date())
    }

    func addOrUpdateAlcoholData(drinkId: Int, newQuantity: Int, flag: String) {
        let currentDate = getCurrentDateString()

        if let index = alcoholData.firstIndex(where: { $0["drinkId"] as? Int == drinkId }) {
            alcoholData[index]["quantity"] = newQuantity
            alcoholData[index]["flag"] = flag
            alcoholData[index]["activityDate"] = currentDate

        } else {
            guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
                fatalError("Unable to found Application Shared Info")
            }
            
            let newEntry: [String: Any] = [
                "flag": flag,
                "plId": userInfo.patientLocationID,
                "trackingId": 1,
                "patientId": userInfo.patientID,
                "clientId": userInfo.clientID,
                "quantity": newQuantity,
                "drinkId": drinkId,
                "activityDate": currentDate            ]
            alcoholData.append(newEntry)
            
        }
    }
    func postAlcoholDrinks(alcoholData: [[String: Any]], bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/alcohol/createDrinkTracking") else {
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
            "alcohol": alcoholData
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
    func getAlcoholDrinks(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/alcohol/getDrinksList") else {
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
            "activityDate": activityDate
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
    func getBasicKnowledgeQuestions(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/takingControl/getPatientBasicKnowledgeCourse") else {
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
            "assessmentId": 1
        ]
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
    @IBAction func forward_action(_ sender: UIButton) {
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
            
        }
//        if totalQuantitySum == 0 {
//            self.view.showToast(message: "Please add one any drink")
//        }
//        else{
            self.view.showToastActivity()
        postAlcoholDrinks(alcoholData: alcoholData, bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
                switch result {
                case .success(let data):
                    // Convert data to JSON object and print it
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            DispatchQueue.main.async { [self] in
                                self.view.hideToastActivity()
                                let next = UIStoryboard(name: "FeelDrinkingHabbit", bundle: nil)
                                let vc = next.instantiateViewController(withIdentifier: "FeelDrinkingHabbit") as? FeelDrinkingHabbit
                                 vc?.title =  AppHelper.getLocalizeString(str: "Basic Knowledge")
                                //vc?.basicData2 = basicData
                                vc?.sectionID666 = sectionID66
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
       // }
        
       
    }
    @IBAction func backward_action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }
}
@available(iOS 16.0, *)
extension DrinikingHabbit: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drinks.count // Adjust this to your data count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DrinksTrackerCollectionCell", for: indexPath) as? DrinksTrackerCollectionCell else {
            return UICollectionViewCell()
        }
        let drink = drinks[indexPath.row]
        print("Full drink object:", drink)
        if let eventName = drink["drinkName"] as? String {
            cell.drinksTitle.text = eventName
        }
        
        if let imageUrlString = drink["imageUrl"] as? String, let url = URL(string: imageUrlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        cell.drinksIImageView.image = UIImage(data: data)
                    }
                }
            }
        }
        if let totalCount = drink["quantity"] as? NSNumber {
            cell.quantityLabel.text  = totalCount.stringValue
        }
        
        countIncr = drink["incrementCount"] as? String ?? "0"
        cell.drinkIncrementLabel.text = countIncr
        print("the increment count is", drink["incrementCount"] ?? "999", "-",countIncr as Any)
        
        cell.minusButtonAction = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            if var count = Int(cell.quantityLabel.text ?? "0"), count > 0 {
                count -= Int(countIncr!) ?? 0 // 1
                
                self.totalQuantitySum -= Int(countIncr!) ?? 0 //1
                
                cell.quantityLabel.text = "\(count)"
                
                self.drinks[indexPath.row]["quantity"] = NSNumber(value: count)
                
                count_lbl.text = String(self.totalQuantitySum + noOfQuantityAlcohol)
                
                
                
                if let drinkId = drink["drinkId"] as? Int {
                    self.addOrUpdateAlcoholData(drinkId: drinkId, newQuantity: count, flag: "U")
                }
                
            }
        }
        
        cell.plusButtonAction = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            if var count = Int(cell.quantityLabel.text ?? "0") {
                count += Int(countIncr!) ?? 0 // 1
                
                self.totalQuantitySum += Int(countIncr!) ?? 0 // 1
                
                cell.quantityLabel.text = "\(count)"
                
                self.drinks[indexPath.row]["quantity"] = NSNumber(value: count)
                
                count_lbl.text = String(self.totalQuantitySum + noOfQuantityAlcohol)
                
                
                if let drinkId = drink["drinkId"] as? Int {
                    let flag = count == 1 ? "I" : "U"
                    self.addOrUpdateAlcoholData(drinkId: drinkId, newQuantity: count, flag: flag)
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 10) / 2
        return CGSize(width: width, height: 229)
    }
    
    
}
