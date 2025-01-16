//
//  ViewController.swift
//  CalmscientIOS
//
//  Created by KA on 22/04/24.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(-5, for: .default)
        self.navigationItem.backButtonTitle = ""
        
        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)

        // Create a UIButton
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(customBackButtonTapped), for: .touchUpInside)

        // Set constraints to adjust the size
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 26).isActive = true // Set desired width
        backButton.heightAnchor.constraint(equalToConstant: 26).isActive = true // Set desired height

        // Create a UIBarButtonItem using the UIButton
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    @objc func customBackButtonTapped() {
        // Handle back navigation
        navigationController?.popViewController(animated: true)
    }

    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        DispatchQueue.main.async {
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "TabBarUnSelectedColor")!, NSAttributedString.Key.font: UIFont(name: Fonts().lexendRegular, size: 9)!], for: .normal)
            UITabBar.appearance().isTranslucent = true
            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "TabBarSelectedColor")!, NSAttributedString.Key.font:UIFont(name: Fonts().lexendRegular, size: 9)!], for: .selected)
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font:UIFont(name: Fonts().lexendMedium, size: 20)!]

            let backImage = UIImage(named: "NavigationBack")
            UINavigationBar.appearance().backIndicatorImage = backImage
            UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
            UINavigationBar.appearance().backItem?.backButtonTitle = ""
        }
        self.view.setNeedsDisplay()
    }
}


