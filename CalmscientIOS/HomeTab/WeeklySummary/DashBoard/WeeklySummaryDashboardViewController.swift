//
//  WeeklySummaryDashboardViewController.swift
//  CalmscientIOS
//
//  Created by NFC on 28/04/24.
//

import UIKit

class WeeklySummaryDashboardViewController: ViewController {
    var collectionItems:[WeeklySummaryItems] = [.WeeklySummarySummaryOfMood,.WeeklySummarySummaryOfSleep,.WeeklySummarySummaryOfPHQ9,.WeeklySummarySummaryOfGAD,.WeeklySummarySummaryOfAudit,.WeeklySummarySummaryOfDast,.WeeklySummaryProgressOnCourseWork,.WeeklySummaryJournalEntry]
    var spanishCollection:[String] = ["Resumen del Estado de Ánimo","Resumen del Sueño","Resumen del PHQ-9","Resumen del GAD","Resumen de la Auditoría","Resumen del DAST-10","Progreso en el Trabajo del Curso","Entrada del Diario"]
    private lazy var dashboardCollectionView:UICollectionView = {
        let customFlowLayout:CustomCollectionViewLayout = CustomCollectionViewLayout()
        let cellWidth = self.view.bounds.width - 42
        customFlowLayout.cellSize = CGSize(width: cellWidth/2, height: 125)
        customFlowLayout.cellSpacing = 10
        customFlowLayout.collectionView?.alwaysBounceHorizontal = false
        customFlowLayout.collectionViewInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 10)
        return UICollectionView(frame: self.view.frame, collectionViewLayout: customFlowLayout)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        let nib = UINib(nibName: "WeeklySummaryDashboardCell", bundle: nil)
        dashboardCollectionView.backgroundColor = UIColor(named: "AppBackGroundColor")
        dashboardCollectionView.register(nib, forCellWithReuseIdentifier: "WeeklySummaryDashboardCell")
        dashboardCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "YourCellIdentifier")
        dashboardCollectionView.isPagingEnabled = false
        dashboardCollectionView.isScrollEnabled = false
        dashboardCollectionView.delegate = self
        dashboardCollectionView.bounces = false
        dashboardCollectionView.dataSource = self
        dashboardCollectionView.showsHorizontalScrollIndicator = false
        dashboardCollectionView.showsVerticalScrollIndicator = false
        dashboardCollectionView.alwaysBounceHorizontal = false
        dashboardCollectionView.alwaysBounceVertical = false
        
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
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.title =  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Weekly summary" : "Resumen semanal"

    }
    
    @objc func profileButtonPressed() {

        let userProfileViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
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
        
        
        if (indexPath.row >= 0  && indexPath.row <= 5) {
            let next = UIStoryboard(name: "WeeklySummaryGraphResults", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "WeeklySummaryGraphViewController") as? WeeklySummaryGraphViewController
            vc?.summaryType = collectionItems[indexPath.row]
            vc?.title = collectionItems[indexPath.row].localized
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if indexPath.row == 6 {
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
