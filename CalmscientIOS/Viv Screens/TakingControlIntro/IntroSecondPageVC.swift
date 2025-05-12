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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Taking control introduction"
        styleButton(firstButton)
        styleButton(secondButton)

    }
    
    @IBAction func firstButtonPressed(_ sender: Any) {
    }
    
    
    @IBAction func secondButtonPressed(_ sender: Any) {
    }
    
    
    @IBAction func forwardButtonPressed(_ sender: Any) {
        let next = UIStoryboard(name: "Taking Control Index", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "TakingIntroLastVC") as? TakingIntroLastVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    @IBAction func backwardButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
