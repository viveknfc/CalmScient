//
//  IntroSecondPageVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 12/05/25.
//

import UIKit

class IntroSecondPageVC: ViewController {
    
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    
    var auditData:[Screening] = []
    var dastData:[Screening] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = AppHelper.getLocalizeString(str: "Taking control introduction")
        styleButton(firstButton)
        styleButton(secondButton)
        
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

    }
    
    @objc func backButtonOverrideAction() {

            if #available(iOS 16.0, *) {
                let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
                let vc = next.instantiateViewController(withIdentifier: "TakingControlIndex") as? TakingControlIndex
                vc?.title = AppHelper.getLocalizeString(str: "Taking control")
                vc?.initialSegmentIndex = 0
                
                self.navigationController?.pushViewController(vc!, animated: true)
            } else {
                // Fallback on earlier versions
            }
        
    }
    
    @IBAction func firstButtonPressed(_ sender: Any) {
        let next = UIStoryboard(name: "ScreeningQuestions", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "ScreeningQuestionsViewController") as? ScreeningQuestionsViewController
        vc?.selectedScreening = auditData[0]

        vc?.screeningAllQuestionsSuccessfullySubmittedClosure = { [weak self] obj in
            guard let self = self else {
                return
            }
            let next = UIStoryboard(name: "ScreeningResultVC", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "ScreeningResultVC") as? ScreeningResultVC
            vc?.selectedScreening = obj
            vc?.isComingFromParticularVC2 = true
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @IBAction func secondButtonPressed(_ sender: Any) {
        let next = UIStoryboard(name: "ScreeningQuestions", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "ScreeningQuestionsViewController") as? ScreeningQuestionsViewController
        vc?.selectedScreening = dastData[0]

        vc?.screeningAllQuestionsSuccessfullySubmittedClosure = { [weak self] obj in
            guard let self = self else {
                return
            }
            let next = UIStoryboard(name: "ScreeningResultVC", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "ScreeningResultVC") as? ScreeningResultVC
            vc?.selectedScreening = obj
            vc?.isComingFromParticularVC2 = true
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        self.navigationController?.pushViewController(vc!, animated: true)

    }
    
    
    @IBAction func forwardButtonPressed(_ sender: Any) {
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "TakingIntroLastVC") as? TakingIntroLastVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @IBAction func backwardButtonPressed(_ sender: Any) {
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "VTakingControlIntroVC") as? VTakingControlIntroVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    private func styleButton(_ button: UIButton) {
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)

        button.applyShadow(
            cornerRadius: 8,
            shadowColor: .black,
            shadowOpacity: 0.3,
            shadowOffset: CGSize(width: 0, height: 1),
            shadowRadius: 2
        )
    }


}
