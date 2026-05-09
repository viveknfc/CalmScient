//
//  ReadyToQuitVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 02/01/25.
//

import UIKit

class ReadyToQuitVC: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    
    var data: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "CapsuleStyleCell", bundle: nil), forCellReuseIdentifier: "CapsuleCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        data = Self.localizedData
        
        completeButton.setTitle("Complete".localized, for: .normal)
        completeButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    static let localizedData: [String] = [
        "Nicotine cravings".localized,
        "Irritability and mood swings".localized,
        "Difficulty concentrating".localized,
        "Increased appetite and weight gain".localized,
        "Sleep disturbances".localized,
        "Depression and anxiety".localized,
        "Feeling jumpy or restless".localized
    ]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CapsuleCell", for: indexPath) as! CapsuleTableViewCell
        
        cell.tableText.text = data[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0) {
            let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
            if let customAlertVC = storyboard.instantiateViewController(withIdentifier: "NicotinCarvingVC") as? NicotinCarvingVC {
                customAlertVC.modalPresentationStyle = .overFullScreen
                customAlertVC.modalTransitionStyle = .crossDissolve
                self.present(customAlertVC, animated: true, completion: nil)
            }
        } else if (indexPath.row == 1) {
            let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
            if let customAlertVC = storyboard.instantiateViewController(withIdentifier: "IrritabilityViewController") as? IrritabilityViewController {
                customAlertVC.modalPresentationStyle = .overFullScreen
                customAlertVC.modalTransitionStyle = .crossDissolve
                self.present(customAlertVC, animated: true, completion: nil)
            }
        } else if (indexPath.row == 2) {
            let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
            if let customAlertVC = storyboard.instantiateViewController(withIdentifier: "DifficultyViewController") as? DifficultyViewController {
                customAlertVC.modalPresentationStyle = .overFullScreen
                customAlertVC.modalTransitionStyle = .crossDissolve
                self.present(customAlertVC, animated: true, completion: nil)
            }
        } else if (indexPath.row == 3) {
            let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
            if let customAlertVC = storyboard.instantiateViewController(withIdentifier: "IncreasedViewController") as? IncreasedViewController {
                customAlertVC.modalPresentationStyle = .overFullScreen
                customAlertVC.modalTransitionStyle = .crossDissolve
                self.present(customAlertVC, animated: true, completion: nil)
            }
        } else if (indexPath.row == 4) {
            let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
            if let customAlertVC = storyboard.instantiateViewController(withIdentifier: "SleepDistrubanceVC") as? SleepDistrubanceVC {
                customAlertVC.modalPresentationStyle = .overFullScreen
                customAlertVC.modalTransitionStyle = .crossDissolve
                self.present(customAlertVC, animated: true, completion: nil)
            }
        } else if (indexPath.row == 5) {
            let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
            if let customAlertVC = storyboard.instantiateViewController(withIdentifier: "DepressionnAnxietyVC") as? DepressionnAnxietyVC {
                customAlertVC.modalPresentationStyle = .overFullScreen
                customAlertVC.modalTransitionStyle = .crossDissolve
                self.present(customAlertVC, animated: true, completion: nil)
            }
        } else if (indexPath.row == 6) {
            let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
            if let customAlertVC = storyboard.instantiateViewController(withIdentifier: "FeelingJumpyVC") as? FeelingJumpyVC {
                customAlertVC.modalPresentationStyle = .overFullScreen
                customAlertVC.modalTransitionStyle = .crossDissolve
                self.present(customAlertVC, animated: true, completion: nil)
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    


}
