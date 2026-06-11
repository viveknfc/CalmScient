//
//  TakingControllIntro.swift
//  CalmscientIOS
//
//  Created by mac on 25/05/24.
//

import Foundation
import UIKit

class TakingControllIntro: ViewController,UITableViewDelegate,UITableViewDataSource { //QuestionAlertAlertViewActionProtocol
    var screeningData:[Screening] = []
    var previouslySelectedIndexPath: Int?
    var networkHandler:NetworkAPIRequest = NetworkAPIRequest()
    let screeningRequest = ScreeningListRequestForm()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var infoButton: UIButton!
    
    var data: [String] = []
    var introData: [Any] = []
    
    var auditFlag: Int = 1
    var dastFlag: Int = 1
    var cageFlag: Int = 1
    
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    var doesttext = ""
    var applytometext = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
       
        getScreeningData()
        tableView.dataSource = self
        tableView.delegate = self
        
        title = AppHelper.getLocalizeString(str: "Taking control introduction")
        self.navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "CustomCell")
        
        getTakingControlIntroAPICalling()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        data = [
            AppHelper.getLocalizeString(str: "AUDIT"),
            AppHelper.getLocalizeString(str: "DAST-10"),
            AppHelper.getLocalizeString(str: "CAGE")
        ]
        
        headerLabel.text = AppHelper.getLocalizeString(str: "Welcome to taking control!")
        descriptionLabel.text = AppHelper.getLocalizeString(str: "Thank you for being willing to talk about alcohol and drugs. Now let’s begin with a brief assessment.")
        
        doesttext = AppHelper.getLocalizeString(str: "Doesn't apply to me")
        applytometext = AppHelper.getLocalizeString(str: "Apply to me")

    }

    
    //MARK: - Get Taking Control Intro Data API Calling
    
    func getTakingControlIntroAPICalling() {
        self.view.showToastActivity()
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Any] = [
            "clientId":userInfo.clientID,
            "patientId": userInfo.patientID,
            "plId":userInfo.patientLocationID
        ]
        
        print("param for getTakingControlIntroAPICalling is, ", params)

        APIService.getTakingControlIntroAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            self.getresponseforGetTakingControlIntroAPI(response: response)
        }
    }
    
    //MARK: - Get Taking Control Intro Data API Response
    
    func getresponseforGetTakingControlIntroAPI(response: Any) {
        self.view.hideToastActivity()
        
        if let responseDict = response as? [String: Any] {
            print("Response from Get Taking Control Intro Data:", responseDict)

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                let decodedResponse = try JSONDecoder().decode(IntroductionResponse.self, from: jsonData)

                auditFlag = decodedResponse.takingControlIntroduction.result.auditFlag
                cageFlag = decodedResponse.takingControlIntroduction.result.cageFlag
                dastFlag = decodedResponse.takingControlIntroduction.result.dastFlag

                print("Audit Flag: \(String(describing: auditFlag))")
                print("Cage Flag: \(String(describing: cageFlag))")
                print("DAST Flag: \(String(describing: dastFlag))")

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                // 👉 You can now use these flags however you want (e.g. update UI)

            } catch {
                print("Decoding failed with error:", error)
            }

        } else {
            print("Unsupported response type:", type(of: response))
        }
    }

    //END
    
    //MARK: - Save Taking Control Intro Data API Calling
    
    func saveTakingControlIntroAPICalling() {
        self.view.showToastActivity()
        
        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        
        let params: [String: Any] = [
            "clientId":userInfo.clientID,
            "patientId": userInfo.patientID,
            "plId":userInfo.patientLocationID,
            "introductionFlag": 0,
            "auditFlag": auditFlag,
            "dastFlag": dastFlag,
            "cageFlag": cageFlag,
            "tutorialFlag": 0
        ]
        
        print("param for saveTakingControlIntroAPICalling is, ", params)

        APIService.saveTakingControlIntroAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
            self.getresponseforSaveTakingControlIntroAPI(response: response)
        }
    }
    
    //MARK: - Save Taking Control Intro Data API Response
    
    func getresponseforSaveTakingControlIntroAPI(response: Any) {
        self.view.hideToastActivity()
        
        if let responseDict = response as? [String: Any] {
            print("Response from Get Taking Control Intro Data:", responseDict)

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                let decodedResponse = try JSONDecoder().decode(IntroductionResponse.self, from: jsonData)

                auditFlag = decodedResponse.takingControlIntroduction.result.auditFlag
                cageFlag = decodedResponse.takingControlIntroduction.result.cageFlag
                dastFlag = decodedResponse.takingControlIntroduction.result.dastFlag

                print("Audit Flag: \(String(describing: auditFlag))")
                print("Cage Flag: \(String(describing: cageFlag))")
                print("DAST Flag: \(String(describing: dastFlag))")

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                // 👉 You can now use these flags however you want (e.g. update UI)

            } catch {
                print("Decoding failed with error:", error)
            }

        } else {
            print("Unsupported response type:", type(of: response))
        }
    }

    //END
    
    func getScreeningData() {
        screeningData = []
        guard let requestURL = screeningRequest.getURLRequest() else {
            self.view.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }
        NetworkAPIRequest.sendRequest(request: requestURL) { [weak self](response: ScreeningResponse?, failureResponse: FailureResponse?, error: Error?) in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.view.hideToastActivity()
                if let _ = error {
                    self.view.showToast(message: "An Unknown error occured. Please check with Admin")
                } else if let response = response {
                    self.screeningData = response.screeningList
                } else if let failureResponse = failureResponse {
                    self.view.showToast(message: failureResponse.statusResponse.responseMessage)
                }
            }
            
        }
    }

    @available(iOS 16.0, *)
    @IBAction func forwardButtonAction(_ sender: Any) {
                let next = UIStoryboard(name: "introductionTakingPage", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "introductionTakingPage") as? introductionTakingPage
        print(AppHelper.getLocalizeString(str: "Taking control introduction"));
        vc?.title = AppHelper.getLocalizeString(str: "Taking control introduction")
                self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func infoTapped(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
        if let customAlertVC = storyboard.instantiateViewController(withIdentifier: "InfoButtonVC") as? InfoButtonVC {
            customAlertVC.modalPresentationStyle = .overFullScreen
            customAlertVC.modalTransitionStyle = .crossDissolve
            self.present(customAlertVC, animated: true, completion: nil)
        }

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.main_view.layer.cornerRadius = 10
        cell.main_view.layer.borderWidth = 1
        cell.main_view.layer.borderColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 0.2).cgColor
        cell.name_label.text = data[indexPath.row]
        cell.selectionStyle = .none
        
        if indexPath.row == 0 {
            if auditFlag == 1 {
                
                cell.action_button.setTitle(doesttext, for: .normal)
                cell.selectionStyle = .none
                cell.main_view.backgroundColor = UIColor(named: "AppBackGroundColor")

            }
            else if auditFlag == 0{
                cell.action_button.setTitle(applytometext, for: .normal)
                cell.selectionStyle = .none
                cell.main_view.backgroundColor = UIColor(named: "barColor3")

            }
        }
    
    
    if indexPath.row == 1 {
        if dastFlag == 1{
            cell.action_button.setTitle(doesttext, for: .normal)
            cell.selectionStyle = .none
            cell.main_view.backgroundColor = UIColor(named: "AppBackGroundColor")
        }
        else if dastFlag == 0 {
            cell.action_button.setTitle(applytometext, for: .normal)
            cell.selectionStyle = .none
            cell.main_view.backgroundColor = UIColor(named: "barColor3")
        }
    }
    if indexPath.row == 2 {
        if cageFlag == 1{
            cell.action_button.setTitle(doesttext, for: .normal)
            cell.selectionStyle = .none
            cell.main_view.backgroundColor = UIColor(named: "AppBackGroundColor")
        }
        else if cageFlag == 0 {
            cell.action_button.setTitle(applytometext, for: .normal)
            cell.selectionStyle = .none
            cell.main_view.backgroundColor = UIColor(named: "barColor3")
        }
    }
        
        // Configure button action
        cell.onButtonTap = { [weak self] in
            guard let self = self else { return }
            self.handleAlertForRow(at: indexPath.row)
        }
    
    return cell
}
    
    //MARK: - Alert Function
    
    func handleAlertForRow(at index: Int) {
        var flagValue = 0
        var flagName = ""
        var updateFlag: ((Int) -> Void)? = nil

        switch index {
        case 0:
            flagValue = auditFlag
            flagName = data[0]
            updateFlag = { self.auditFlag = $0 }
        case 1:
            flagValue = dastFlag
            flagName = data[1]
            updateFlag = { self.dastFlag = $0 }
        case 2:
            flagValue = cageFlag
            flagName = data[2]
            updateFlag = { self.cageFlag = $0 }
        default:
            return
        }

        let subTitle = flagValue == 0 ? "\(flagName) \(applytometext)" : "\(flagName) \(doesttext)"

        showGeneralAlertYesNo(
            image: UIImage(named: "question2"),
            imageSize: CGSize(width: 40, height: 40),
            title: flagName,
            subTitle: subTitle,
            okButtonTitle: AppHelper.getLocalizeString(str: "YES"),
            cancelButtonTitle: AppHelper.getLocalizeString(str: "NO"),
            okAction: {
                let newFlag = flagValue == 0 ? 1 : 0
                updateFlag?(newFlag)
                print("Updated \(flagName) flag to \(newFlag)")
                self.saveTakingControlIntroAPICalling()
                // optionally reload this row only
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            }
        )
    }


    
    //END

        
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let screeningID = 3
            if auditFlag == 0{
                
            }
            else if auditFlag == 1{
                if let selectedScreening = screeningData.filter({ $0.screeningID == screeningID }).first {
                    if #available(iOS 16.0, *) {
                        let host = ScreeningQuestionsHostingController()
                        host.configure(selectedScreening: selectedScreening)
                        self.navigationController?.pushViewController(host, animated: true)
                    }
                }
                
            }
        }
        if indexPath.row == 1 {
            let screeningID1 = 4
            if dastFlag == 0 {
                
            }
            else if dastFlag == 1 {
                if let selectedScreening = screeningData.filter({ $0.screeningID == screeningID1 }).first {
                    if #available(iOS 16.0, *) {
                        let host = ScreeningQuestionsHostingController()
                        host.configure(selectedScreening: selectedScreening)
                        self.navigationController?.pushViewController(host, animated: true)
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
   
    
}
