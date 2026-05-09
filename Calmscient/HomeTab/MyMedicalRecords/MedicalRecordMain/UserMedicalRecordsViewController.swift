//
//  UserMedicalRecordsViewController.swift
//  MainTabBarApp
//
//  Created by KA on 13/03/24.
//

import UIKit

class UserMedicalRecordsViewController: ViewController {

    @IBOutlet weak var medicalRecordsTableView: UITableView!

    private let medicalRecordRowImages: [UIImage] = [
        UIImage(named: "Medications_Cell")!,
        UIImage(named: "MedicalAppointment_Cell")!,
        UIImage(named: "Screening_Cell")!
    ]
    /// Localization keys — titles use `Localized.strings` (en / es / ja).
    private let medicalRecordTitleKeys = [
        "Medications",
        "Upcoming medical appointments",
        "Screenings"
    ]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = false

        medicalRecordsTableView.register(UINib(nibName: "MyMedicalRecordsCell", bundle: nil), forCellReuseIdentifier: "MyMedicalRecordsCell")
        if #available(iOS 16.0, *) {
            medicalRecordsTableView.dataSource = self
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 16.0, *) {
            medicalRecordsTableView.delegate = self
        } else {
            // Fallback on earlier versions
        }
        medicalRecordsTableView.separatorStyle = .none
        self.navigationController?.navigationBar.isHidden = false
        
        //Nav right bar button start
        
        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
                //set image for button
        button.setImage(UIImage(named: "profileIcon.png"), for: UIControl.State.normal)
                //add function for button
        button.addTarget(self, action: #selector(profileButtonPressed), for: .touchUpInside)
                //set frame
                button.frame = CGRectMake(0, 0, 32, 32)

                let barButton = UIBarButtonItem(customView: button)
                //assign button to navigationbar
                self.navigationItem.rightBarButtonItem = barButton
        
        // end
        
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
        let storyboard = UIStoryboard(name: "DashboardHomeTab", bundle: nil)
        if let homeTabVC = storyboard.instantiateViewController(withIdentifier: "HomeTabDashboardViewController") as? HomeTabDashboardViewController {
            self.navigationController?.pushViewController(homeTabVC, animated: true)
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationItem.title = "My medical records".localized
        medicalRecordsTableView.reloadData()

    }
    @objc func profileButtonPressed() {

        let userProfileViewController = UIStoryboard(name: "UserProfile", bundle: nil).instantiateViewController(withIdentifier: "UserProfileViewController") as! UserProfileViewController
        userProfileViewController.shouldPopBack = true
        UserDefaults.standard.removeObject(forKey: "shouldPopToDis")
        self.navigationController?.pushViewController(userProfileViewController, animated: true)
        }
}

@available(iOS 16.0, *)
extension UserMedicalRecordsViewController : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMedicalRecordsCell", for: indexPath) as! MyMedicalRecordsCell
        cell.medicalCellImage.image = medicalRecordRowImages[indexPath.row]
        cell.titleTextField.text = medicalRecordTitleKeys[indexPath.row].localized
//        cell.addShadowAndBorder()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       return 172
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let next = UIStoryboard(name: "UserMedications", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "UserMedicationsViewController") as? UserMedicationsViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if indexPath.row == 1 {
            let next = UIStoryboard(name: "NextAppointments", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "NextAppointmentsViewController") as? NextAppointmentsViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
            let next = UIStoryboard(name: "ScreeningListVC", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "ScreeningListVC") as? ScreeningListVC
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
    }
    
}
