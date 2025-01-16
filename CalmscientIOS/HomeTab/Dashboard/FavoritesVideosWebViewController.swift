//
//  FavoritesVideosWebViewController.swift
//  CalmscientIOS
//
//  Created by BVK on 09/07/24.
//

import UIKit
import WebKit

class FavoritesVideosWebViewController: ViewController, WKUIDelegate, WKNavigationDelegate {

    @IBOutlet weak var favoritesWebView: WKWebView!
    var favURL : String = ""
    override func viewDidLoad() {
          super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        favoritesWebView.uiDelegate = self
        favoritesWebView.navigationDelegate = self
       loadFavoriteURL()
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
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            self.view.hideToastActivity()
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            self.view.hideToastActivity()
        }
}
