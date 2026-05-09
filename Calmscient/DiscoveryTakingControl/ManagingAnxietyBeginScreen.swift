//
//  ManagingAnxietyBeginScreen.swift
//  CalmscientIOS
//
//  Created by BVK on 21/08/24.
//

import UIKit

class ManagingAnxietyBeginScreen: ViewController {

    @IBOutlet weak var letsBeginButton: LinearGradientButton!
    @IBOutlet weak var managingTextView: UITextView!
    
    @IBOutlet weak var calmsLabels: UILabel!
    @IBOutlet weak var areYouReadyLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "The Discovery".localized
        managingTextView.font = UIFont(name: Fonts().lexendLight, size: 16)
        calmsLabels.font = UIFont(name: Fonts().lexendMedium, size: 16)
        letsBeginButton.titleLabel?.font = UIFont(name: Fonts().lexendSemiBold, size: 18)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let defaultAppearance = UINavigationBarAppearance()
        defaultAppearance.configureWithOpaqueBackground()
        defaultAppearance.backgroundColor = nil // Reset to default (system default color)
        defaultAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.label] // Default text color

        navigationController?.navigationBar.standardAppearance = defaultAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = defaultAppearance
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        letsBeginButton.setTitle("Let's begin!".localized, for: .normal)
        areYouReadyLbl.font = UIFont(name: Fonts().lexendRegular, size: 22)
        areYouReadyLbl.text = "Are you ready?".localized
        
        calmsLabels.text = "The Calmscient discovery will only be as effective as you make it.".localized
        
        managingTextView.text = "So be determined to dedicate time to following along and completing the exercises. Each section has interesting and informative content that is designed to keep you actively thinking about your specific challenges. But, like taking a road trip to an unknown destination, you’ll need to be committed to following the map! It may be a little more work than you’re used to, but it will absolutely pay off in the end.".localized
        
        // Customize the navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = #colorLiteral(red: 0.5218948722, green: 0.5200269818, blue: 0.7418552041, alpha: 1) // Set the nav bar background color
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont(name: Fonts().lexendMedium, size: 18)!] // Set title color to white
        
        // Apply appearance to the navigation bar
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

    }
    @IBAction func letBeginButtonAction(_ sender: Any) {
        
        let backItem = UIBarButtonItem()
        backItem.title = "" // Set an empty string for the back button
        self.navigationItem.backBarButtonItem = backItem
        
        let next = UIStoryboard(name: "CourseViewController", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "CoursesViewController") as? CoursesViewController
        vc?.title = "Managing anxiety".localized
        vc?.courseID = 2
        self.navigationController?.pushViewController(vc!, animated: true)
    }

}
