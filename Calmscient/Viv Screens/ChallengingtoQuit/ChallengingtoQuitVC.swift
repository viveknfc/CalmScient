//
//  ChallengingtoQuitVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 30/12/24.
//

import UIKit

class ChallengingtoQuitVC: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    var sectionID4: Int?
    
    var data: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

    data = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? edata : sdata
        
    tableView.register(UINib(nibName: "CapsuleStyleCell", bundle: nil), forCellReuseIdentifier: "CapsuleCell")
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorStyle = .none
        
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
    
    let edata = ["“I’m thinking about quitting”", "“Getting ready to quit”", "“Quitting”", "“Staying smoke-free”"]
    
    let sdata = ["“Estoy pensando en dejarlo”", "“Preparándote para dejar de fumar”", "“Dejar de fumar”", "“Mantenerse libre de fumar”"]
    
    
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
    
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
        completeButtonAPICall()
    }
    
    //MARK: - Complete Button API Call
    
    func completeButtonAPICall() {
        self.view.showToastActivity()
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Any] = [
            "isCompleted":1,
            "patientId": userInfo.patientID,
            "sectionId":sectionID4 ?? 0
        ]

        APIService.SUpdateBasicKAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            self.getresponseforBasicKnowAPI(response: response)
        }
    }
    
    //MARK: - Complete Button API Response
    
    func getresponseforBasicKnowAPI(response: Any) {
        self.view.hideToastActivity()
        
        if let responseDict = response as? [String: Any] {
            
            print("Response from Basic standard complete button:", responseDict)
            self.navigationController?.popViewController(animated: true)
            
        } else {
            print("Unsupported response type:", type(of: response))
        }
    }
    
    
    

}
