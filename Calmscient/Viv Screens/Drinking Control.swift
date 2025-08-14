//
//  Drinking Control.swift
//  CalmscientIOS
//
//  Created by NFC User on 28/11/24.
//

import Foundation
import UIKit
import FSCalendar

class DrinkingControl: UIViewController, NCalendarToViewDelegate { //CalendarToViewDelegate
    func NcalendardidChangeBounds(newBounds: CGRect) {
        calenderHeight.constant = newBounds.height
    }
    
    func NuserSelectedNewDate(selectedDate: Date) {
        
    }
    
    @IBOutlet weak var leftBox: UIView!
    @IBOutlet weak var rightBox: UIView!
    
    @IBOutlet weak var leftBoxLabel: FontLM38!
    @IBOutlet weak var rightBoxLabel: FontLM18!
    
    @IBOutlet weak var rightBoxTitle: FontLR15!
    
    
    @IBOutlet weak var infoButton: UIButton!
    
    @IBOutlet weak var calenderView2: UIView!
    @IBOutlet weak var weeklyCalender: NewCalender! //CustomCalender
    @IBOutlet weak var calenderHeight: NSLayoutConstraint!
    
    @IBOutlet weak var drinkTrackerButtonView: UIView!
    @IBOutlet weak var drinkTrackerButton: UIButton!
    
    @IBOutlet weak var eventTrackerButtonView: UIView!
    @IBOutlet weak var eventTrackerButton: UIButton!
    
    @IBOutlet weak var needToTalkButton: LinearGradientButton!
    
    @IBOutlet weak var basicKnowledge: CurvedOutlineButton!
    @IBOutlet weak var makeAPlan: CurvedOutlineButton!
    @IBOutlet weak var stayFocussed: CurvedOutlineButton!
    @IBOutlet weak var myProgress: CurvedOutlineButton!

    @IBOutlet var infoView: UIView!
    
    //For Language
    
    @IBOutlet weak var textL1: FontLL14!
    @IBOutlet weak var textL2: FontLL14!
    @IBOutlet weak var textR1: FontLL14!
    @IBOutlet weak var textR2: FontLL14!
    
    
    @IBOutlet weak var goalTypeLbl1: UILabel!
    @IBOutlet weak var goalTypeLbl2: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeAPlan.isEnabled = true
        makeAPlan.setBorderColor(.lightGray)
        makeAPlan.setTitleColor(.lightGray)
        stayFocussed.isEnabled = true
        stayFocussed.setBorderColor(.lightGray)
        stayFocussed.setTitleColor(.lightGray)
        myProgress.isEnabled = true
        myProgress.setBorderColor(.lightGray)
        myProgress.setTitleColor(.lightGray)
        
        leftBox.layer.cornerRadius = 12
        leftBox.layer.masksToBounds = true
        
        rightBox.layer.cornerRadius = 12
        rightBox.layer.masksToBounds = true
        
        drinkTrackerButtonView.layer.cornerRadius = 12
        drinkTrackerButtonView.layer.masksToBounds = true
        
        eventTrackerButtonView.layer.cornerRadius = 12
        eventTrackerButtonView.layer.masksToBounds = true
        
        self.weeklyCalender.calendarToViewDelegate = self

        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let dayAfterTomorrow = Calendar.current.date(byAdding: .day, value: 2, to: today)!
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let dayBeforeyesterday = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        
        let colo = UIColor.red
        let colo1 = UIColor.orange
        let colo2 = UIColor.purple
        let colo3 = UIColor.systemGreen
        weeklyCalender.addEvent(forDate: dayBeforeyesterday, iconColor: colo3)
        weeklyCalender.addEvent(forDate: yesterday, iconColor: colo)
        weeklyCalender.addEvent(forDate: tomorrow, iconColor: colo1)
        weeklyCalender.addEvent(forDate: dayAfterTomorrow, iconColor: colo2)
        
        infoView.isHidden = true
        self.view.addSubview(infoView)
        let popupWidth: CGFloat = 300 // Example width
        let popupHeight: CGFloat = 160 // Example height
        infoView.frame.size = CGSize(width: popupWidth, height: popupHeight)
        infoView.translatesAutoresizingMaskIntoConstraints = true
        infoView.layer.shadowColor = UIColor.black.cgColor // Shadow color
        infoView.layer.shadowOpacity = 0.2 // Opacity: 0 (transparent) to 1 (solid)
        infoView.layer.shadowOffset = CGSize(width: 0, height: 2) // Horizontal and vertical offset
        infoView.layer.shadowRadius = 4 // Blur radius for a soft shadow
        infoView.layer.masksToBounds = false // Ensure shadow appears outside bounds
        
