//
//  ScreeningListVC.swift
//  HealthScreeningApp
//
//  Created by KA on 22/03/24.
//

import UIKit
import SDWebImage

class ScreeningListVC: ViewController {
    
    var networkHandler:NetworkAPIRequest = NetworkAPIRequest()
    let screeningRequest = ScreeningListRequestForm()
    @IBOutlet weak var screeningListTable: UITableView!
    
    var isComingFromParticularVC = false
    var isComingFromParticularVC1 = false
    
    var screeningData:[Screening] = [] {
        didSet {
            self.screeningListTable.reloadSections(IndexSet(integer: 0), with: .fade)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        screeningListTable.register(UINib(nibName: "ScreeningCell", bundle: nil), forCellReuseIdentifier: "ScreeningCell")
        screeningListTable.register(UINib(nibName: "ScreeningUpdatedCell", bundle: nil), forCellReuseIdentifier: "ScreeningUpdatedCell")
        self.screeningListTable.delegate = self
        self.screeningListTable.dataSource = self
        
        
        //nav bar back button start
        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)

        // Create a UIButton
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonOverrideAction), for: .touchUpInside)

        // Set constraints to adjust the size
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true // Set desired width
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true // Set desired height

        // Create a UIBarButtonItem using the UIButton
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        //end
        
        getScreeningData()
    }
    
    @objc func backButtonOverrideAction() {
        if isComingFromParticularVC {
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "TakingControlIndex") as? TakingControlIndex
            vc?.title = AppHelper.getLocalizeString(str: "Taking control")
            vc?.initialSegmentIndex = 0
            
            self.navigationController?.pushViewController(vc!, animated: true)
        } else if isComingFromParticularVC1 {
            let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "TakingControlIndex") as? TakingControlIndex
            vc?.title = AppHelper.getLocalizeString(str: "Taking control")
            vc?.initialSegmentIndex = 1
            
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
        else {
            let next = UIStoryboard(name: "UserMedicalRecords", bundle: nil)
            if let vc = next.instantiateViewController(withIdentifier: "UserMedicalRecordsViewController") as? UserMedicalRecordsViewController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
//        self.view.showToastActivity()
        self.title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Screenings" : "Exámenes"
        
        
    }
    
    func getScreeningData() {
        self.view.showToastActivity()
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
}

extension ScreeningListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return screeningData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.screeningListTable.dequeueReusableCell(withIdentifier: "ScreeningUpdatedCell") as? ScreeningUpdatedCell else {
            return UITableViewCell()
        }
        let data = screeningData[indexPath.row]
        
        if data.archiveFlag > 0 {
            cell.viewHistoryButton.isHidden = false
            cell.onHistoryButtonTapped = { [weak self] in
                let storyboard = UIStoryboard(name: "HistoryVC", bundle: nil)
                if let vc = storyboard.instantiateViewController(withIdentifier: "HistoryVC") as? HistoryVC {
                    vc.selectedScreening = data
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else {
            cell.viewHistoryButton.isHidden = true
        }
        
        cell.viewHistoryButton.titleLabel?.font = UIFont(name: Fonts().lexendMedium, size: 14)
        cell.viewHistoryButton.setTitleColor(#colorLiteral(red: 0.4635629654, green: 0.505692482, blue: 0.7547530532, alpha: 1), for: .normal)
        cell.viewHistoryButton.layer.borderWidth = 1
        cell.viewHistoryButton.layer.borderColor = #colorLiteral(red: 0.4635629654, green: 0.505692482, blue: 0.7547530532, alpha: 1).cgColor

        cell.screeningButton.titleLabel?.font = UIFont(name: Fonts().lexendMedium, size: 14)
        cell.screeningButton.setTitleColor(.white, for: .normal)

        
        cell.viewHistoryButton.setTitle(AppHelper.getLocalizeString(str: "View history"), for: .normal)
        cell.screeningButton.setTitle(AppHelper.getLocalizeString(str: "Take the screening"), for: .normal)

        cell.headText.text = data.screeningType
        cell.subtext.text = data.screeningReminder
        cell.selectionStyle = .none
        let iconUrlString = data.iconUrl
        cell.mainImg.sd_setImage(with: URL(string: iconUrlString), placeholderImage: UIImage(named: "placeholder"))
        
        cell.onScreeningButtonTapped = { [weak self] in
            
            let next = UIStoryboard(name: "ScreeningQuestions", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "ScreeningQuestionsViewController") as? ScreeningQuestionsViewController
            vc?.selectedScreening = self?.screeningData[indexPath.row]

            print("screeningData===\(String(describing: self?.screeningData))")

            vc?.screeningAllQuestionsSuccessfullySubmittedClosure = { [weak self] obj in
                guard let self = self else {
                    return
                }
                let next = UIStoryboard(name: "ScreeningResultVC", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "ScreeningResultVC") as? ScreeningResultVC
                vc?.selectedScreening = obj
                if isComingFromParticularVC {
                    vc?.isComingFromParticularVC = true
                } else if isComingFromParticularVC1 {
                    vc?.isComingFromParticularVC1 = true
                }
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            self?.navigationController?.pushViewController(vc!, animated: true)
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 240
    }
    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell:ScreeningCell = self.screeningListTable.dequeueReusableCell(withIdentifier: "ScreeningCell") as? ScreeningCell else {
//            return UITableViewCell()
//        }
//        let data = screeningData[indexPath.row]
//        if data.archiveFlag > 0 {
//            cell.historyIcon.isHidden = false
//        } else {
//            cell.historyIcon.isHidden = true
//        }
//        cell.configureCell(celldata: data)
//        cell.selectionStyle = .none
//        cell.onHistoryClick = { [weak self] in
//            let next = UIStoryboard(name: "HistoryVC", bundle: nil)
//            let vc = next.instantiateViewController(withIdentifier: "HistoryVC") as? HistoryVC
//            vc?.selectedScreening = data
//            self?.navigationController?.pushViewController(vc!, animated: true)
//        }
//        return cell
//    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedScreening = screeningData[indexPath.row]
//
//            let next = UIStoryboard(name: "ScreeningQuestions", bundle: nil)
//            let vc = next.instantiateViewController(withIdentifier: "ScreeningQuestionsViewController") as? ScreeningQuestionsViewController
//            vc?.selectedScreening = screeningData[indexPath.row]
//            
//            print("screeningData===\(screeningData)")
//            
//            vc?.screeningAllQuestionsSuccessfullySubmittedClosure = { [weak self] obj in
//                guard let self = self else {
//                    return
//                }
//                let next = UIStoryboard(name: "ScreeningResultVC", bundle: nil)
//                let vc = next.instantiateViewController(withIdentifier: "ScreeningResultVC") as? ScreeningResultVC
//                vc?.selectedScreening = obj
//                if isComingFromParticularVC {
//                    vc?.isComingFromParticularVC = true
//                } else if isComingFromParticularVC1 {
//                    vc?.isComingFromParticularVC1 = true
//                }
//                self.navigationController?.pushViewController(vc!, animated: true)
//            }
//            self.navigationController?.pushViewController(vc!, animated: true)
//
//    }
}


