//
//  WeeklySummaryDashboardViewController.swift
//  CalmscientIOS
//
//  Created by NFC on 28/04/24.
//

import UIKit
import Network


class WeeklySummaryDashboardViewController: ViewController {
    var collectionItems:[WeeklySummaryItems] = [.WeeklySummarySummaryOfMood,.WeeklySummarySummaryOfSleep,.WeeklySummarySummaryOfPHQ9,.WeeklySummarySummaryOfGAD,.WeeklySummarySummaryOfAudit,.WeeklySummarySummaryOfDast, .WeeklySummaryCAGE, .WeeklySummaryProgressOnCourseWork,.WeeklySummaryJournalEntry]
    var spanishCollection:[String] = ["Resumen del Estado de Ánimo","Resumen del Sueño","Resumen del PHQ-9","Resumen del GAD","Resumen de la Auditoría","Resumen del DAST-10","Progreso en el Trabajo del Curso","Entrada del Diario"]
    // MARK: - Network Monitor
        private let networkMonitor = NWPathMonitor()
        private var hasNetworkConnection: Bool = true
    private lazy var dashboardCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let cellWidth = self.view.bounds.width - 42
        flowLayout.itemSize = CGSize(width: cellWidth / 2, height: 125)
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10)
        flowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = true
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        let nib = UINib(nibName: "WeeklySummaryDashboardCell", bundle: nil)
        dashboardCollectionView.backgroundColor = UIColor(named: "AppBackGroundColor")
        dashboardCollectionView.register(nib, forCellWithReuseIdentifier: "WeeklySummaryDashboardCell")
        dashboardCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "YourCellIdentifier")
        dashboardCollectionView.isPagingEnabled = false
        dashboardCollectionView.isScrollEnabled = true
        dashboardCollectionView.delegate = self
        dashboardCollectionView.bounces = true
        dashboardCollectionView.dataSource = self
        dashboardCollectionView.showsHorizontalScrollIndicator = false
        dashboardCollectionView.showsVerticalScrollIndicator = true
        dashboardCollectionView.alwaysBounceHorizontal = false
        dashboardCollectionView.alwaysBounceVertical = true
        
        self.view.addSubview(dashboardCollectionView)
        dashboardCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dashboardCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            dashboardCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            dashboardCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            dashboardCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        dashboardCollectionView.collectionViewLayout.invalidateLayout()
        dashboardCollectionView.reloadData()
        
               // MARK: - Start Network Monitoring
               startNetworkMonitoring()
        //Nav right bar button start
        
        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
                //set image for button
        button.setImage(UIImage(named: "profileIcon.png"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(profileButtonPressed), for: .touchUpInside)
                //set frame
                button.frame = CGRectMake(0, 0, 32, 32)

                let barButton = UIBarButtonItem(customView: button)
                //assign button to navigationbar
//                self.navigationItem.rightBarButtonItem = barButton

    }
    
    // MARK: - Network Monitor Setup
       private func startNetworkMonitoring() {
           networkMonitor.pathUpdateHandler = { [weak self] path in
               self?.hasNetworkConnection = (path.status == .satisfied)
           }
           networkMonitor.start(queue: DispatchQueue(label: "NetworkMonitor"))
       }
       
       deinit {
           networkMonitor.cancel()
       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.title =  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Weekly summary" : "Resumen semanal"

    }
    
    @objc func profileButtonPressed() {

        let userProfileViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        UserDefaults.standard.removeObject(forKey: "shouldPopToDis")
        self.navigationController?.pushViewController(userProfileViewController, animated: true)
        }
}

extension WeeklySummaryDashboardViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionItems.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeeklySummaryDashboardCell", for: indexPath) as? WeeklySummaryDashboardCell else {
            return UICollectionViewCell()
        }
        cell.cellImageView.image = UIImage(named: collectionItems[indexPath.row].getAssetName())
        cell.cellTitleLabel.text = collectionItems[indexPath.row].localized
        return cell
    }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // MARK: - Internet Check Before Navigation
              guard hasNetworkConnection else {
                  let noInternetMsg = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1
                      ? "No internet connection. Please try again."
                      : "Sin conexión a internet. Por favor, inténtalo de nuevo."
                  DispatchQueue.main.async {
                      NoInternetBanner.shared.openDetails()
                  }
                  return
              }
        
        if (indexPath.row >= 0  && indexPath.row <= 6) {
            let next = UIStoryboard(name: "WeeklySummaryGraphResults", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "WeeklySummaryGraphViewController") as? WeeklySummaryGraphViewController
            vc?.summaryType = collectionItems[indexPath.row]
            vc?.title = collectionItems[indexPath.row].localized
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if indexPath.row == 7 {
            let next = UIStoryboard(name: "ProgressOnWorkMain", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "ProgressOnWorkMainViewController") as? ProgressOnWorkMainViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if indexPath.row == collectionItems.count - 1 {
            let next = UIStoryboard(name: "JournalEntryViewController", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "JournalEntryViewController") as? JournalEntryViewController
            vc?.title = collectionItems[indexPath.row].localized
            self.navigationController?.pushViewController(vc!, animated: true)
        }
      
    }
    
    
}

