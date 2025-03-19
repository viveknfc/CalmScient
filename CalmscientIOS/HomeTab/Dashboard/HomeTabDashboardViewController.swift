//
//  HomeTabDashboardViewController.swift
//  MainTabBarApp
//
//  Created by KA on 23/04/24.
//

import UIKit

class HomeTabDashboardViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    
    static let shared = HomeTabDashboardViewController()
    
    @IBOutlet weak var noFavsLabel: UILabel!
    @IBOutlet weak var screenTitleLabel: UILabel!
    @IBOutlet weak var dashboardTableView: UITableView!
    @IBOutlet weak var dashBoardCollectionView: UICollectionView!
    @IBOutlet weak var actionButton: LinearGradientButton!
    var favorites: [[String: Any]] = []
    var excersises: [[String: Any]] = []
    var patientFavorites: [[String: Any]] = []
    
    let screenTitle = "Hello  \(ApplicationSharedInfo.shared.loginResponse?.firstName ?? "")\nWe are happy to see you"
    let helloFont = UIFont(name: Fonts().lexendLight, size: 34)
    let userFont = UIFont(name: Fonts().lexendSemiBold, size: 34)
    let subTextFont = UIFont(name: Fonts().lexendLight, size: 14)
    
    @IBOutlet weak var myFavourites: UILabel!
    var languageId : Int = 1
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noFavsLabel.numberOfLines = 0
        self.navigationController?.isNavigationBarHidden = true
        setupLanguage()
        
        //title
        
        let text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? NSMutableAttributedString(string: "Hello \(ApplicationSharedInfo.shared.loginResponse!.firstName)\nWe are happy to see you") :
        NSMutableAttributedString(string: "Hola \(ApplicationSharedInfo.shared.loginResponse!.firstName)\nEstamos felices de verte")
        text.addAttributes([.font:helloFont!], range: text.mutableString.range(of:UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "Hello" : "Hola"))
        text.addAttributes([.font:userFont!], range: text.mutableString.range(of: ApplicationSharedInfo.shared.loginResponse!.firstName))
        text.addAttributes([.font:subTextFont!], range: text.mutableString.range(of:UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "We are happy to see you" : "Estamos felices de verte"))
        screenTitleLabel.attributedText = text
        
        //end

        NotificationCenter.default.addObserver(self, selector: #selector(updateFavorites), name: .favoritesUpdated, object: nil)  
        self.favorites = FavoriteManager.shared.favorites
        self.dashBoardCollectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.removeObserver(self, name: .favoritesUpdated, object: nil)
    }
    
    //MARK: - Add Favourites
    
    @objc func updateFavorites() {
        print("Received Notification - Updating Favorites")
        self.favorites = FavoriteManager.shared.favorites
        self.excersises = FavoriteManager.shared.exercises
        self.noFavsLabel.isHidden = !self.favorites.isEmpty
        print("✅ Favorites Updated: \(self.favorites.count), Exercises: \(self.excersises.count)")
        self.dashBoardCollectionView.reloadData()
        self.view.hideToastActivity()
    }
    
    
    private func fetchFavorites() {
        self.view.showToastActivity()
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else { return }

        FavoriteManager.shared.fetchFavoritesIfNeeded(
            plId: userInfo.patientLocationID,
            patientId: userInfo.patientID,
            clientId: userInfo.clientID,
            parentId: 0
        ) {
            UserDefaults.standard.set(true, forKey: "hasFetchedFavorites")
        }
    }
    
    //END
    
    @IBAction func didClickOnProfile(_ sender: UIButton) {
        let userProfileViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        self.navigationController?.pushViewController(userProfileViewController, animated: true)
        
    }
    var nomedications1 = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        let hasFetchedFavorites = UserDefaults.standard.bool(forKey: "hasFetchedFavorites")
        
        //VIV Fav API Call
        
        // Check token expiration before making API calls
        if TokenManager.shared.isTokenExpired() {
            print("Token expired, refreshing...")
            TokenManager.shared.refreshAccessToken(from: self) { success in
                DispatchQueue.main.async {
                    if success {
                        print("Token refreshed, proceeding with API call")
//                        self.geMenuItemsAPICalls()
                        if !hasFetchedFavorites {
                            self.fetchFavorites()
                            }
                    } else {
                        print("Token refresh failed")
                        self.view.showToast(message: "Token refresh failed")
                        // Handle failure (e.g., logout user, show alert)
                    }
                }
            }
        } else {
            print("Token is still valid, proceeding with API call")
//            geMenuItemsAPICalls()
            if !hasFetchedFavorites {
                       fetchFavorites()
                   }
        }
        
        //END
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        dashboardTableView.register(UINib(nibName: "DashboardMainTableCell", bundle: nil), forCellReuseIdentifier: "DashboardMainTableCell")
        dashboardTableView.dataSource = self
        dashboardTableView.delegate = self
        dashboardTableView.isScrollEnabled = true

        
        
        let nib = UINib(nibName: "HomeTabFavoritesCollectionViewCell", bundle: nil)
        
        dashBoardCollectionView.register(nib, forCellWithReuseIdentifier: "HomeTabFavoritesCollectionViewCell")
        
        dashBoardCollectionView.delegate = self
        dashBoardCollectionView.dataSource = self
        if let layout = dashBoardCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        dashBoardCollectionView.showsHorizontalScrollIndicator = false
        
        self.noFavsLabel.isHidden = true
   
    }
    
    //MARK: - Get Menu Items API Call
    
