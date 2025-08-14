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
        
        self.title = "Sources and Citations"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonPressed)
        )
        
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
            title = "Sources and Citations"
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            self.view.hideToastActivity()
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            self.view.hideToastActivity()
        }
}
