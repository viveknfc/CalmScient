//
//  HomeTabDashboardViewController.swift
//  MainTabBarApp
//
//  Created by KA on 23/04/24.
//

import UIKit

class HomeTabDashboardViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    
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
    
    var nomedications1 = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        setupViews()
        
        checkTokenAndFetchFavorites()
   
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        noFavsLabel.numberOfLines = 0
        self.navigationController?.isNavigationBarHidden = true
        setupLanguage()

        // Safely unwrap loginResponse
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            print("Error: loginResponse is nil")
            return
        }

        // Title
        let greeting = "Hello".localized
        let subText = "We are happy to see you".localized
        let firstName = loginResponse.firstName

        let text = NSMutableAttributedString(string: "\(greeting) \(firstName)\n\(subText)")
        text.addAttributes([.font: helloFont!], range: text.mutableString.range(of: greeting))
        text.addAttributes([.font: userFont!], range: text.mutableString.range(of: firstName))
        text.addAttributes([.font: subTextFont!], range: text.mutableString.range(of: subText))
        screenTitleLabel.attributedText = text

        setupObservers()
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
    
    
    // MARK: - Token & API
    private func checkTokenAndFetchFavorites() {
        let hasFetchedFavorites = UserDefaults.standard.bool(forKey: "hasFetchedFavorites")

        if TokenManager.shared.isTokenExpired() {
            print("Token expired, refreshing...")
            TokenManager.shared.refreshAccessToken(from: self) { success in
                DispatchQueue.main.async {
                    if success {
                        print("Token refreshed, proceeding with API call")
                        if !hasFetchedFavorites { self.fetchFavorites() }
                    } else {
                        self.handleTokenFailure()
                    }
                }
            }
        } else {
            print("Token is still valid, proceeding with API call")
            if !hasFetchedFavorites { self.fetchFavorites() }
        }
    }
    
    private func handleTokenFailure() {
        UserDefaults.standard.set(0, forKey: "rememberMe")
        UserDefaultsHelper.clearLoginDetailsFromUserDefaults()
        ApplicationSharedInfo.shared.loginResponse = nil
        ApplicationSharedInfo.shared.tokenResponse = nil

        if #available(iOS 16.0, *) {
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                let navController = LoginHostingController.loginNavigationRoot()
                sceneDelegate.changeRootViewController(to: navController)
            }
        }
    }
    
    @IBAction func didClickOnProfile(_ sender: UIButton) {
        let userProfileViewController = UserProfileHostingController()
        UserDefaults.standard.removeObject(forKey: "shouldPopToDis")
        self.navigationController?.pushViewController(userProfileViewController, animated: true)
        
    }
    
    //MARK: - Setup Views
    
    private func setupViews() {
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        
        dashboardTableView.register(UINib(nibName: "DashboardMainTableCell", bundle: nil), forCellReuseIdentifier: "DashboardMainTableCell")
        dashboardTableView.dataSource = self
        dashboardTableView.delegate = self
        dashboardTableView.isScrollEnabled = true
        dashboardTableView.separatorStyle = .none
        
        let nib = UINib(nibName: "HomeTabFavoritesCollectionViewCell", bundle: nil)
        dashBoardCollectionView.register(nib, forCellWithReuseIdentifier: "HomeTabFavoritesCollectionViewCell")
        dashBoardCollectionView.delegate = self
        dashBoardCollectionView.dataSource = self
        if let layout = dashBoardCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        dashBoardCollectionView.showsHorizontalScrollIndicator = false
        
        noFavsLabel.isHidden = true
    }
    
    //MARK: - Setup Observers
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateFavorites), name: .favoritesUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchFavorites), name: .favLanUpdated, object: nil)
    }
    
    // MARK: - Language
    func setupLanguage() {
        
noFavsLabel.text = AppHelper.getLocalizeString(str: "No favorites found for this patient")
        myFavourites.text = AppHelper.getLocalizeString(str: "My Favorites")
        actionButton.setAttributedTitleWithGradientDefaults(title: AppHelper.getLocalizeString(str: "Need to talk with someone?"))
        actionButton.applyNeedToTalkButtonVisibility()
        dashboardTableView.reloadData()
        
        // Notify observers that language has changed
        NotificationCenter.default.post(name: .languageChanged, object: nil)
    }
    
    // MARK: - Favorites
    @objc private func fetchFavorites() {
        print("fetch fav")
        self.view.showToastActivity()
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else { return }

        FavoriteManager.shared.fetchFavoritesIfNeeded(
            plId: userInfo.patientLocationID,
            patientId: userInfo.patientID,
            clientId: userInfo.clientID,
            parentId: 0
        ) {
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: "hasFetchedFavorites")
                self.updateFavorites()
            }
        }
    }

    @objc func actionButtonTapped() {
        // Perform the action you want when the button is tapped
        let next = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController
        vc?.title = "Emergency resource"
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashboardMainTableCell", for: indexPath) as! DashboardMainTableCell
        
        if (indexPath.row == 0) {
            cell.cellTitleLabel.text = "My medical records".localized
            cell.cellImageView?.image = UIImage(named: "MyMedicalRecordsIcon")
        } else if (indexPath.row == 1){
            cell.cellTitleLabel.text = "Weekly summary".localized
            cell.cellImageView?.image = UIImage(named: "weeklySummay1")
        } else if (indexPath.row == 2){
            cell.cellTitleLabel.text = "Mental wellbeing tracker".localized
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
            if #available(iOS 16.0, *) {
                self.navigationController?.pushViewController(UserMedicalRecordsHostingController(), animated: true)
            } else {
                let next = UIStoryboard(name: "UserMedicalRecords", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "UserMedicalRecordsViewController") as? UserMedicalRecordsViewController
                if let vc { self.navigationController?.pushViewController(vc, animated: true) }
            }
        } else if indexPath.row == 1 {
            if #available(iOS 16.0, *) {
                navigationController?.pushViewController(WeeklySummaryDashboardHostingController(), animated: true)
            } else {
                let next = UIStoryboard(name: "WeeklySummaryDashboard", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "WeeklySummaryDashboardViewController") as? WeeklySummaryDashboardViewController
                if let vc { navigationController?.pushViewController(vc, animated: true) }
            }
        } else if indexPath.row == 2 {
            if #available(iOS 16.0, *) {
                let vc = DayFeedbackHostingController(
                    hideSkipButton: true,
                    dashboardNavigationTitle: "Mental wellbeing tracker".localized
                )
                self.navigationController?.pushViewController(vc, animated: true)
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
            let config = URLSessionConfiguration.default
            config.waitsForConnectivity = true // Ensures better network handling
            let session = URLSession(configuration: config)

            session.dataTask(with: url) { data, _, error in
                if let data = data, error == nil, let image = UIImage(data: data) {
                    DispatchQueue.main.async(qos: .userInitiated) {
                        cell.cellImageView.image = image
                    }
                }
            }.resume()
        }

        cell.titleLabel.text = images["title"] as? String
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedFavorite = favorites[indexPath.item]
        
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
            print("the screen code is",screenCode)
            print("is from excerise value is ",isFromExcercise)
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
