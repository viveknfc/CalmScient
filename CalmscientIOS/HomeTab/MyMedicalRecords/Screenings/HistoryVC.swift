//
//  HistoryVC.swift
//  HealthScreeningApp
//
//  Created by KA on 22/03/24.
//

import UIKit

class HistoryVC: ViewController {
    
    @IBOutlet weak var screeningTitle: UILabel!
    @IBOutlet weak var historyTable: UITableView!
    public weak var selectedScreening:Screening? = nil
    var screeningHistoryData:[ScreeningHistory] = [] {
        didSet {
            self.historyTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "History"
        historyTable.register(UINib(nibName: "HistoryCell", bundle: nil), forCellReuseIdentifier: "HistoryCell")
        historyTable.delegate = self
        historyTable.dataSource = self
        getScreeningHistoryData()
    }
    
    fileprivate func getScreeningHistoryData() {
        self.view.showToastActivity()
        var prepareRequestBodyParams:[String:Any] = [:]
        guard let screeningObject = self.selectedScreening, let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            return
        }
        screeningTitle.text = screeningObject.screeningType
        prepareRequestBodyParams["screeningId"] = screeningObject.screeningID
        prepareRequestBodyParams["assessmentId"] = screeningObject.assessmentID
        
        prepareRequestBodyParams["patientLocationId"] = loginResponse.patientLocationID
        prepareRequestBodyParams["patientId"] = loginResponse.patientID
        prepareRequestBodyParams["clientId"] = loginResponse.clientID
       
        let questonariesRequest = ScreeningHistoryRequestForm(prepareRequestBodyParams)
        guard let requestURL = questonariesRequest.getURLRequest() else {
            self.view.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }
        NetworkAPIRequest.sendRequest(request: requestURL) { [weak self](response: ScreeningHistoryResponse?, failureResponse: FailureResponse?, error: Error?) in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.view.hideToastActivity()
                if let _ = error {
                    self.view.showToast(message: "An Unknown error occured. Please check with Admin")
                } else if let response = response {
                    self.screeningHistoryData = response.screeningHistory
                } else if let failureResponse = failureResponse {
                    self.view.showToast(message: failureResponse.statusResponse.responseMessage)
                }
            }
        }
    }
}

extension HistoryVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return screeningHistoryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell:HistoryCell = self.historyTable.dequeueReusableCell(withIdentifier: "HistoryCell") as? HistoryCell else {
            return UITableViewCell()
        }
        
        cell.selectionStyle = .none
        cell.configureData(data: screeningHistoryData[indexPath.row])
        return cell
    }
    
}
