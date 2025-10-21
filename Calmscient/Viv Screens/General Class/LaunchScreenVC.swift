//
//  LaunchScreenVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 25/03/25.
//

import UIKit
import SwiftyGif

@available(iOS 16.0, *)
class LaunchScreenVC: UIViewController {
    
    @IBOutlet weak var launchGif: UIImageView!
    weak var sceneDelegate: SceneDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            print("🎬 Loading GIF in viewDidLoad")
            let gif = try UIImage(gifName: "whiteGif.gif") //launchGifWhite.gif
            launchGif.setGifImage(gif, loopCount: -1)
        } catch {
            print("❌ Failed to load GIF: \(error)")
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkVersionAPI()
    }
    
    //MARK: - Version CHeck API
    
    func checkVersionAPI() {
        let params: [String: Any] = [
            "sourceId": "2",
            "version": Bundle.main.appVersion
        ]

        self.view.showToastActivity()
        
        print("the params of version check is \(params)")
        
        APIService.validateVersionAPICalling(self, params: params, method: "POST", parameterPlacement: "body") { response in
            
            guard let dict = response as? [String: Any] else {
                print("❌ Response is not a dictionary")
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dict)
                let decoder = JSONDecoder()
                let versionResponse = try decoder.decode(VersionResponse.self, from: jsonData)
                self.getResponseforVersionAPI(versionResponse)
            } catch {
                print("❌ Decoding failed: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Missing key: \(key.stringValue) - \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch for type: \(type) - \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Value not found for type: \(type) - \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
            }
        }

    }
    
    func getResponseforVersionAPI(_ response: VersionResponse) {
        self.view.hideToastActivity()
        
        print("the version api response is \(response)")
        
        guard response.mandatoryUpdate == false else {
            showUpdateAlert(forceUpdate: !response.mandatoryUpdate)
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { //+ 2.0
            print("🕒 Timer (from viewDidLoad) done, proceeding to next screen")
            self.sceneDelegate?.proceedAfterSplashScreen()
        }
        
    }
    
    
    func showUpdateAlert(forceUpdate: Bool) {
        guard let topVC = UIApplication.topViewController() else { return }
        
        let alert = UIAlertController(
            title: "Update Required",
            message: "A new version of the app is available. Please update to continue.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Update", style: .default) { _ in
            if let url = URL(string: "https://apps.apple.com/in/app/6748917043") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        
        DispatchQueue.main.async {
            topVC.present(alert, animated: true) {
                // Add extra dimming after alert appears
                if let window = UIApplication.shared.connectedScenes
                    .compactMap({ ($0 as? UIWindowScene)?.keyWindow })
                    .first {
                    
                    // Find the alert's background dimming view and make it darker
                    for view in window.subviews {
                        if let dimView = view as? UIVisualEffectView {
                            dimView.alpha = 0.5 // Make it more prominent
                        }
                    }
                }
            }
        }
    }

}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

struct VersionResponse: Decodable {
    let flexibleVersion: String
    let mandatoryVersion: String
    let status: Status
    let mandatoryUpdate: Bool
    let flexibleUpdate: Bool
}

struct Status: Decodable {
    let responseCode: Int
    let responseMessage: String
}
