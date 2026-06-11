//
//  ProgressOnWorkMainViewController.swift
//  CalmscientIOS
//
//  Created by NFC on 29/04/24.
//

import UIKit

public class ProgressOfWorkMainTableData {
    var title:String!
    var subTitle:String!
    
    init(title: String!, subTitle: String!) {
        self.title = title
        self.subTitle = subTitle
    }
}
class ProgressOnWorkMainViewController: ViewController {
    var progressData: [[String: Any]] = []
    @IBOutlet weak var tableView: UITableView!
    var mainPercentage : Float?
    var avgPercentage : Float = 0
    @IBOutlet weak var needTotTalkSomeOneButton: LinearGradientButton!
    var tableData:[ProgressOfWorkMainTableData] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
            fatalError("Unable to found Application Shared Info")
        }
        self.view.showToastActivity()
        getPatientCourseWorkPercentageDetails(patientId: userInfo.patientID,bearerToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async { [self] in
                            self.view.hideToastActivity()
                            
//                            let response = try JSONDecoder().decode(PatientCourseWorkResponse.self, from: json)
//                            self.patientCourseWorkList = response.patientCourseWorkList
                            
                            
                            if let newdata = json["patientcourseWorkList"] as? [[String: Any]] {
                                progressData = newdata
                                print(progressData)
                                avgPercentage = 0
                                var totalPercentage: Float = 0
                                for eachCourse in newdata {
                                    if let mainPerc = eachCourse["completedPer"] as? Float {
                                        totalPercentage += mainPerc
                                        mainPercentage = mainPerc
                                        let courseName = eachCourse["courseName"] as? String
                                        tableData.append(ProgressOfWorkMainTableData(title: courseName, subTitle: "\(mainPerc)%"))
                                    }
                                }
                                avgPercentage = totalPercentage / Float(newdata.count)
                                setUpTableView()

                                tableView.reloadData()

                                    } else {
                                        print("Unable to cast patientcourseWorkList to [[String: Any]]")
                                    }
                                
                          
                        }
                        
                    } else {
                        print("Unable to convert data to JSON")
                    }
                } catch {
                    print("Error converting data to JSON: \(error)")
                }
            case .failure(let error):
                print("Error: \(error)")
            }
        }
        
        tableView.isScrollEnabled = false
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        needTotTalkSomeOneButton.setAttributedTitleWithGradientDefaults(title: AppHelper.getLocalizeString(str:"Need to talk with someone?"))
        needTotTalkSomeOneButton.applyNeedToTalkButtonVisibility()
        self.title = "Progress on course work".localized
    }
    @IBAction func needToTalkButtonAction(_ sender: Any) {
        let next = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
               let vc = next.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController
               vc?.title = "Emergency resource"
               self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func getPatientCourseWorkPercentageDetails( patientId: Int,bearerToken: String, completion: @escaping (Result<Data, Error>) -> Void){
        guard NetworkMonitor.shared.isConnected else {
            DispatchQueue.main.async {
                NoInternetBanner.shared.show()
            }
            return
        }
        // Define the URL
        guard let url = URL(string: "\(baseURLString)patients/api/v1/course/getPatientCourseWorkPercentageDetailsForMobile") else {
            print("Invalid URL")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        
        // Define the JSON payload
        let payload: [String: Any] = [
            "patientId": patientId,
        ]
        
        
        print("payload\(payload)")
        // Convert the payload to JSON data
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            print(jsonData)
        } catch {
            print("Error converting payload to JSON: \(error)")
            completion(.failure(error))
            return
        }
        
        // Create the URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error with request: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                print("Response JSON: \(jsonResponse)")
            } catch {
                print("Error parsing JSON response: \(error)")
                completion(.failure(error))
                return
            }
            // If needed, handle the response here
            completion(.success(data))
        }
        
        // Start the data task
        task.resume()
    }
    
    
    
    fileprivate func setUpTableView() {
        let nib = UINib(nibName: "ProgressOnCourseWorkMainViewTableCell", bundle: nil)
        // Register custom cell class
        tableView.register(nib, forCellReuseIdentifier: "ProgressOnCourseWorkMainViewTableCell")
        tableView.separatorStyle = .none
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 66
        // Set data source and delegate
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
}

extension ProgressOnWorkMainViewController: UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        66
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 150
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = ProgressOnCourseWorkHeaderView()
        view.percentageLabel.text = "\(avgPercentage)%"
        view.progressView.progress = Float(avgPercentage) / 100.0
        return view
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataItem = tableData[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProgressOnCourseWorkMainViewTableCell", for: indexPath) as? ProgressOnCourseWorkMainViewTableCell else {
            return UITableViewCell()
        }
        cell.dataItem = dataItem
        return cell
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Handle cell selection
        print("Selected item index: \(indexPath.row)")
           print("Selected item: \(tableData[indexPath.row])")
        let next = UIStoryboard(name: "ProgressOnWorkDetail", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "ProgressOnWorkDetailViewController") as? ProgressOnWorkDetailViewController
        vc?.progressDetailData = progressData
        
        vc?.index = indexPath.row
        self.navigationController?.pushViewController(vc!, animated: true)
    }
   

}
