//
//  Taking Control Index.swift
//  CalmscientIOS
//
//  Created by NFC User on 28/11/24.
//

import Foundation
import UIKit

class TakingControlIndex: ViewController {
    
    @IBOutlet weak var takingSegmentControl: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var barView: UIView!
    var initialSegmentIndex: Int = 0
    
    private var currentViewController: UIViewController?
    
    var shouldPopBack: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Change the font for the item names
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Fonts().lexendRegular, size: 16)!,  // Set the font style and size
            .foregroundColor: UIColor.lightGray  // Optional: Change the font color
        ]
        takingSegmentControl.setTitleTextAttributes(attributes, for: .normal)

        // If you want to customize the font for the selected segment, you can do so like this:
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Fonts().lexendRegular, size: 16)!,
            .foregroundColor: UIColor(named: "VTextColor2")!
        ]

        takingSegmentControl.setTitleTextAttributes(selectedAttributes, for: .selected)

        takingSegmentControl.removeBorders()
        
        barView.alpha = 0
                UIView.animate(withDuration: 0.4) {
                    self.barView.alpha = 1
                }
        
        takingSegmentControl.selectedSegmentIndex = initialSegmentIndex
        switchToViewController(withIdentifier: "", sender: initialSegmentIndex)
        updateIndicatorPosition()
        
        self.navigationController?.navigationBar.isHidden = false
        if #available(iOS 16.0, *) {
            self.navigationController?.navigationItem.leftBarButtonItem?.isHidden = false
            
            //nav bar back button start
            let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)

            // Create a UIButton
            let backButton = UIButton(type: .custom)
            backButton.setImage(backButtonImage, for: .normal)
            backButton.addTarget(self, action: #selector(backButtonOverrideAction), for: .touchUpInside)

            // Set constraints to adjust the size
            backButton.translatesAutoresizingMaskIntoConstraints = false
            backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true // Set desired width
            backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true // Set desired height

            // Create a UIBarButtonItem using the UIButton
            let backBarButtonItem = UIBarButtonItem(customView: backButton)
            navigationItem.leftBarButtonItem = backBarButtonItem
            
            //end
            
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    @objc func backButtonOverrideAction() {
        if shouldPopBack {
            self.navigationController?.popViewController(animated: true)
        } else {
            if #available(iOS 16.0, *) {
                let vc = UIStoryboard(name: "DiscoveryMainDashboard", bundle: nil).instantiateViewController(withIdentifier: "DiscoveryMainViewController") as! DiscoveryMainViewController
                self.navigationController?.setViewControllers([vc], animated: true)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false

        let titleLabel = UILabel()
        titleLabel.text = AppHelper.getLocalizeString(str: "Taking control")
        titleLabel.font = UIFont(name: Fonts().lexendMedium, size: 18)
        titleLabel.textColor = .label // or any color you want
        navigationItem.titleView = titleLabel
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateIndicatorPosition()
    }

    
    @IBAction func segmentActionClicked(_ sender: UISegmentedControl) {
        switchToViewController(withIdentifier: "", sender: sender.selectedSegmentIndex)
        updateIndicatorPosition()
    }
    

    func updateIndicatorPosition() {
        // Calculate the effective width of the UISegmentedControl
        let segmentWidth = (takingSegmentControl.frame.width) / CGFloat(takingSegmentControl.numberOfSegments) // 20 accounts for 10 leading + 10 trailing
        let xPosition = CGFloat(takingSegmentControl.selectedSegmentIndex) * segmentWidth + 10 // Start at the leading inset (10 points)

        // Update the frame of the indicator
        UIView.animate(withDuration: 0.4) {
            self.barView.frame = CGRect(x: xPosition, y: self.takingSegmentControl.frame.maxY, width: segmentWidth, height: 3)
        }
    }

    
    private func switchToViewController(withIdentifier identifier: String, sender: Int) {
        // Manually instantiate the view controller and add it as a child
        var newViewController: UIViewController?

        if sender == 0 {
            newViewController = UIStoryboard(name: "Taking Control Index", bundle: nil).instantiateViewController(withIdentifier: "DrinkingControl")            
        } else {
            newViewController = UIStoryboard(name: "Taking Control Index", bundle: nil).instantiateViewController(withIdentifier: "SmokingControl")
        }

        if let newVC = newViewController {
            // Remove the current view controller from the container
            if let currentVC = currentViewController {
                currentVC.view.removeFromSuperview()
                currentVC.removeFromParent()
            }

            // Add the new view controller
            addChild(newVC)
            newVC.view.frame = containerView.bounds
            containerView.addSubview(newVC.view)
            newVC.didMove(toParent: self)

            // Update the current view controller reference
            currentViewController = newVC
        }
    }
  
}

extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: backgroundColor ?? .clear), for: .normal, barMetrics: .default)
        setBackgroundImage(imageWithColor(color: backgroundColor ?? .clear), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }

    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}