//    func geMenuItemsAPICalls() {
//        
//        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
//            fatalError("Unable to found Application Shared Info")
//        }
//        self.view.showToastActivity()
//        
//        UserDefaults.standard.removeObject(forKey: "favoriteExcersises")
//        getMeniItems(plId: userInfo.patientLocationID, patientId: userInfo.patientID, clientId: userInfo.clientID, parentId: 0) { [self] result in
//            switch result {
//            case .success(let data):
//                // Convert data to JSON object and print it
//                do {
//                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                        if let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
//                           let jsonString = String(data: jsonData, encoding: .utf8) {
//                            print("Json string -> \(jsonString)")  // Prints JSON in readable format
//                        }
//                        DispatchQueue.main.async {
//                            
////                            self.favorites = json["favorites"] as! [[String : Any]]
//                            self.excersises = self.favorites.filter({ if let abc = $0["isFromExercises"], abc as! Int == 1 {
//                                return true
//                            } else {return false}})
//                            var favExcercises: [ExcercisesModel] = []
//                            
//                            self.excersises.forEach {
//                                if let isFav = $0["isFavorite"] as? Int, let screenCode = $0["screenCode"] as? Int {
//                                    favExcercises.append(ExcercisesModel(isFav: isFav, screenCode: screenCode))
//                                }}
//
//                                UserDefaults.standard.set(try? PropertyListEncoder().encode(favExcercises), forKey: "favoriteExcersises")
//        
//                            if self.favorites.isEmpty{
//                                self.noFavsLabel.isHidden = false
//                            }
//                            else {
//                                self.noFavsLabel.isHidden = true
//                                print("self.favorites\(self.favorites)")
//                                self.dashBoardCollectionView.reloadData()
//                            }
//                            self.view.hideToastActivity()
//                            
//                        }
//                        
//                    } else {
//                        self.view.hideToastActivity()
//                        print("Unable to convert data to JSON")
//                    }
//                    
//                } catch {
//                    self.view.hideToastActivity()
//                    print("Error converting data to JSON: \(error)")
//                }
//            case .failure(let error):
//                print("Error: \(error)")
//            }
//        }
//        
//    }
    
    func setupLanguage() {
        
        languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        
        if languageId == 1 {
            UserDefaults.standard.set("en", forKey: "Language")
        } else if languageId == 2 {
            UserDefaults.standard.set("es", forKey: "Language")
        }
        
        noFavsLabel.text = AppHelper.getLocalizeString(str: "No favorites found for this patient")
        myFavourites.text = AppHelper.getLocalizeString(str: "My Favorites")
        actionButton.setAttributedTitleWithGradientDefaults(title: AppHelper.getLocalizeString(str: "Need to talk with someone?"))
        dashboardTableView.reloadData()
        
    }
    @objc func actionButtonTapped() {
        // Perform the action you want when the button is tapped
        let next = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController
        vc?.title = "Emergency resource"
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func getPatientFavorites(plId: Int, patientId: Int, clientId: Int,parentId: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard let url = URL(string: "\(baseURLString)patients/api/v1/course/getPatientFavorites") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(ApplicationSharedInfo.shared.tokenResponse?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        
        let payload: [String: Any] = [
            "plId": plId,
            "patientId": patientId,
            "parentId" : parentId,
            "clientId": clientId,
        ]
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
            
            // If needed, handle the response here
            completion(.success(data))
        }
        
        // Start the data task
        task.resume()
    }
    func getMeniItems(plId: Int, patientId: Int, clientId: Int,parentId: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        // Define the URL
        guard let url = URL(string: "\(baseURLString)identity/api/v1/menu/fetchMenus") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(ApplicationSharedInfo.shared.tokenResponse?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        
        let payload: [String: Any] = [
            "plId": plId,
            "patientId": patientId,
            "parentId" : parentId,
            "clientId": clientId,
        ]
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
            
            // If needed, handle the response here
            completion(.success(data))
        }
        
        // Start the data task
        task.resume()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardMainTableCell", for: indexPath) as! DashboardMainTableCell
        
        if (indexPath.row == 0) {
            cell.cellTitleLabel.text = languageId == 1 ? "My medical records" :  "Mis registros médicos"
            cell.cellImageView?.image = UIImage(named: "MyMedicalRecordsIcon")
        } else if (indexPath.row == 1){
            cell.cellTitleLabel.text = languageId == 1 ? "Weekly summary" : "Resumen semanal"
            cell.cellImageView?.image = UIImage(named: "weeklySummay1")
        } else if (indexPath.row == 2){
            cell.cellTitleLabel.text = languageId == 1 ? "Mental wellbeing tracker" : "Rastreador de bienestar mental"
            cell.cellImageView?.image = UIImage(named: "mentalWellbeing")
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 106
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let next = UIStoryboard(name: "UserMedicalRecords", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "UserMedicalRecordsViewController") as? UserMedicalRecordsViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if indexPath.row == 1 {
            let next = UIStoryboard(name: "WeeklySummaryDashboard", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "WeeklySummaryDashboardViewController") as? WeeklySummaryDashboardViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if indexPath.row == 2 {
            
            let next = UIStoryboard(name: "UserIntro", bundle: nil)
            if #available(iOS 16.0, *) {
                let vc = next.instantiateViewController(withIdentifier: "UserIntroDayFeedbackViewController") as? UserIntroDayFeedbackViewController
                
//                vc.titleString = "\(loginResponse.loginDetails.firstName)"
//                UserDefaults.standard.set("\(loginResponse.loginDetails.firstName)", forKey: "titleString")
                
                vc?.title = languageId == 1 ? "Mental wellbeing tracker" : "Rastreador de bienestar mental"
                vc?.hideSkipButton = true
                self.navigationController?.pushViewController(vc!, animated: true)
            } else {
                // Fallback on earlier versions
            }
            
        }
    }
    
    
}

extension HomeTabDashboardViewController : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        favorites.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeTabFavoritesCollectionViewCell", for: indexPath) as? HomeTabFavoritesCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let images = favorites[indexPath.row]
        
        
        if let imageUrlString = images["thumbnailUrl"] as? String, let url = URL(string: imageUrlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        cell.cellImageView.image = UIImage(data: data)
                    }
                }
            }
        }
        cell.titleLabel.text = images["title"] as? String
        
        // cell.cellImageView.image = UIImage(named: "HometabFavorites\(Int.random(in: 1...2))")
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedFavorite = favorites[indexPath.item]
        //        let patientselectedFavorite = patientFavorites[indexPath.item]
        
        if let favoritesId = selectedFavorite["favoritesId"] as? Int,
           let patientFavoriteId = selectedFavorite["favoritesId"] as? Int,
           favoritesId == patientFavoriteId {
            if let navigateURL = selectedFavorite["navigateURL"] as? String {
                
                print("navigateURL===\(navigateURL)")
                
                let next = UIStoryboard(name: "FavoritesVideosWebViewController", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "FavoritesVideosWebViewController") as? FavoritesVideosWebViewController
                vc?.favURL = navigateURL
                let newTitle = selectedFavorite["title"] as! String
                vc?.title = newTitle
                self.navigationController?.pushViewController(vc!, animated: true)
                
            }
        }
        if let isFromExcercise = selectedFavorite["isFromExercises"] as? Int, isFromExcercise == 1, let screenCode = selectedFavorite["screenCode"] as? Int  {
            let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
            let excerciseType = ExcercisesTypeEnum(rawValue: screenCode)
            
            // Push to the destination view controller
            self.navigationController?.pushViewController(excerciseType!.destVC, animated: true)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Return the size of each item in your collection view
        
        return CGSize(width: 160, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    
    
}
