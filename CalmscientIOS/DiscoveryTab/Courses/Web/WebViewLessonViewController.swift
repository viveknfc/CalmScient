//
//  WebViewLessonViewController.swift
//  CalmscientIOS
//
//  Created by KA on 27/05/24.
//

import UIKit
import WebKit

class WebViewLessonViewController: ViewController, WKNavigationDelegate, WKScriptMessageHandler {
    var webView:WKWebView!
    var urlString:String = ""
    var pageTitle: String = ""
    var index : Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(0, for: .default)

        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "nativeDispatch")
        configuration.preferences.javaScriptEnabled = true
        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), configuration: configuration)
        self.view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        self.navigationController?.navigationBar.isHidden = false
        webView.navigationDelegate = self
        if let urlT = URL(string: urlString) {
            let request = URLRequest(url: urlT)
            webView.load(request)
        }
        self.view.showToastActivity()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            [weak self] in
            self?.view.hideToastActivity()
        })

        disableZoom()
        self.navigationController?.toolbar.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    func disableZoom() {
        // JavaScript code to disable zooming
        let script = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.getElementsByTagName('head')[0].appendChild(meta);
            """
        
        // Inject the JavaScript into the WKWebView
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(userScript)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(-5, for: .default)
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = nil
        navigationItem.hidesBackButton = false
    }
    
    func configureCustomBackButton() {
        // Create the custom button with an image
        let backButtonImage = UIImage(named: "coursesLeftButton") // Replace with your image name
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backButtonTapped))
        
        // Set the custom button as the left bar button item
        navigationItem.leftBarButtonItem = backButton
        
        // Hide the default back button
        navigationItem.hidesBackButton = true
    }
    
    func configureRightButton() {
        // Create the custom button with an image
        let backButtonImage = UIImage(named: "coursesRightButton") // Replace with your image name
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(rightButtonTapped))
        
        // Set the custom button as the left bar button item
        navigationItem.rightBarButtonItem = backButton
        
        // Hide the default back button
        navigationItem.hidesBackButton = true
    }
    
    @objc func rightButtonTapped() {
        
        let next = UIStoryboard(name: "GlossyController", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "GlossyController") as? GlossyController
        vc?.title = "Glossary"
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc func backButtonTapped() {
        let javascript = "onAbortCourseGotoIndex();"
        
        webView.evaluateJavaScript(javascript) { [weak self] (result, error) in
            guard let self = self else { return }

            if let error = error {
                print("JavaScript error: \(error)")
            }

            // Here we simulate the messageBody that might contain "1001" key
            // Normally, this would come from your JS message handler
            let messageBody: [String: Any] = ["1001": "turn off loading and go to index"]

            for keyValuePair in messageBody {
                if keyValuePair.key == "1001" {
                    // index 3 - last page (quiz)
                    if self.index == 2 {
                        self.navigationController?.popViewController(animated: true)
                    } else if self.index == 3 {
                        self.title = "Your results"
                        self.navigationController?.popViewController(animated: true)
                    }
                }else if (keyValuePair.key == "1100"){
                    print("web page loaded with valid session")
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureCustomBackButton()
        configureRightButton()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "nativeDispatch" {
            guard let messageBody = message.body as? [String:Any] else {
                return
            }
            print("--------\(messageBody)-----------")
            for keyValuePair in messageBody {
                
                
//                {
//                    gotoIndex: {
//                        1001: 'turn off loading and go to index',
//                    },
//                    intialLoadingOff: {
//                        1100: 'web page loaded with valid session'
//                    },
//                    inValidSession: {
//                        401: 'in valid session'
//                    },
//                    changedHeaderTitle: {
//                        1002: 'in value u will get updated title'
//                    },
//                    hideHeader: {
//                        1003: 'Hide Header'
//                    },
//                    showHeader: {
//                        1004: 'Show  Header'
//                    },
//                    needToTalkWithSomeOne: {
//                        1005: 'needToTalkWithSomeOne'
//                    },
//                    returningBackFromFavMedia: {
//                        1006: 'returningBackFromFavMedia'
//                    }
//
//
//                }
                
                if keyValuePair.key == "1001" {
                    //index 3 - last page (quiz)
                    if(index == 2){
                        print("key 1001 indeex value 2 clicked complete button")
                        self.navigationController?.popViewController(animated: true)
                    }else if(index == 3){
                        print("key 1001 indeex value 2 clicked complete button")
                        self.navigationController?.popViewController(animated: true) //viv added
//                        self.title = "Your results"
                    }
                    self.navigationController?.isNavigationBarHidden = false
                    
                } else if keyValuePair.key == "1100" {
                    print("key is 1100")
                    //index 3 - quiz page entered
                    self.view.hideToastActivity()
                    if(pageTitle != "" ){
                        self.title = pageTitle
                    }
                    
                    self.navigationController?.isNavigationBarHidden = false
                }else if keyValuePair.key == "1003" {
                    // "1003": Hide Header
                    self.navigationController?.isNavigationBarHidden = true
                    
                } else if keyValuePair.key == "401" {
                    self.navigationController?.isNavigationBarHidden = false
                    let alertController = UIAlertController(title: "Error Occured", message: "Error occured. Please try again!!", preferredStyle: .alert)
                    // Add an action button to the alert
                    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                        // Handle OK button action if needed
//                        self.navigationController?.popViewController(animated: true)
                    }
                    alertController.addAction(okAction)
                    // Present the alert
                    self.present(alertController, animated: true, completion: nil)
                } else if keyValuePair.key == "1005" {
//                    let next = UIStoryboard(name: "NeedToTalkViewController", bundle: nil)
//                    let vc = next.instantiateViewController(withIdentifier: "NeedToTalkViewController") as? NeedToTalkViewController
//                    vc?.title = "Emergency resource"
//                    self.navigationController?.pushViewController(vc!, animated: true)
                } else if keyValuePair.key == "1008" {
                    let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
                    let vc = next.instantiateViewController(withIdentifier: "TakingControlIndex") as? TakingControlIndex
                    vc?.title = AppHelper.getLocalizeString(str: "Taking control")
                    self.navigationController?.pushViewController(vc!, animated: true)
                } else if keyValuePair.key == "1009" {
                    let next = UIStoryboard(name: "CourseViewController", bundle: nil)
                    let vc = next.instantiateViewController(withIdentifier: "CoursesViewController") as? CoursesViewController
                    vc?.title =  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "Changing your response to stress" : "Cambiando tu respuesta al estrés"
                    vc?.courseID = 3
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
                
                else {
                    self.navigationController?.isNavigationBarHidden = false
                }
            }
        }
        
        
    }
}

extension WebViewLessonViewController: WKUIDelegate {
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
        print("User Redirected to \(String(describing: navigationAction.request.url))")
        return .allow
    }
    
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print(error)
    }
    
    typealias JSONDictionary = [String : Any]

    func asString(jsonDictionary: JSONDictionary) -> String {
      do {
        let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
        return String(data: data, encoding: String.Encoding.utf8) ?? ""
      } catch {
        return ""
      }
    }
}
