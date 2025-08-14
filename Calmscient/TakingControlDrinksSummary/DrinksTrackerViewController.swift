import UIKit

class DrinksTrackerViewController: UIViewController {
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var saveButton: LinearGradientButton!
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var pickerBackView: UIView!
    @IBOutlet weak var drinksTrackerCollectionView: UICollectionView!
    var totalQuantitySum: Int = 0
    var noOfQuantityAlcohol: Int = 0
    var individualQuantity : NSString = ""
    var drinks: [[String: Any]] = []
    var alcoholData: [[String: Any]] = []
    var dateString : String = ""
    
    @IBOutlet weak var datePickerView: UIDatePicker!
    var saveButtonEnabled: Bool = false {
        didSet {
            saveButton.isHidden = saveButtonEnabled
           // saveButton.alpha = saveButtonEnabled ? 1.0 : 0.5 // Optional: Visual feedback for disabled state
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        saveButton.isEnabled = false
//        saveButton.alpha = 0.5
        totalCountLabel.maskCircle()
        let nib = UINib(nibName: "DrinksTrackerCollectionCell", bundle: nil)
        drinksTrackerCollectionView.register(nib, forCellWithReuseIdentifier: "DrinksTrackerCollectionCell")
        drinksTrackerCollectionView.dataSource = self
        drinksTrackerCollectionView.delegate = self
        drinksTrackerCollectionView.reloadData()
        
        self.countLabel.font = UIFont(name: Fonts().lexendRegular, size: 10)
        self.totalLabel.font = UIFont(name: Fonts().lexendRegular, size: 14)
        self.totalCountLabel.font = UIFont(name: Fonts().lexendRegular, size: 20)

        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        pickerBackView.backgroundColor = UIColor(named: "whiteAndBlack")
        pickerBackView.layer.borderColor = UIColor.lightGray.cgColor
        pickerBackView.layer.borderWidth = 1

        pickerBackView.translatesAutoresizingMaskIntoConstraints = false
        if let window = UIApplication.shared.keyWindow {
            window.addSubview(pickerBackView)
            
            // Add constraints
            NSLayoutConstraint.activate([
                pickerBackView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                pickerBackView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                pickerBackView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
                pickerBackView.heightAnchor.constraint(equalToConstant: 200)
            ])
        }
        
        pickerBackView.isHidden = true
        self.view.showToastActivity()
        getAlcoholDrinks(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            print(json)
                            self.view.hideToastActivity()
                            if let totalCount = json["totalCount"] as? NSNumber {
                                self.totalCountLabel.text = totalCount.stringValue
                                noOfQuantityAlcohol = Int(truncating: totalCount)
                            }
                            var newDate = json["date"] as? String
                            newDate = self.getCurrentDateString()
                            self.dateLable.text = newDate
                          //  self.dateLable.text = json["date"] as? String
                            
                            self.drinks = json["drinksList"] as! [[String : Any]]
                            self.drinksTrackerCollectionView.reloadData()
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
        
        saveButtonEnabled = true
    }
    override func viewDidDisappear(_ animated: Bool) {
        pickerBackView.isHidden = true
    }
   
    @IBAction func closeAction(_ sender: Any) {
        pickerBackView.isHidden = true
        
    }
    @IBAction func dropDownButtonAction(_ sender: Any) {
        self.view.bringSubviewToFront(pickerBackView)
        datePickerView.maximumDate = Date()

        pickerBackView.isHidden = false
    }
    @IBAction func doneAction(_ sender: Any) {
        
       
        let selectedDate = datePickerView.date
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateString = dateFormatter.string(from: selectedDate)
       
        print(dateString)
        pickerBackView.isHidden = true
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        self.view.showToastActivity()
        getAlcoholDrinks(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: dateString, bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            print(json)
                            self.view.hideToastActivity()
                            if let totalCount = json["totalCount"] as? NSNumber {
                                self.totalCountLabel.text = totalCount.stringValue
                                noOfQuantityAlcohol = Int(truncating: totalCount)
                            }
//                            var newDate = json["date"] as? String
//                            newDate = self.getCurrentDateString()
                            //self.dateLable.text = newDate
                          //  self.dateLable.text = json["date"] as? String
                            
                            self.drinks = json["drinksList"] as! [[String : Any]]
                            self.drinksTrackerCollectionView.reloadData()
                            dateLable.text = dateString
                           
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
                "activityDate": currentDate
            ]

            // Append the new entry to the existing array
            alcoholData.append(newEntry)
        }
    }

    @IBAction func saveButtonClicked(_ sender: Any) {
        //print("alcoholData==\(alcoholData)")
        self.view.showToastActivity()
        postAlcoholDrinks(alcoholData: alcoholData, bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
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
    
    func getAlcoholDrinks(plId: Int, patientId: Int, clientId: Int, activityDate: String,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
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
            "courseId":6,
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
    func postAlcoholDrinks(alcoholData: [[String: Any]], bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void) {
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
            
            // If needed, handle the response here
            completion(.success(data))
        }
        
        // Start the data task
        task.resume()
    }
    
    
}

extension DrinksTrackerViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        
        cell.minusButtonAction = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            if var count = Int(cell.quantityLabel.text ?? "0"), count > 0 {
                count -= 1
                
                self.totalQuantitySum -= 1
                
                cell.quantityLabel.text = "\(count)"
                
                self.drinks[indexPath.row]["quantity"] = NSNumber(value: count)
                
                totalCountLabel.text = String(self.totalQuantitySum + noOfQuantityAlcohol)
                
                
                self.saveButtonEnabled = false
                
                if let drinkId = drink["drinkId"] as? Int {
                    self.addOrUpdateAlcoholData(drinkId: drinkId, newQuantity: count, flag: "U")
                }
                
            }
        }
        
        cell.plusButtonAction = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            if var count = Int(cell.quantityLabel.text ?? "0") {
                count += 1
                
                self.totalQuantitySum += 1
                
                cell.quantityLabel.text = "\(count)"
                
                self.drinks[indexPath.row]["quantity"] = NSNumber(value: count)
                
                totalCountLabel.text = String(self.totalQuantitySum + noOfQuantityAlcohol)
                
                self.saveButtonEnabled = false
                
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
        return CGSize(width: width, height: 230)
    }
    
    
}
extension UILabel {
    public func maskCircle() {
        self.contentMode = UIView.ContentMode.scaleAspectFill
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = false
        self.clipsToBounds = true

        // make square(* must to make circle),
        // resize(reduce the kilobyte) and
        // fix rotation.
        // self.image = anyImage
    }
}