        // Add tap gesture recognizer to the main view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissInfoView))
        tapGesture.cancelsTouchesInView = false // Allow other views to receive touches
        self.view.addGestureRecognizer(tapGesture)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        needToTalkButton.setAttributedTitleWithGradientDefaults(title: AppHelper.getLocalizeString(str:"Need to talk with someone?"))
        getTakingControlIndexAPICalling()
        
    }

    //MARK: - Info Button Pressed
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        print("info button pressed")
         
         if let button = sender as? UIView,
            let buttonFrame = button.superview?.convert(button.frame, to: self.view) {
             
             let popupWidth = infoView.frame.size.width // Width of the popup view
             let popupX = buttonFrame.origin.x - popupWidth - 5 // 5 points to the leading of the button
             let popupY = buttonFrame.origin.y + buttonFrame.size.height + 10 // 10 points below the button
             
             // Set popup view position
             infoView.frame.origin = CGPoint(x: popupX, y: popupY)
         }

         infoView.isHidden = false
         infoView.alpha = 0
        self.view.bringSubviewToFront(self.infoView)
         UIView.animate(withDuration: 0.3) {
             self.infoView.alpha = 1
         }
    }
    
    //MARK: - Info Button to close
    
    @objc func dismissInfoView(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.view)
        
        // Ignore the tap if it's within the infoView's frame
        if infoView.isHidden || infoView.frame.contains(location) {
            return
        }
        
        hideInfoView()
    }

    func hideInfoView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.infoView.alpha = 0
        }) { _ in
            self.infoView.isHidden = true
        }
    }
    
    
    @IBAction func infoCloseButtonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
                    self.infoView.alpha = 0
                }) { _ in
                    self.infoView.isHidden = true
                }
    }
    
    //MARK: - Drink Tracker Button Clicked
    
    
    @IBAction func drinkTrackerClicked(_ sender: Any) {
        print("drink tarcker button pressed")
        let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
        if let customAlertVC = storyboard.instantiateViewController(withIdentifier: "FullComingSoonVC") as? FullComingSoonVC {
            customAlertVC.modalPresentationStyle = .overFullScreen
            customAlertVC.modalTransitionStyle = .crossDissolve
            self.present(customAlertVC, animated: true, completion: nil)
        }
    }
    
    //MARK: - Event Tracker Button Clicked
    
    
    @IBAction func eventTrackerButtonPressed(_ sender: Any) {
        print("event tarcker button pressed")
        let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
        if let customAlertVC = storyboard.instantiateViewController(withIdentifier: "FullComingSoonVC") as? FullComingSoonVC {
            customAlertVC.modalPresentationStyle = .overFullScreen
            customAlertVC.modalTransitionStyle = .crossDissolve
            self.present(customAlertVC, animated: true, completion: nil)
        }
    }
    
    //MARK: - Need to Talk button Pressed
    
    
    @IBAction func needToTalkButtonPressed(_ sender: Any) {
        print("need to talk button pressed")
        let next = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController
                vc?.title = "Emergency resource"
                self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    //MARK: - Basic Knowledge button Pressed
    
    @IBAction func basicKnowledgeButtonPressed(_ sender: Any) {
        let next = UIStoryboard(name: "Basicknowledge", bundle: nil)
        if #available(iOS 16.0, *) {
            let vc = next.instantiateViewController(withIdentifier: "Basicknowledge") as? Basicknowledge
            vc?.title =  AppHelper.getLocalizeString(str: "Basic Knowledge")
            self.navigationController?.pushViewController(vc!, animated: true)
        } else {
            // Fallback on earlier versions
        }
       
    }
    
    //MARK: - Make A Plan Button
    
    @IBAction func makeAPlanButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
        if let customAlertVC = storyboard.instantiateViewController(withIdentifier: "FullComingSoonVC") as? FullComingSoonVC {
            customAlertVC.modalPresentationStyle = .overFullScreen
            customAlertVC.modalTransitionStyle = .crossDissolve
            self.present(customAlertVC, animated: true, completion: nil)
        }
    }
    
    //MARK: - Stay focussed Button Clicked
    
    @IBAction func stayFocussedButtonClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
        if let customAlertVC = storyboard.instantiateViewController(withIdentifier: "FullComingSoonVC") as? FullComingSoonVC {
            customAlertVC.modalPresentationStyle = .overFullScreen
            customAlertVC.modalTransitionStyle = .crossDissolve
            self.present(customAlertVC, animated: true, completion: nil)
        }
    }
    
    //MARK: - My Progress Button Clicked
    
    
    @IBAction func myProgressButtoonClicked(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Taking Control Index", bundle: nil)
        if let customAlertVC = storyboard.instantiateViewController(withIdentifier: "FullComingSoonVC") as? FullComingSoonVC {
            customAlertVC.modalPresentationStyle = .overFullScreen
            customAlertVC.modalTransitionStyle = .crossDissolve
            self.present(customAlertVC, animated: true, completion: nil)
        }
    }
    
    //MARK: - Resources
    
    @IBAction func workYourStrengthButton(_ sender: Any) {
    }
    
    @IBAction func breathingExerciseButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "BreathingTechnique") as! BreathingTechnique
        self.navigationController?.pushViewController(destinationVC, animated: true)
    }
    
    @IBAction func managingAnxietyButton(_ sender: Any) {
        let next = UIStoryboard(name: "ManagingAnxietyBeginScreen", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "ManagingAnxietyBeginScreen") as? ManagingAnxietyBeginScreen
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func screeningButton(_ sender: Any) {
        let next = UIStoryboard(name: "ScreeningListVC", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "ScreeningListVC") as? ScreeningListVC
        vc?.isComingFromParticularVC = true
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func drinkCountButton(_ sender: Any) {
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "DrinkingCountVC") as? DrinkingCountVC
        vc?.title = AppHelper.getLocalizeString(str: "Drink counts calculator") //Contador de bebidas

        self.navigationController?.pushViewController(vc!, animated: true)
    }
    

}

