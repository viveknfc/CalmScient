//
//  WebView_Citation.swift
//  CalmscientIOS
//
//  Created by NFC Solutions on 08/08/25.
//

import UIKit
import WebKit

class CitationWebViewController: ViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var favoritesWebView: WKWebView!
    var favURL : String = ""
    override func viewDidLoad() {
          super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        self.title = "sources_and_citations_title".localized
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(
//            image: UIImage(systemName: "chevron.left"),
//            style: .plain,
//            target: self,
//            action: #selector(backButtonPressed)
//        )
        
        //nav bar back button start
        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)

        // Create a UIButton
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)

        // Set constraints to adjust the size
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true // Set desired width
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true // Set desired height

        // Create a UIBarButtonItem using the UIButton
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        favoritesWebView.uiDelegate = self
        favoritesWebView.navigationDelegate = self
        loadFavoriteURL()
        
       }
    
    @objc func backButtonPressed() {
        if favoritesWebView.canGoBack {
            favoritesWebView.goBack()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    func loadFavoriteURL() {
            self.view.showToastActivity()
            if let myURL = URL(string: favURL) {
                let myRequest = URLRequest(url: myURL)
                favoritesWebView.load(myRequest)
            }
        }
       
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            self.view.hideToastActivity()
            title = "sources_and_citations_title".localized
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            self.view.hideToastActivity()
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            self.view.hideToastActivity()
        }
}
