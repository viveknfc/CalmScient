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
        
        data = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? edata : sdata
        
        let selectedLanguageID = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        let title = selectedLanguageID == 1 ? "Complete" : "Finalizar"
        completeButton.setTitle(title, for: .normal)
        completeButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    let edata = ["Nicotine cravings", "Irritability and mood swings", "Difficulty concentrating", "Increased appetite and weight gain", "Sleep disturbances", "Depression and anxiety", "Feeling jumpy or restless"]
    
    let sdata = ["Deseos de nicotina", "Irritabilidad y cambios de humor", "Dificultad para concentrarse", "Aumento del apetito y aumento de peso", "Trastornos de sueño", "Depresión y ansiedad", "Sentirse nervioso o inquieto"]
    
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
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    


}
