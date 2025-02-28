//
//  ScreeningResultVC.swift
//  HealthScreeningApp
//
//  Created by KA on 23/03/24.
//

import UIKit

class ScreeningResultVC: ViewController {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var scoreLbl: UILabel!
    @IBOutlet weak var totalScoreLbl: UILabel!
    
    @IBOutlet weak var testDateLbl: UILabel!
    @IBOutlet weak var testTimeLbl: UILabel!
    @IBOutlet weak var remindOptionLbl: UILabel!
    @IBOutlet weak var needToTalkButton: LinearGradientButton!
    @IBOutlet weak var screeningLabel: FontLR15!
    
    
    private var customAlertBackgroundView:UIVisualEffectView?
    public weak var selectedScreening:Screening? = nil

    fileprivate var screeningResult:ScreeningSuccessResults? = nil
    @IBOutlet weak var remindMeLabel: UILabel!
    
    
    @IBOutlet weak var scoreMarkedLabel: UILabel!
    
    @IBOutlet weak var totalscoreLabelText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        needToTalkButton.setAttributedTitleWithGradientDefaults(title: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Need to talk with someone?" : "¿Necesitas hablar con alguien?")
        addShadowAndBorder()
        print(progressBar.frame.height)
        print(progressBar.frame.height)
        progressBar.subviews.forEach { subview in
            subview.layer.masksToBounds = true
            subview.layer.cornerRadius = 12
        }
        getResultsForScreening()
        
        //nav bar back button start
        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)

