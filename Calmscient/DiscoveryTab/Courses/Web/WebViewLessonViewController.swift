//
//  WebViewLessonViewController.swift
//  CalmscientIOS
//
//  Created by KA on 27/05/24.
//

//import UIKit
//import WebKit

//class WebViewLessonViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
//    var webView:WKWebView!
//    var urlString:String = ""
//    var pageTitle: String = ""
//    var index : Int = 0
//    
//    var hasAlreadyPopped = false // declare this at class level
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(0, for: .default)
//
//        let configuration = WKWebViewConfiguration()
//        configuration.userContentController.add(self, name: "nativeDispatch")
//        
//        webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), configuration: configuration)
//        self.view.addSubview(webView)
//        webView.translatesAutoresizingMaskIntoConstraints = false
//        webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
//        webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
//        webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
//        webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
//        self.navigationController?.navigationBar.isHidden = false
//        webView.navigationDelegate = self
//        
//        injectTokenScript()
//        
//        if let urlT = URL(string: urlString) {
//            
//            var request = URLRequest(url: urlT)
//            webView.load(request)
//        }
//        self.view.showToastActivity()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
//            [weak self] in
//            self?.view.hideToastActivity()
//        })
//
//        disableZoom()
//        self.navigationController?.toolbar.isHidden = true
//        // Do any additional setup after loading the view.
//        
//        //viv start
//        
//        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)
//
//        // Create a UIButton
//        let backButton = UIButton(type: .custom)
//        backButton.setImage(backButtonImage, for: .normal)
//        backButton.addTarget(self, action: #selector(backButtonOverrideAction), for: .touchUpInside)
//
//        // Set constraints to adjust the size
//        backButton.translatesAutoresizingMaskIntoConstraints = false
//        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true // Set desired width
//        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true // Set desired height
//
//        // Create a UIBarButtonItem using the UIButton
//        let backBarButtonItem = UIBarButtonItem(customView: backButton)
//        navigationItem.leftBarButtonItem = backBarButtonItem
//        
//        //end
//    }
//    
//    deinit {
//        webView.configuration.userContentController.removeScriptMessageHandler(forName: "nativeDispatch")
//    }
//
//    func injectTokenScript() {
//        guard let tokenResponse = ApplicationSharedInfo.shared.tokenResponse else {
//            print("❌ tokenResponse nil")
//            return
//        }
//        let token = tokenResponse.accessToken
//        
//        print("✅ Native Token:")
//        print(token)
//        print("Length:", token.count)
//        
//        let source = """
//        window.__nativeAccessToken = '\(token)';
//        
//        // Call immediately if function already exists
//        if (typeof window.onAccessTokenReceived === 'function') {
//            window.onAccessTokenReceived('\(token)');
//        }
//        
//        // Override the function definition so when the web app defines it,
//        // it fires immediately with the token
//        var __tokenToDeliver = '\(token)';
//        Object.defineProperty(window, 'onAccessTokenReceived', {
//            configurable: true,
//            set: function(fn) {
//                if (typeof fn === 'function') {
//                    // Call it right away when web app assigns the function
//                    setTimeout(function() { fn(__tokenToDeliver); }, 0);
//                }
//            },
//            get: function() { return function(t) {}; }
//        });
//        """
//        
//        let script = WKUserScript(
//            source: source,
//            injectionTime: .atDocumentStart,
//            forMainFrameOnly: true
//        )
//        webView.configuration.userContentController.addUserScript(script)
//    }
//    
//    func disableZoom() {
//        // JavaScript code to disable zooming
//        let script = """
//            var meta = document.createElement('meta');
//            meta.name = 'viewport';
//            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
//            document.getElementsByTagName('head')[0].appendChild(meta);
//            """
//        
//        // Inject the JavaScript into the WKWebView
//        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
//        webView.configuration.userContentController.addUserScript(userScript)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(-5, for: .default)
//        navigationItem.leftBarButtonItem = nil
//        navigationItem.rightBarButtonItem = nil
//        navigationItem.hidesBackButton = false
//        
//    }
//    
//    func configureCustomBackButton() {
//        // Create the custom button with an image
//        let backButtonImage = UIImage(named: "coursesLeftButton") // Replace with your image name
//        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backButtonTapped))
//        
//        // Set the custom button as the left bar button item
//        navigationItem.leftBarButtonItem = backButton
//        
//        // Hide the default back button
//        navigationItem.hidesBackButton = true
//    }
//    
//    func configureRightButton() {
//        // Create the custom button with an image
//        let backButtonImage = UIImage(named: "coursesRightButton") // Replace with your image name
//        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(rightButtonTapped))
//        
//        // Set the custom button as the left bar button item
//        navigationItem.rightBarButtonItem = backButton
//        
//        // Hide the default back button
//        navigationItem.hidesBackButton = true
//    }
//    
//    @objc func rightButtonTapped() {
//        GlossaryNavigation.push(from: self)
//    }
//    
//    @objc func backButtonTapped() {
//        print("back button tap function called")
//        
//        UserDefaults.standard.set(false, forKey: "hasFetchedFavorites")
//
//        let stopMediaAndNotifyScript = """
//            document.querySelectorAll('audio, video').forEach(el => {
//                el.pause();
//                el.currentTime = 0;
//                el.src = '';
//                el.load();
//            });
//            if (typeof onAbortCourseGotoIndex === 'function') {
//                onAbortCourseGotoIndex();
//            }
//        """
//
//        // Step 1: Execute JS to notify and stop media
//        webView.evaluateJavaScript(stopMediaAndNotifyScript) { [weak self] (result, error) in
//            guard let self = self else { return }
//
//            if let error = error {
//                print("JavaScript error: \(error)")
//            } else {
//                print("JavaScript executed successfully")
//            }
//
//            // Step 2: Remove webView from the view
//            self.webView.removeFromSuperview()
//
//            // Step 3: Stop loading and destroy it
//            self.webView.navigationDelegate = nil
//            self.webView.uiDelegate = nil
//            self.webView.stopLoading()
//            self.webView = nil  // Deallocate and stop media
//
//            // Step 4: Navigate back
//            if self.index == 2 || self.index == 3 {
//                if self.index == 3 {
//                    self.title = "Your results"
//                }
//                self.navigationController?.popViewController(animated: true)
//            }
//        }
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        configureCustomBackButton()
//        configureRightButton()
//        self.navigationController?.isNavigationBarHidden = false
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        self.navigationController?.isNavigationBarHidden = false
//        NotificationCenter.default.post(name: .favLanUpdated, object: nil)
//        print("fetching favorites from webview page inside")
//    }
//    
//    @objc func backButtonOverrideAction() {
//        backButtonTapped()
//        }
//    
//    //viv start
//    
//    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
//        guard message.name == "nativeDispatch",
//              let messageBody = message.body as? [String: Any] else {
//            return
//        }
//
//        print("--------\(messageBody)-----------")
//
//        for (key, msg) in messageBody {
//            switch key {
//                
//            case "1001":
//                
//                guard !hasAlreadyPopped else { break }
//                
//                if index == 2 {
//                    print("key 1001 index value 2 clicked complete button")
//                    hasAlreadyPopped = true
//                    DispatchQueue.main.async {
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                } else if index == 3 {
//                    print("key 1001 index value 3 clicked complete button")
//                    self.title = "Your results"
//                    hasAlreadyPopped = true
//                    DispatchQueue.main.async {
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                }
//                self.navigationController?.isNavigationBarHidden = false
//                break
//                
//            case "1002":
//                print("key is 1002")
//                if msg as! String != "" {
//                    self.title = msg as? String
//                }
//                self.navigationController?.isNavigationBarHidden = false
//                break
//
//
//            case "1100":
//                print("key is 1100")
//                self.view.hideToastActivity()
//                if pageTitle != "" {
//                    self.title = pageTitle
//                }
//                self.navigationController?.isNavigationBarHidden = false
//                break
//
//            case "1003":
//                self.navigationController?.isNavigationBarHidden = true
//                break
//
//            case "401":
//                self.navigationController?.isNavigationBarHidden = false
//                
//                print("CURRENT URL =", webView.url?.absoluteString ?? "nil")
//                
//                let alertController = UIAlertController(
//                    title: "Error Occured",
//                    message: "Error occured. Please try again!!",
//                    preferredStyle: .alert
//                )
//                let okAction = UIAlertAction(title: "OK".localized, style: .default)
//                alertController.addAction(okAction)
//                self.present(alertController, animated: true, completion: nil)
//                break
//
//            case "1005":
//
//                break
//
//            case "1008":
//                let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
//                if let vc = next.instantiateViewController(withIdentifier: "TakingControlIndex") as? TakingControlIndex {
//                    vc.title = AppHelper.getLocalizeString(str: "Taking control")
//                    vc.shouldPopBack = true
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//                break
//
//            case "1009":
//                CoursesNavigation.push(
//                    courseID: 3,
//                    title: "Changing your response to stress".localized,
//                    from: self
//                )
//                break
//
//            default:
//                self.navigationController?.isNavigationBarHidden = false
//                break
//            }
//        }
//    }
//
//    
//    //end
//
//}

