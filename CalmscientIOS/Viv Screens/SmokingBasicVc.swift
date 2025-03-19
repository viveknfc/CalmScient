//
//  SmokingBasicVc.swift
//  CalmscientIOS
//
//  Created by NFC User on 27/12/24.
//

import UIKit

class SmokingBasicVc: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "CustomCheckboxCell", bundle: nil), forCellReuseIdentifier: "CustomCheckboxCell")
        tableView.rowHeight = UITableView.automaticDimension

        // Do any additional setup after loading the view.
    }
    
    let data = ["What is tobacco?", "How is vaping safer than tobacco?", "Why does smoking seem to relax me?", "Why is it challenging to quit?", "How does smoking affect your mental health?", "My smoking habit"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCheckboxCell", for: indexPath) as! CustomCheckboxCell
        let newData = data[indexPath.row]
        cell.customLabel.text = newData
     
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "TobacoViewController") as? TobacoViewController
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if indexPath.row == 1 {
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "VapingViewController") as? VapingViewController
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if indexPath.row == 2 {
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "SmokingRelaxVC") as? SmokingRelaxVC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if indexPath.row == 3 {
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "ChallengingtoQuitVC") as? ChallengingtoQuitVC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if indexPath.row == 4 {
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "SmokingAffectMentalHealthVC") as? SmokingAffectMentalHealthVC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if indexPath.row == 5 {
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "MySmokingHabitVC") as? MySmokingHabitVC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    

    @IBAction func completeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
