//
//  ChallengingtoQuitVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 30/12/24.
//

import UIKit

class ChallengingtoQuitVC: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    tableView.register(UINib(nibName: "CapsuleStyleCell", bundle: nil), forCellReuseIdentifier: "CapsuleCell")
    tableView.delegate = self
    tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    let data = ["“I’m thinking about quitting”", "“Getting ready to quit”", "“Quitting”", "“Staying smoke-free”"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CapsuleCell", for: indexPath) as! CapsuleTableViewCell
        
        cell.tableText.text = data[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            
//            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
//            let vc = next.instantiateViewController(withIdentifier: "testVC") as? testVC
//            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
//            self.navigationController?.pushViewController(vc!, animated: true)
            
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "ThinkingAbtQuitingVC") as? ThinkingAbtQuitingVC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
        if indexPath.row == 1{
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "ReadyToQuitVC") as? ReadyToQuitVC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
        if indexPath.row == 2{
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "TryingToQuitVC") as? TryingToQuitVC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
        if indexPath.row == 3{
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "TobaccoFreeVC") as? TobaccoFreeVC
            vc?.title = AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        }
    }
    

}
