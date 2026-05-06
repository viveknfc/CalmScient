//
//  ViewController.swift
//  CalmscientIOS
//
//  Created by KA on 22/04/24.
//

import UIKit
import Network

class ViewController: UIViewController {
    // MARK: - Properties
        private let networkMonitor = NWPathMonitor()
        private let networkQueue = DispatchQueue(label: "com.calmscient.networkMonitor")
        private(set) var isConnected: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(-5, for: .default)
        self.navigationItem.backButtonTitle = ""
        startNetworkMonitoring()
        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)

        // Create a UIButton
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)

        // Set constraints to adjust the size
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true // Set desired width
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true // Set desired height

        // Create a UIBarButtonItem using the UIButton
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        if let customFont = UIFont(name: Fonts().lexendMedium, size: 18) {
            navigationController?.navigationBar.titleTextAttributes = [
                NSAttributedString.Key.font: customFont,
                NSAttributedString.Key.foregroundColor: UIColor.black // or a custom color
            ]
        }

    }
    
    override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            stopNetworkMonitoring()
        }
    
    
    
    @objc func customBackButtonTapped() {
        // Handle back navigation
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Network Monitoring
       private func startNetworkMonitoring() {
           networkMonitor.pathUpdateHandler = { [weak self] path in
               guard let self = self else { return }
               DispatchQueue.main.async {
                   if path.status == .satisfied {
                       if !self.isConnected {
                           self.isConnected = true
                           NoInternetBanner.shared.hide()
                           self.onNetworkRestored()  // ✅ Hook for subclasses
                       }
                   } else {
                       self.isConnected = false
                       NoInternetBanner.shared.show()
                       self.onNetworkLost()          // ✅ Hook for subclasses
                   }
               }
           }
           networkMonitor.start(queue: networkQueue)
       }
       
       private func stopNetworkMonitoring() {
           networkMonitor.cancel()
       }
    
    /// Called when internet connection is restored. Override to refresh data.
       func onNetworkRestored() {}
       
       /// Called when internet connection is lost. Override to pause operations.
       func onNetworkLost() {}

    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        DispatchQueue.main.async {
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "TabBarUnSelectedColor")!, NSAttributedString.Key.font: UIFont(name: Fonts().lexendRegular, size: 9)!], for: .normal)
            UITabBar.appearance().isTranslucent = true
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "TabBarSelectedColor")!, NSAttributedString.Key.font:UIFont(name: Fonts().lexendRegular, size: 9)!], for: .selected)
        }
        self.view.setNeedsDisplay()
    }
    
    func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            responder = responder?.next
        }
        return nil
    }

}