        // Create a UIButton
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonOverrideAction), for: .touchUpInside)

        // Set constraints to adjust the size
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 26).isActive = true // Set desired width
        backButton.heightAnchor.constraint(equalToConstant: 26).isActive = true // Set desired height

        // Create a UIBarButtonItem using the UIButton
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        //end

    }
    
    @objc func backButtonOverrideAction() {
        let next = UIStoryboard(name: "ScreeningListVC", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "ScreeningListVC") as? ScreeningListVC
        self.navigationController?.pushViewController(vc!, animated: true)
    
        }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
    }

    
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        self.title =  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Your results" : "Tus resultados."
     //   needToTalkButton.titleLabel!.text = AppHelper.getLocalizeString(str:"Need to talk with someone?")
        needToTalkButton.setAttributedTitleWithGradientDefaults(title: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Need to talk with someone?" : "¿Necesitas hablar con alguien?")
        remindMeLabel.text = AppHelper.getLocalizeString(str:"Remind me")
        scoreMarkedLabel.font = UIFont(name: Fonts().lexendRegular, size: 10)
        scoreLbl.font = UIFont(name: Fonts().lexendMedium, size: 30)
        scoreMarkedLabel.text =  AppHelper.getLocalizeString(str:"Score\nmarked")
        totalscoreLabelText.font = UIFont(name: Fonts().lexendRegular, size: 10)
        totalScoreLbl.font = UIFont(name: Fonts().lexendMedium, size: 30)
        totalscoreLabelText.text = AppHelper.getLocalizeString(str:"Total score")
        remindOptionLbl.text =  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Weekly" : "Semanalmente"
        
        }
    @IBAction func needToTalkAction(_ sender: Any) {
        let next = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController
        vc?.title = "Emergency resource"
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    fileprivate func getResultsForScreening() {
        self.view.showToastActivity()
        var prepareRequestBodyParams:[String:Any] = [:]
        guard let screeningObject = self.selectedScreening, let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            return
        }
        prepareRequestBodyParams["screeningId"] = screeningObject.screeningID
        prepareRequestBodyParams["assessmentId"] = screeningObject.assessmentID
        
        prepareRequestBodyParams["patientLocationId"] = loginResponse.patientLocationID
        prepareRequestBodyParams["patientId"] = loginResponse.patientID
        prepareRequestBodyParams["clientId"] = loginResponse.clientID
        
        
        let questonariesRequest = ScreeningSuccessResultRequestForm(prepareRequestBodyParams)
        guard let requestURL = questonariesRequest.getURLRequest() else {
            self.view.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }
        NetworkAPIRequest.sendRequest(request: requestURL) { [weak self](response: ScreeningSuccessResponse?, failureResponse: FailureResponse?, error: Error?) in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.view.hideToastActivity()
                if let _ = error {
                    self.view.showToast(message: "An Unknown error occured. Please check with Admin")
                } else if let response = response {
                    self.screeningResult = response.screeningResults
                    self.totalScoreLbl.text = "\(self.screeningResult?.total ?? 0)"
                    self.scoreLbl.text =  "\(self.screeningResult?.score ?? 0)"
                    self.progressBar.setProgress(Float(response.screeningResults.score)/Float(response.screeningResults.total), animated: true)
                    self.screeningLabel.text = "\(self.screeningResult?.screeningName ?? "")"
                    
                    //Date and Time
                    
                    let screeningDate = self.screeningResult?.screeningDate ?? "2025-01-01 00:00:00"
                    
                    // Step 1: Parse the date-time string
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Format matching the API response
                    if let date = dateFormatter.date(from: screeningDate) {
                        
                        // Step 2: Extract the date
                        let dateFormatterForDate = DateFormatter()
                        dateFormatterForDate.dateFormat = "MM/dd/yyyy" // Format for date
                        let dateString = dateFormatterForDate.string(from: date)
                        
                        // Step 3: Extract the time
                        let dateFormatterForTime = DateFormatter()
                        dateFormatterForTime.dateFormat = "h:mm a" // Format for time
                        let timeString = dateFormatterForTime.string(from: date)
                        
                        print("Date: \(dateString)")
                        print("Time: \(timeString)")
                        
                        self.testTimeLbl.text = "\(timeString)"
                        self.testDateLbl.text = "\(dateString)"
                    } else {
                        print("Invalid date format")
                    }
                    
                    //End
                    
                } else if let failureResponse = failureResponse {
                    self.view.showToast(message: failureResponse.statusResponse.responseMessage)
                }
            }
        }
    }
    
    fileprivate func addShadowAndBorder() {
        shadowView.layer.backgroundColor = UIColor.clear.cgColor
        shadowView.layer.shadowColor = UIColor(named: "AppViewShadowColor")?.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowRadius = 4.0
        
        cornerView.layer.cornerRadius = 8
        cornerView.layer.masksToBounds = true
        cornerView.layer.borderWidth = 1
        cornerView.layer.borderColor = UIColor(named: "AppViewBorderColor")?.cgColor
    }
    @IBAction func didClickOnInfo(_ sender: Any) {
        addAlertView()
    }
    
    private func addAlertView() {
       
       customAlertBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        customAlertBackgroundView?.frame = self.view.frame
        var customAlertView:CustomAlertMoreInfoView? = CustomAlertMoreInfoView(frame: self.view.frame)
        customAlertBackgroundView?.contentView.addSubview(customAlertView!)
        customAlertView?.translatesAutoresizingMaskIntoConstraints = false
        customAlertView?.okAction = { [weak self] in
            guard let self = self else {
                return
            }
            UIView.transition(with: self.view, duration: 0.25, options: .transitionCrossDissolve, animations: {
                customAlertView?.removeFromSuperview()
                self.customAlertBackgroundView?.removeFromSuperview()
                customAlertView = nil
                self.customAlertBackgroundView = nil
                self.navigationController?.navigationBar.layer.zPosition = 0

            }, completion: nil)
        }
        
        UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.navigationController?.navigationBar.layer.zPosition = -1
            self.view.addSubview(self.customAlertBackgroundView!)
            }, completion: nil)
        customAlertView?.layer.cornerRadius = 10
        customAlertView?.layer.masksToBounds = true
        customAlertView?.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        customAlertView?.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        customAlertView?.widthAnchor.constraint(equalToConstant: self.view.frame.width * 0.9).isActive = true
//        customAlertView?.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.45).isActive = true
//        let alertHeight = self.view.frame.height * 0.45
//        customAlertView?.heightAnchor.constraint(greaterThanOrEqualToConstant: 220).isActive = true // Minimum height
//        customAlertView?.heightAnchor.constraint(lessThanOrEqualToConstant: alertHeight).isActive = true // Dynamic height up to 45% of screen


    
    }
    

}
