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


