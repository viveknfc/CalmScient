//
//  AppMainTabViewController.swift
//  MainTabBarApp
//
//  Created by KA on 13/03/24.
//

import UIKit
//protocol LanguageSelectionDelegate: AnyObject {
//    func didSelectLanguage(languageId: Int)
//}

let tabTitlesEnglish: [String] = ["Home", "Discovery", "Exercises", "Rewards"]
let tabTitlesSpanish: [String] = ["Inicio", "Descubrimiento", "Ejercicios", "Recompensas"]
var tabTitles: [String] = []

@available(iOS 16.0, *)
class AppMainTabViewController: UITabBarController {

    var isInitalView: Bool  = false
   
    let selectedImages:[String] =  ["MainTab_Home_Selected","MainTab_Discovery_Selected","MainTab_Exercises_Selected","MainTab_Rewards_Selected"]
    let unselectedimages:[String] = ["MainTab_Home_Unselected","MainTab_Discovery_Unselected","MainTab_Exercises_Unselected","MainTab_Rewards_UnSelected"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register for language change notifications
                NotificationCenter.default.addObserver(self, selector: #selector(languageChanged(_:)), name: .languageChanged, object: nil)
                
        if #available(iOS 15, *) {
            let tabBarItemAppearence = UITabBarItemAppearance()
            tabBarItemAppearence.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "TabBarUnSelectedColor")!, NSAttributedString.Key.font: UIFont(name: Fonts().lexendRegular, size: 9)!]
            tabBarItemAppearence.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(named: "TabBarSelectedColor")!, NSAttributedString.Key.font: UIFont(name: Fonts().lexendRegular, size: 9)!]
            let tabBarAppearance: UITabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor(named: "TabBarBackgroundColor")
            tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearence
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }

        delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateTabBarItems()
        prepareTabs()
        

        
    }


    @objc func languageChanged(_ notification: Notification) {
            updateTabBarItems() // Update tab bar items when the language changes
        }
    deinit {
            NotificationCenter.default.removeObserver(self, name: .languageChanged, object: nil)
        }
    func updateTabBarItems() {
            let selectedLanguageID = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            tabTitles = selectedLanguageID == 1 ? tabTitlesEnglish : tabTitlesSpanish
            guard let items = tabBar.items else { return }
            for i in 0..<items.count {
                print("the first title is",tabTitles[i])
                items[i].title = tabTitles[i]
            }
        
        }
    
    private func prepareTabs() {
        print("prepare Tabs")
        print("the initial view value is ",isInitalView)
        
        guard tabTitles.count >= 4 else {
                print("Error: tabTitles does not have enough elements.")
                return
            }
        
        var tabVC:[UIViewController] = []
        
        let vmain = UIStoryboard(name: "DashboardHomeTab", bundle: nil).instantiateViewController(withIdentifier: "HomeTabDashboardViewController") as! HomeTabDashboardViewController
        let navCview = UINavigationController(rootViewController: vmain)
        
        let vc1 = UIStoryboard(name: "UserMedications", bundle: nil).instantiateViewController(withIdentifier: "UserMedicationsViewController") as! UserMedicationsViewController
        let navC = UINavigationController(rootViewController: vc1)


        let item1 = isInitalView ? navC : navCview
        let icon1 = UITabBarItem(title: "Home", image: UIImage(named: "\(unselectedimages[0])"), selectedImage: UIImage(named: "\(selectedImages[0])")) //\(tabTitles[0])
        item1.tabBarItem = icon1
        tabVC.append(item1)
        print("Tab bar item title: \(item1.tabBarItem.title ?? "No title")")
        
        
        let vcz = UIStoryboard(name: "DiscoveryMainDashboard", bundle: nil).instantiateViewController(withIdentifier: "DiscoveryMainViewController") as! DiscoveryMainViewController
        let navC2 = UINavigationController(rootViewController: vcz)
        
        let item2 = navC2
        item2.title = tabTitles[1]
        let icon2 = UITabBarItem(title: "\(tabTitles[1])", image: UIImage(named: "\(unselectedimages[1])"), selectedImage: UIImage(named: "\(selectedImages[1])"))
        item2.tabBarItem = icon2
        tabVC.append(item2)
        
        let vcz3 = UIStoryboard(name: "Excercises", bundle: nil).instantiateViewController(withIdentifier: "Excercises") as! Excercises
        let navC3 = UINavigationController(rootViewController: vcz3)
        
        
        let item3 = navC3
        item3.title = tabTitles[2]
        let icon3 = UITabBarItem(title: "\(tabTitles[2])", image: UIImage(named: "\(unselectedimages[2])"), selectedImage: UIImage(named: "\(selectedImages[2])"))
        item3.tabBarItem = icon3
        tabVC.append(item3)
        
        let item4 = TestViewController4()
        item4.title = tabTitles[3]
        let icon4 = UITabBarItem(title: "\(tabTitles[3])", image: UIImage(named: "MainTab_Rewards_UnSelected"), selectedImage: UIImage(named: "MainTab_Rewards_Selected"))
        item4.tabBarItem = icon4
        tabVC.append(item4)
        
        self.viewControllers = tabVC
    }
    
    private func updateTabBarAppearance() {
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "TabBarUnSelectedColor")!, NSAttributedString.Key.font: UIFont(name: Fonts().lexendRegular, size: 9)!], for: .normal)
            
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "TabBarSelectedColor")!, NSAttributedString.Key.font:UIFont(name: Fonts().lexendRegular, size: 9)!], for: .selected)
        self.tabBarController?.tabBar.backgroundColor = UIColor(named: "TabBarBackgroundColor")
    }

}

@available(iOS 16.0, *)
extension AppMainTabViewController : UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        print("Should select viewController: \(viewController.title ?? "") ?")
        return true;
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print("Tab bar selecting from here")
        
        if (isInitalView && (viewController.title == "Medications")) {
            print("Tab bar did select clicked")
            isInitalView = false
            prepareTabs()
        }
    }
}


class TestViewController4: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        print("item 1 loaded")
        
        // Load the image
        guard let image = UIImage(named: "comingsoon.png") else {
            print("Image not found")
            return
        }
        
        // Create and configure the UIImageView
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        // Add the UIImageView to the view
        view.addSubview(imageView)
        
        // Set up constraints to center the UIImageView
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300), // Adjust the width as needed
            imageView.heightAnchor.constraint(equalToConstant: 200) // Adjust the height as needed
        ])
    }
}

extension UIColor {
    class func randomColor(randomAlpha: Bool = false) -> UIColor {
        let redValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let greenValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let blueValue = CGFloat(arc4random_uniform(255)) / 255.0;
        let alphaValue = randomAlpha ? CGFloat(arc4random_uniform(255)) / 255.0 : 1;

        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: alphaValue)
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}
