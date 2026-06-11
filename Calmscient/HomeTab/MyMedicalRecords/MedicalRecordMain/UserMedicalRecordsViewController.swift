//
//  UserMedicalRecordsViewController.swift
//  MainTabBarApp
//
//  Created by KA on 13/03/24.
//

import SwiftUI
import UIKit

class UserMedicalRecordsViewController: ViewController {

    @IBOutlet weak var medicalRecordsTableView: UITableView!

    private let medicalRecordRowImages: [UIImage] = [
        UIImage(named: "Medications_Cell")!,
        UIImage(named: "MedicalAppointment_Cell")!,
        UIImage(named: "Screening_Cell")!,
    ]
    /// Localization keys — titles use `Localized.strings` (en / es / ja).
    private let medicalRecordTitleKeys = [
        "Medications",
        "Upcoming medical appointments",
        "Screenings",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 16.0, *) {
            installSwiftUIMedicalRecordsHost()
        } else {
            installLegacyTableAndNavigation()
        }
    }

    @available(iOS 16.0, *)
    private func installSwiftUIMedicalRecordsHost() {
        medicalRecordsTableView?.isHidden = true
        medicalRecordsTableView?.removeFromSuperview()

        let host = UserMedicalRecordsHostingController()
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        host.didMove(toParent: self)
    }

    private func installLegacyTableAndNavigation() {
        self.navigationController?.isNavigationBarHidden = false

        medicalRecordsTableView.register(UINib(nibName: "MyMedicalRecordsCell", bundle: nil), forCellReuseIdentifier: "MyMedicalRecordsCell")
        medicalRecordsTableView.dataSource = self
        medicalRecordsTableView.delegate = self
        medicalRecordsTableView.separatorStyle = .none
        self.navigationController?.navigationBar.isHidden = false

        let button: UIButton = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: "profileIcon.png"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(profileButtonPressed), for: .touchUpInside)
        button.frame = CGRectMake(0, 0, 32, 32)

        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton

        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)

        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonOverrideAction), for: .touchUpInside)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true

        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
    }

    @objc func backButtonOverrideAction() {
        if #available(iOS 16.0, *) {
            let homeRoot = HomeDashboardHostingController()
            self.navigationController?.pushViewController(homeRoot, animated: true)
        } else {
            let storyboard = UIStoryboard(name: "DashboardHomeTab", bundle: nil)
            if let homeTabVC = storyboard.instantiateViewController(withIdentifier: "HomeTabDashboardViewController") as? HomeTabDashboardViewController {
                self.navigationController?.pushViewController(homeTabVC, animated: true)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 16.0, *) {
            navigationController?.setNavigationBarHidden(false, animated: animated)
            navigationController?.navigationBar.isHidden = false
        } else {
            self.navigationItem.title = "My medical records".localized
            medicalRecordsTableView.reloadData()
        }
    }

    @objc func profileButtonPressed() {
        let userProfileViewController = UserProfileHostingController()
        userProfileViewController.shouldPopBack = true
        UserDefaults.standard.removeObject(forKey: "shouldPopToDis")
        self.navigationController?.pushViewController(userProfileViewController, animated: true)
    }
}

extension UserMedicalRecordsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMedicalRecordsCell", for: indexPath) as! MyMedicalRecordsCell
        cell.medicalCellImage.image = medicalRecordRowImages[indexPath.row]
        cell.titleTextField.text = medicalRecordTitleKeys[indexPath.row].localized
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        172
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            if #available(iOS 16.0, *) {
                let next = UIStoryboard(name: "UserMedications", bundle: nil)
                if let vc = next.instantiateViewController(withIdentifier: "UserMedicationsViewController") as? UserMedicationsViewController {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else if indexPath.row == 1 {
            if #available(iOS 16.0, *) {
                self.navigationController?.pushViewController(NextAppointmentsHostingController(), animated: true)
            }
        } else {
            let next = UIStoryboard(name: "ScreeningListVC", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "ScreeningListVC") as? ScreeningListVC
            if let vc { self.navigationController?.pushViewController(vc, animated: true) }
        }
    }
}
