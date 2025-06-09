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
    var tableAalrm = [5,10,15,20,25,30]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        settingsAlarmTable.dataSource = self
        settingsAlarmTable.delegate = self

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: Notification.Name("RemoveDimmingView"), object: nil)
    }

    
    @IBAction func okButtonPressed(_ sender: Any) {
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        guard let selectedIndex = selectedIndex else {
            let alertText = "Please select a time interval before proceeding."
            showGeneralAlert(
                image: UIImage(named: "InfoIcon"),
                imageSize: CGSize(width: 60, height: 60),
                title: alertText,
                okButtonTitle: AppHelper.getLocalizeString(str: "Ok"),
                okAction: {
                    print("Select a time interval")
                },
                dismissAction: {
                    print("Dismiss action triggered")
                }
            )
            return
        }
        
        let patientID = userInfo.patientID
        let email = userInfo.email
        alarm = selectedIndex
        
        let params: [String: Any] = ["patientId": patientID, "alarmDuration": alarm! as Int, "emailId": email]
        
        print("param for alarm duration is",params)
        
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
                    
                    UserDefaults.standard.set(alarm, forKey: "alarmPriorMinutes")
                    
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
        print("from cell the selected index is",selectedIndex as Any, "and the table alarm value is", tableAalrm[indexPath.row])

//        tickImage?.isHidden = selectedIndex != tableAalrm[indexPath.row]
        
        let isSelected = selectedIndex == tableAalrm[indexPath.row]
        tickImage?.isHidden = !isSelected

        if isSelected {
            let alarm = tableAalrm[indexPath.row]
            UserDefaults.standard.set(alarm, forKey: "alarmPriorMinutes")
        }
  
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = tableAalrm[indexPath.row]
        tableView.reloadData()
    }



}