//extension WebViewLessonViewController: WKUIDelegate {
//    
//    
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        webView.isHidden = false
//        
//        webView.evaluateJavaScript("window.__nativeAccessToken") { result, error in
//            print("JS TOKEN =", result ?? "nil")
//            print("JS ERROR =", error ?? "none")
//        }
//        
//        webView.evaluateJavaScript("""
//        typeof window.onAccessTokenReceived
//        """) { result, error in
//
//            print("FUNCTION =", result ?? "nil")
//        }
//
////        guard let tokenResponse = ApplicationSharedInfo.shared.tokenResponse else {
////            fatalError("Unable to found Application Shared Info")
////        }
////        
////        let token = tokenResponse.accessToken
////        print("the token is \(token)")
////        
////        let js = """
////        (function waitForFn(){
////            if (window && typeof window.onAccessTokenReceived === 'function') {
////                window.onAccessTokenReceived('\(token)');
////            } else {
////                setTimeout(waitForFn, 200);
////            }
////        })();
////        """
////        
////        webView.evaluateJavaScript(js, completionHandler: nil)
//    }
//
//    func webView(
//        _ webView: WKWebView,
//        decidePolicyFor navigationAction: WKNavigationAction,
//        preferences: WKWebpagePreferences
//    ) async -> WKNavigationActionPolicy {
//        preferences.allowsContentJavaScript = true
//        print("User Redirected to from web view lesson view controller:\(String(describing: navigationAction.request.url))")
//        return .allow
//    }
//    
//    
//    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
//        print(error)
//    }
//    
//    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//        print(error)
//    }
//    
//    typealias JSONDictionary = [String : Any]
//
//    func asString(jsonDictionary: JSONDictionary) -> String {
//      do {
//        let data = try JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
//        return String(data: data, encoding: String.Encoding.utf8) ?? ""
//      } catch {
//        return ""
//      }
//    }
//
//}
