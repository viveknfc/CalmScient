//
//  CoursesViewController.swift
//  CalmscientIOS
//
//  Created by KA on NA.
//

import UIKit

class CoursesViewController: ViewController {

    var courseID = 2
    private var courseDate:[CourseLesson] = []
    @IBOutlet weak var courseTableView: UITableView!
    private var courseSessionID = ""
    var patientSessionDetails: PatientSessionDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor(named: "whiteAndBlack")
        if #available(iOS 16.0, *) {
            self.navigationController?.navigationItem.leftBarButtonItem?.isHidden = false
        } else {
            // Fallback on earlier versions
        }
        setupTableView()
//        getCoursesData()
        // Do any additional setup after loading the view.
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: "CoursesTableViewCell", bundle: nil)
        courseTableView.register(nib, forCellReuseIdentifier: "CoursesTableViewCell")
        courseTableView.separatorStyle = .none

        courseTableView.dataSource = self
        courseTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
       // self.title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "Changing your response to stress" : "Cambiando tu respuesta al estrés"
        getCoursesData()
//        let courseRequest = GetCourseSessionIdRequestForm()
//        guard let requestURL = courseRequest.getURLRequest() else {
//            return
//        }
//        NetworkAPIRequest.sendRequest(request: requestURL) { [weak self](response: CoursesSessionInfo?, failureResponse: FailureResponse?, error: Error?) in
//            DispatchQueue.global(qos: .userInitiated).async {
//                guard let self = self else {
//                    return
//                }
//                if let _ = error {
//
//                } else if let response = response {
//                    self.courseSessionID = response.sessionId
//                }
//            }
//
//        }
    }
    
    func getCoursesData() {
        guard let loginResponse = ApplicationSharedInfo.shared.loginResponse else {
            return
        }
        let params = ["patientId":loginResponse.patientID,"clientId":loginResponse.clientID,"patientLocationId":loginResponse.patientLocationID,"courseId":courseID]
        let courseRequest = GetCourseDetailsRequestForm(params)
        guard let requestURL = courseRequest.getURLRequest() else {
            self.view.showToast(message: "An Unknown error occured. Please check with Admin")
            return
        }
        
        self.view.showToastActivity()
        NetworkAPIRequest.sendRequest(request: requestURL) { [weak self](response: UserCoursesData?, failureResponse: FailureResponse?, error: Error?) in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                self.view.hideToastActivity()
                if let _ = error {
                    self.view.showToast(message: "An Unknown error occured. Please check with Admin")
                } else if let response = response {
                    self.courseDate = response.coursesList
                    self.courseSessionID = response.patientSessionDetails.userSessionID
                    self.patientSessionDetails = response.patientSessionDetails
                    self.courseTableView.reloadData()
                } else if let failureResponse = failureResponse {
                    self.view.showToast(message: failureResponse.statusResponse.responseMessage)
                }
            }
            
        }
    }
    
}

extension CoursesViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CoursesTableViewCell", for: indexPath) as? CoursesTableViewCell else {
            return UITableViewCell()
        }
        let instance = courseDate[indexPath.row]
        if courseID == 2{
            cell.courseName = "managingAnxiety"
            let name = "managingAnxiety"
            cell.courseSelectionClosure = { [weak self] (urlString,title,name) in
                guard self?.courseSessionID != "" else {
                    return
                }
                let next = UIStoryboard(name: "WebViewLesson", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "WebViewLessonViewController") as? WebViewLessonViewController
                let fullURLString = "\(urlString)&sessionId=\(self?.courseSessionID ?? "")"
                vc?.urlString = fullURLString
                vc?.index = 2
                vc?.title = "\(title)"
                
                self?.navigationController?.pushViewController(vc!, animated: true)
            }
            cell.darkTheme = self.patientSessionDetails?.darkTheme ?? 0
            cell.languageName = self.patientSessionDetails?.languageName ?? ""
            cell.userSessionID = self.courseSessionID
            cell.updateTableCell(data: instance)
            cell.selectionStyle = .none
        }
        if courseID == 3{
            let name1 = "changingYourResponseToStress"
            cell.courseName = "changingYourResponseToStress"
            cell.courseSelectionClosure = { [weak self] (urlString,title,name1) in
                guard self?.courseSessionID != "" else {
                    return
                }
                let next = UIStoryboard(name: "WebViewLesson", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "WebViewLessonViewController") as? WebViewLessonViewController
                let fullURLString = "\(urlString)&sessionId=\(self?.courseSessionID ?? "")"
                vc?.urlString = fullURLString
//                vc?.title = "\(title)"
                vc?.index = 3
                vc?.pageTitle = title
                self?.navigationController?.pushViewController(vc!, animated: true)
            }
            cell.darkTheme = self.patientSessionDetails?.darkTheme ?? 0
            cell.languageName = self.patientSessionDetails?.languageName ?? ""
            cell.userSessionID = self.courseSessionID
            cell.updateTableCell(data: instance)
            cell.selectionStyle = .none
        }
//        cell.courseSelectionClosure = { [weak self] (urlString,title) in
//            guard self?.courseSessionID != "" else {
//                return
//            }
//            let next = UIStoryboard(name: "WebViewLesson", bundle: nil)
//            let vc = next.instantiateViewController(withIdentifier: "WebViewLessonViewController") as? WebViewLessonViewController
//            let fullURLString = "\(urlString)&sessionId=\(self?.courseSessionID ?? "")"
//            vc?.urlString = fullURLString
//            vc?.title = "\(title)"
//            self?.navigationController?.pushViewController(vc!, animated: true)
//        }
//        cell.updateTableCell(data: instance)
//        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
    }
}
