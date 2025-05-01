//
//  settingsAlarmVCViewController.swift
//  CalmscientIOS
//
//  Created by NFC User on 26/04/25.
//

import UIKit

protocol SettingsAlarmDelegate: AnyObject {
    func didUpdateAlarmValue(_ newValue: Int)
}


class settingsAlarmVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var settingsAlarmTable: UITableView!
    @IBOutlet weak var tableCell: UITableViewCell!
    @IBOutlet weak var tableLabel: UILabel!
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var okButton: UIButton!
    
    var selectedIndex: Int? = nil
    var alarm: Int?
    
    weak var delegate: SettingsAlarmDelegate?

    
    var tableData = ["5 min", "10 min", "15 min", "20 min", "25 min", "30 min"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        settingsAlarmTable.dataSource = self
        settingsAlarmTable.delegate = self

    }
    
    @IBAction func okButtonPressed(_ sender: Any) {
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let patientID = userInfo.patientID
        let email = userInfo.email
        alarm = selectedIndex ?? 0
        
        let params: [String: Any] = ["patientId": patientID, "alarmDuration": alarm! as Int, "emailId": email]
        
        self.view.showToastActivity()
        APIService.alarmSettingsAPICalling(
            self,
            params: params,
            method: "POST",
            accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken,
            acces: false,
            parameterPlacement: "body"
        ) { response in
            self.getresponseforOkAPI(response: response)
        }

   
    }
    
    //MARK: - Ok API response
    
    func getresponseforOkAPI(response:AnyObject)->() {
        self.view.hideToastActivity()
        if let responseString = response as? String {
            print("Response received from alarm setting api calling is", responseString)
        } else if let responseDict = response as? [String: Any] {
            print("the alarm setting api response is", responseDict)
            
            if let responseMessage = responseDict["responseMessage"] as? String {
                self.showSuccessAlert(successContent: responseMessage, centreImage: nil, okButtonAction: { [self] in
                    self.delegate?.didUpdateAlarmValue(self.alarm ?? 0)
                    NotificationCenter.default.post(name: Notification.Name("RemoveDimmingView"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                })
            }
            
        } else {
            print("Unsupported response type:", type(of: response))
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        print("Cancel button pressed.")
        NotificationCenter.default.post(name: Notification.Name("RemoveDimmingView"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath)
        
        // Assuming your custom cell has these outlets
        let label = cell.viewWithTag(1) as? UILabel
        let tickImage = cell.viewWithTag(2) as? UIImageView
        
        label?.text = tableData[indexPath.row]
        tickImage?.isHidden = selectedIndex != indexPath.row
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }



}
