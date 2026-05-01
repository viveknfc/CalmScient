//
//  DrinkingCountVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 16/12/24.
//

import UIKit

class DrinkingCountVC: ViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {  //DrinkingCountCellDelegate
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var totalCount: FontLR12!
    @IBOutlet weak var totalCountView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    var noOfQuantityAlcohol: Double = 0
    var drinks: [[String: Any]] = []
    var alcoholData: [[String: Any]] = []
    var alcoholRequest = [Alcohol]()
    var saveButtonEnabled: Bool = true {
        didSet {
            saveButton.isHidden = saveButtonEnabled
           // saveButton.alpha = saveButtonEnabled ? 1.0 : 0.5 // Optional: Visual feedback for disabled state
        }
    }
    
    var totalCount1: Double = 0 {
            didSet {
                // Update the total count label whenever the total changes
                totalCount.text = "\(totalCount1)"
            }
        }
    
    private var data: [DrinkingCountData] = [
            DrinkingCountData(countImageName: "check", countLabelText: "1", centreImageName: "beerImage", centreLabelText: "Regular beer (12 fl oz) about 5% alcohol"),
            DrinkingCountData(countImageName: "check", countLabelText: "2", centreImageName: "wine", centreLabelText: "Margarita (3 fl oz) about 33% alcohol"),
            DrinkingCountData(countImageName: "check", countLabelText: "3", centreImageName: "flavour", centreLabelText: "Glass of table wine (5 fl oz) about 12% alcohol"),
            DrinkingCountData(countImageName: "check", countLabelText: "1", centreImageName: "beerImage", centreLabelText: "Regular beer (12 fl oz) about 5% alcohol"),
            DrinkingCountData(countImageName: "check", countLabelText: "2", centreImageName: "wine", centreLabelText: "Margarita (3 fl oz) about 33% alcohol"),
            DrinkingCountData(countImageName: "check", countLabelText: "3", centreImageName: "flavour", centreLabelText: "Glass of table wine (5 fl oz) about 12% alcohol"),
            DrinkingCountData(countImageName: "check", countLabelText: "1", centreImageName: "beerImage", centreLabelText: "Regular beer (12 fl oz) about 5% alcohol")
        ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self

        mainCollectionView.register(UINib(nibName: "DrinkingCountCell", bundle: nil), forCellWithReuseIdentifier: "DrinkingCountCell")
        
        totalCountView.layer.cornerRadius = 8 // Adjust this value as needed
        totalCountView.layer.masksToBounds = true
        let nib = UINib(nibName: "DrinksTrackerCollectionCell", bundle: nil)
        mainCollectionView.register(nib, forCellWithReuseIdentifier: "DrinksTrackerCollectionCell")
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        mainCollectionView.reloadData()

        // Do any additional setup after loading the view.
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
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
                                self.totalCount.text = totalCount.stringValue
                                noOfQuantityAlcohol = Double(truncating: totalCount)
                            }
                            var newDate = json["date"] as? String
                            newDate = self.getCurrentDateString()
//                            self.dateLable.text = newDate
                          //  self.dateLable.text = json["date"] as? String
                            
                            self.drinks = json["drinksList"] as! [[String : Any]]
                            
                            if !self.drinks.isEmpty {
                                guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
                                    fatalError("Unable to found Application Shared Info")
                                }
                                let todaysDate = getCurrentDateString()
                                for drink in self.drinks {
                                    
                                    let alcohol = Alcohol(activityDate: todaysDate, clientID: userInfo.clientID, drinkID: drink["drinkId"] as? Int, flag: "", patientID: userInfo.patientID, plID: userInfo.patientLocationID, quantity: drink["quantity"] as? Int)
                                    alcoholRequest.append(alcohol)
                                }
                                
                            }
                            self.mainCollectionView.reloadData()
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
    
