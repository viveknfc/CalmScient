//
//  ManagingAnxietyBeginScreen.swift
//  CalmscientIOS
//
//  Created by BVK on 21/08/24.
//

import UIKit

class ManagingAnxietyBeginScreen: ViewController {

    private static let discoveryNavBarPurple = UIColor(
        red: 0.5218948722,
        green: 0.5200269818,
        blue: 0.7418552041,
        alpha: 1
    )

    @IBOutlet weak var letsBeginButton: LinearGradientButton!
    @IBOutlet weak var managingTextView: UITextView!
    
    @IBOutlet weak var calmsLabels: UILabel!
    @IBOutlet weak var areYouReadyLbl: UILabel!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "The Discovery".localized
        managingTextView.font = UIFont(name: Fonts().lexendLight, size: 16)
        calmsLabels.font = UIFont(name: Fonts().lexendMedium, size: 16)
        letsBeginButton.titleLabel?.font = UIFont(name: Fonts().lexendSemiBold, size: 18)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        resetNavigationChrome()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        letsBeginButton.setTitle("Let's begin!".localized, for: .normal)
        areYouReadyLbl.font = UIFont(name: Fonts().lexendRegular, size: 22)
        areYouReadyLbl.text = "Are you ready?".localized
        
        calmsLabels.text = "The Calmscient discovery will only be as effective as you make it.".localized
        
        managingTextView.text = "So be determined to dedicate time to following along and completing the exercises. Each section has interesting and informative content that is designed to keep you actively thinking about your specific challenges. But, like taking a road trip to an unknown destination, you’ll need to be committed to following the map! It may be a little more work than you’re used to, but it will absolutely pay off in the end.".localized

        applyDiscoveryNavigationChrome()
        setNeedsStatusBarAppearanceUpdate()
    }

    private func applyDiscoveryNavigationChrome() {
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.largeTitleDisplayMode = .never

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Self.discoveryNavBarPurple
        appearance.shadowColor = UIColor.white.withAlphaComponent(0.25)
        if let titleFont = UIFont(name: Fonts().lexendMedium, size: 18) {
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: titleFont,
            ]
        }

        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance

        guard let navBar = navigationController?.navigationBar else { return }
        navBar.isTranslucent = false
        navBar.barStyle = .black
        navBar.tintColor = .white
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        navBar.compactScrollEdgeAppearance = appearance
    }

    private func resetNavigationChrome() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.shadowColor = nil

        navigationItem.standardAppearance = nil
        navigationItem.scrollEdgeAppearance = nil
        navigationItem.compactAppearance = nil
        navigationItem.compactScrollEdgeAppearance = nil

        guard let navBar = navigationController?.navigationBar else { return }
        navBar.isTranslucent = true
        navBar.barStyle = .default
        navBar.tintColor = nil
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        navBar.compactScrollEdgeAppearance = appearance
    }
    @IBAction func letBeginButtonAction(_ sender: Any) {
        
        let backItem = UIBarButtonItem()
        backItem.title = "" // Set an empty string for the back button
        self.navigationItem.backBarButtonItem = backItem
        
        CoursesNavigation.push(
            courseID: 2,
            title: "Managing anxiety".localized,
            from: self
        )
    }

}