extension DrinkingControl {
    
    //MARK: - GetTakingControlIndexAPICalling
    
        func getTakingControlIndexAPICalling() {
            self.view.showToastActivity()
            guard let userInfo = ApplicationSharedInfo.shared.loginResponse else {
                fatalError("Unable to found Application Shared Info")
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            let currentDateString = formatter.string(from: Date())
            
            let params: [String: Any] = [
                    "patientId": userInfo.patientID,
                    "plId": userInfo.patientLocationID,
                    "clientId": userInfo.clientID,
                    "date": currentDateString
                ]
            
            print("the Taking control API call params", params)
            
            APIService.getTakingControlIndexAPICalling(self, params: params, method: "POST", accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken, acces: false, parameterPlacement: "body") { response in
                
                self.view.hideToastActivity()
                self.parsetheDrinkingResponse(response: response)
            }
        }
        
    //MARK: - Parsing the Response
        
        func parsetheDrinkingResponse(response: AnyObject) {
            self.view.hideToastActivity()

            if let responseString = response as? String {
                print("Response received from Get Drinking Data API calling is", responseString)
            } else if let responseDict = response as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                    let data = try JSONDecoder().decode(DrinkingTakingControlResponse.self, from: jsonData)

                    // Access skipTutorialFlag from the first CourseList
                    if let firstCourse = data.courseLists?.first {
                        let skipTutorial = firstCourse.skipTutorialFlag ?? 0
                        print("First course's skipTutorialFlag from drinking control is: \(skipTutorial)")
                           
                            // Access goal details
                            if let indexes = data.index, indexes.count >= 2 {
                                self.goalTypeLbl1.text = indexes[0].goalType ?? ""
                                
                                print("the left label is \(indexes[0].goal ?? 0)")
                                
                                self.leftBoxLabel.text = "\(indexes[0].goal ?? 0)"
                                self.goalTypeLbl2.text = indexes[1].goalType ?? ""
                                self.rightBoxLabel.text = "\(indexes[1].goal ?? 0)"
                                self.rightBoxTitle.text = indexes[1].goalDescription ?? ""
                            }
                            
                    }

                } catch {
                    print("Error decoding JSON: \(error)")
                }
            } else {
                print("Unsupported response type:", type(of: response))
            }
        }
    
}



