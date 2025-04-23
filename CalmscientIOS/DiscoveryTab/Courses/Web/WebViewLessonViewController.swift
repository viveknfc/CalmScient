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
    
    var hasAlreadyPopped = false // declare this at class level
    
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
        
        //viv start
        

        
        //end
    }
    
    deinit {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: "nativeDispatch")
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
        print("back button tap fucntion called")
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
    
    //viv start
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "nativeDispatch",
              let messageBody = message.body as? [String: Any] else {
            return
        }

        print("--------\(messageBody)-----------")

        for (key, msg) in messageBody {
            switch key {
                
            case "1001":
                
                guard !hasAlreadyPopped else { break }
                
                if index == 2 {
                    print("key 1001 index value 2 clicked complete button")
                    hasAlreadyPopped = true
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else if index == 3 {
                    print("key 1001 index value 3 clicked complete button")
                    self.title = "Your results"
                    hasAlreadyPopped = true
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                self.navigationController?.isNavigationBarHidden = false
                break
                
            case "1002":
                print("key is 1002")
                if msg as! String != "" {
                    self.title = msg as? String
                }
                self.navigationController?.isNavigationBarHidden = false
                break


            case "1100":
                print("key is 1100")
                self.view.hideToastActivity()
                if pageTitle != "" {
                    self.title = pageTitle
                }
                self.navigationController?.isNavigationBarHidden = false
                break

            case "1003":
                self.navigationController?.isNavigationBarHidden = true
                break

            case "401":
                self.navigationController?.isNavigationBarHidden = false
                let alertController = UIAlertController(
                    title: "Error Occured",
                    message: "Error occured. Please try again!!",
                    preferredStyle: .alert
                )
                let okAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                break

            case "1005":

                break

            case "1008":
                let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
                if let vc = next.instantiateViewController(withIdentifier: "TakingControlIndex") as? TakingControlIndex {
                    vc.title = AppHelper.getLocalizeString(str: "Taking control")
                    vc.shouldPopBack = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                break

            case "1009":
                let next = UIStoryboard(name: "CourseViewController", bundle: nil)
                if let vc = next.instantiateViewController(withIdentifier: "CoursesViewController") as? CoursesViewController {
                    vc.title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1
                        ? "Changing your response to stress"
                        : "Cambiando tu respuesta al estrés"
                    vc.courseID = 3
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                break

            default:
                self.navigationController?.isNavigationBarHidden = false
                break
            }
        }
    }

    
    //end

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
