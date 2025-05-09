import UIKit

class BasicStandardDrink: ViewController {
    
    @IBOutlet weak var drinkScrollView: UIScrollView!
    @IBOutlet weak var drinkName: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var normalTextLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var main_view: UIView!
    @IBOutlet weak var image_view: UIView!
    @IBOutlet weak var normalTextView: UITextView!
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    var images: [UIImage] = []
    var titles: [String] = []
    var currentIndex: Int = 0
    var drinks: [[String: Any]] = []
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    var sectionID1: Int?
    var userloginResponse : LoginDetails?
    override func viewDidLoad() {
        super.viewDidLoad()
        labelText()
        main_view.layer.cornerRadius = 10
        main_view.layer.borderWidth = 1
        main_view.layer.borderColor = UIColor(hex: "#F6F6FF").cgColor
        updateContent()
        
        
        self.view.bringSubviewToFront(backButton)
        self.view.bringSubviewToFront(forwardButton)
        
        self.view.showToastActivity()
        if #available(iOS 17.4, *) {
//            drinkScrollView.bouncesHorizontally = false
        } else {
            // Fallback on earlier versions
        }
        drinkScrollView.alwaysBounceHorizontal = false
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        userloginResponse = userInfo
      
        self.normalTextLabel.font = UIFont(name: Fonts().lexendLight, size: 16)
        self.normalTextView.font = UIFont(name: Fonts().lexendLight, size: 16)
        getAlcoholDrinks(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, activityDate: "", bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            print(json)
                            
                            self.drinks = json["drinksList"] as! [[String : Any]]
                            self.view.hideToastActivity()
                            loadTitlesAndImages()
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
    
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
        completeButton.updateTitleForLanguage()
    }
    
    func labelText() {
        let fullText = """
        In the United States, a “standard drink” (also known as an alcoholic drink equivalent) is defined as any drink that contains about 0.6 fluid ounces or 14 grams of pure alcohol. Although the drinks pictured here are different sizes, each contains approximately the same amount of alcohol and counts as one U.S. standard drink or one alcoholic drink equivalent.
        """

        // Define the substrings and the color to apply
        let purpleSubstrings = ["0.6 fluid ounces", "14 grams"]
        let purpleColor = UIColor(named: "barColor1")

        // Create an NSMutableAttributedString
        let attributedString = NSMutableAttributedString(string: fullText)

        // Apply purple color to the specified substrings
        for substring in purpleSubstrings {
            if let range = fullText.range(of: substring) {
                let nsRange = NSRange(range, in: fullText)
                attributedString.addAttribute(.foregroundColor, value: purpleColor, range: nsRange)
            }
        }

        // Assign the attributed string to the UILabel
        normalTextLabel.attributedText = attributedString

        // Additional label setup (optional)
        normalTextLabel.numberOfLines = 0  // Allows label to display multiple lines
        normalTextLabel.textAlignment = .left
       
    }
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
                
                headerLabel.text = AppHelper.getLocalizeString(str: "What’s a standard drink")
                normalTextLabel.text = AppHelper.getLocalizeString(str: "standard drink description")
                normalTextView.text = AppHelper.getLocalizeString(str: "standard drink description2")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
                
                headerLabel.text = AppHelper.getLocalizeString(str: "What’s a standard drink")
                normalTextLabel.text = AppHelper.getLocalizeString(str: "standard drink description")
                normalTextView.text = AppHelper.getLocalizeString(str: "standard drink description2")
            }
        self.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
        }
    
    //viv start
    
    func loadTitlesAndImages() {
        activityIndicator.startAnimating()
        
        let filteredDrinks = drinks.filter { drink in
            if let drinkId = drink["drinkId"] as? Int {
                return drinkId >= 2  // Start from drinkId = 2
            }
            return false
        }
        .sorted { // Sort by drinkId to maintain the sequence
            if let id1 = $0["drinkId"] as? Int, let id2 = $1["drinkId"] as? Int {
                return id1 < id2
            }
            return false
        }
        
        var tempTitles: [String] = Array(repeating: "", count: filteredDrinks.count)
        var tempImages: [UIImage?] = Array(repeating: nil, count: filteredDrinks.count)
        var loadedCount = 0

        for (index, drink) in filteredDrinks.enumerated() {
            if let title = drink["drinkName"] as? String,
               let imageUrlString = drink["imageUrl"] as? String,
               let url = URL(string: imageUrlString) {

                    URLSession.shared.dataTask(with: url) { data, response, error in
                        if let data = data, let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                tempTitles[index] = title
                                tempImages[index] = image
                                loadedCount += 1

                                if loadedCount == filteredDrinks.count {
                                    self.titles = tempTitles
                                    self.images = tempImages.compactMap { $0 }
                                    self.updateContent()
                                    self.activityIndicator.stopAnimating()
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                print("Failed to load image from URL: \(url)")
                                loadedCount += 1
                                if loadedCount == filteredDrinks.count {
                                    self.titles = tempTitles
                                    self.images = tempImages.compactMap { $0 }
                                    self.updateContent()
                                    self.activityIndicator.stopAnimating()
                                }
                            }
                        }
                    }.resume()

            } else {
                print("Invalid data: \(drink)")
            }
        }
    }

    
    //END
    
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
        print("getDrinksList payload\(payload)")
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
    
    func updateContent() {
        if !images.isEmpty && !titles.isEmpty {
            imageView.image = images[currentIndex]
            drinkName.text = titles[currentIndex]
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        guard !images.isEmpty, !titles.isEmpty else { return }
        if currentIndex > 0 {
            currentIndex -= 1
            updateContent()
        }
    }
    
    @IBAction func forwardButtonTapped(_ sender: UIButton) {
        guard !images.isEmpty, !titles.isEmpty else { return }
        if currentIndex < images.count - 1 {
            currentIndex += 1
        } 
//        else {
//            currentIndex = 0  // Rotate back to the first image
//        }
        updateContent()
    }

    //MARK: - Complete Button Pressed
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        
        completeButtonAPICall()

    }
    
    //MARK: - Complete Button API Call
    
    func completeButtonAPICall() {
        self.view.showToastActivity()
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Any] = [
            "isCompleted":1,
            "patientId": userInfo.patientID,
            "sectionId":sectionID1 ?? 0
        ]

        APIService.DUpdateBasicKAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            self.getresponseforBasicKnowAPI(response: response)
        }
    }
    
    //MARK: - Complete Button API Response
    
    func getresponseforBasicKnowAPI(response: Any) {
        self.view.hideToastActivity()
        
        if let responseDict = response as? [String: Any] {
            
            print("Response from Basic standard complete button:", responseDict)
            self.navigationController?.popViewController(animated: true)
            
        } else {
            print("Unsupported response type:", type(of: response))
        }
    }
    
    
}