//    func didUpdateCountValue(changeType: CountChangeType) {
//         switch changeType {
//         case .increase:
//             totalCount1 += 1
//         case .decrease:
//             totalCount1 -= 1
//         }
//     }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drinks.count
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
            cell.rightCountView.isHidden = totalCount == 0 ? true : false
            
        }
        
        var countIncr: Double = 0.0
        if let num = drink["incrementCount"] as? NSNumber {
            countIncr = num.doubleValue
        } else if let str = drink["incrementCount"] as? String {
            countIncr = Double(str) ?? 0.0
        }
        cell.drinkIncrementLabel.text = "\(countIncr)"
        print("the increment count is", drink["incrementCount"] ?? "?", "-", countIncr)

        cell.minusButtonAction = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            if var count = Double(cell.quantityLabel.text ?? "0"), count > 0 {
                count -= countIncr // 1
                cell.rightCountView.isHidden = count == 0 ? true : false
                self.totalCount1 -= countIncr // 1
                print("from minus action total count value is",totalCount1)
//                cell.quantityLabel.text = "\(count)"
                cell.quantityLabel.text = String(format: "%.1f", count)
                
                self.drinks[indexPath.row]["quantity"] = NSNumber(value: count)
                
//                totalCount.text = String(self.totalCount1 + noOfQuantityAlcohol)
                let finalTotal = Double(self.totalCount1 + noOfQuantityAlcohol)
                totalCount.text = String(format: "%.1f", finalTotal)
                
                self.saveButtonEnabled = true
                
                if let drinkId = drink["drinkId"] as? Int {
                    self.addOrUpdateAlcoholData(drinkId: drinkId, newQuantity: count, flag: "U")
                    
                }
                
            }
            
        }
        
        cell.plusButtonAction = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            if var count = Double(cell.quantityLabel.text ?? "0") {
                count += countIncr // 1
                
                self.totalCount1 += countIncr // 1
                print("from plus action total count value is",totalCount1)
                
//                cell.quantityLabel.text = "\(count)"
                cell.quantityLabel.text = String(format: "%.1f", count)
                
                self.drinks[indexPath.row]["quantity"] = NSNumber(value: count)
                
                print("the total count is",totalCount1, "+", noOfQuantityAlcohol)
//                totalCount.text = String(self.totalCount1 + noOfQuantityAlcohol)
                let finalTotal = Double(self.totalCount1 + noOfQuantityAlcohol)
                totalCount.text = String(format: "%.1f", finalTotal)

                
                
                cell.rightCountView.isHidden = totalCount.text == "0" ? true : false
                self.saveButtonEnabled = true
                
                if let drinkId = drink["drinkId"] as? Int {
                    let flag = count == 1 ? "I" : "U"
                    self.addOrUpdateAlcoholData(drinkId: drinkId, newQuantity: count, flag: flag)
                }
            }
        }
    
        print("Total count value is ",self.totalCount1)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 10) / 2
        return CGSize(width: width, height: 230)
    }
    


}



extension DrinkingCountVC {
    
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
    
    func getCurrentDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: Date())
    }
    func addOrUpdateAlcoholData(drinkId: Int, newQuantity: Double, flag: String) {
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
    
}


extension DrinkingCountVC {
    
    
//MARK: - UIBUTTON ACTIONS
    
    @IBAction func saveCartBtnAction() {
        self.view.showToastActivity()
        let params: [String: Any] = [ "alcohol": alcoholData ]
        
        print("the Get Journal API call params", params)
    
        APIService.createDrinkingCountAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body" ) { [self] result in
            
            print(result)
            if let responseDict = result as? [String: Any],
               let statusResponse = responseDict["statusResponse"] as? [String: Any],
               let responseMessage = statusResponse["responseMessage"] as? String {
                print(responseMessage)
                self.showSuccessAlert(successContent: responseMessage, centreImage: nil, okButtonAction: {
                    self.navigationController?.popViewController(animated: true)
                })
            }
            self.view.hideToastActivity()
        }
        
    }
    
    
}
