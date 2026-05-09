//
//  NicotinCarvingVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 07/01/25.
//

import UIKit

class NicotinCarvingVC: UIViewController {
    
    @IBOutlet weak var title1: FontLM16!
    @IBOutlet weak var subContext1: FontLL15!
    @IBOutlet weak var title2: FontLM16!
    @IBOutlet weak var subContext2: FontLL15!
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var circle1: UIView!
    
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var circle2: UIView!
    
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var circle3: UIView!
    
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var circle4: UIView!
    
    @IBOutlet weak var verticalBar: UIView!
    
    @IBOutlet weak var subContext3: FontLL15!
    @IBOutlet weak var subContext4: FontLL15!
    
    @IBOutlet weak var view5: UIView!
    @IBOutlet weak var circle5: UIView!
    
    @IBOutlet weak var view6: UIView!
    @IBOutlet weak var circle6: UIView!
    
    @IBOutlet weak var view7: UIView!
    @IBOutlet weak var circle7: UIView!
    
    @IBOutlet weak var subContext5: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

         let subContext3Text = """
\("You can also try…".localized)

\("One non-nicotine medicine (prescription from your doctor is required). Varenicline is a pill that works differently from other medicines. It does not contain nicotine. It works by attaching to the same parts of your brain that are stimulated by nicotine. This means that nicotine from a cigarette has fewer places to attach because the varenicline is already there. This makes it harder to get a nicotine \"buzz\".".localized)
"""
        
        let subCOntext4Text = "The benefits of Varenicline are:".localized
        
        let subCOntext7Text = """
\("Know your triggers:".localized)

\("Certain things can make you want to smoke, like being around friends you used to smoke with or being in a place where you often smoked. Even memories or feelings can bring it on.".localized)

\("Positive thoughts:".localized)

\("Remember why you decided to quit. You're in control, and cravings don't last forever. They'll pass.".localized)
"""
        
        subContext3.attributedText = TextHighlighter.getFormattedText(fullText: subContext3Text, highlightTexts: ["One non-nicotine medicine".localized], highlightColor: UIColor(hex: "6E6BB3"))
        subContext4.attributedText = TextHighlighter.getFormattedText(fullText: subCOntext4Text, highlightTexts: ["Varenicline".localized], highlightColor: UIColor(hex: "6E6BB3"))
        subContext5.attributedText = TextHighlighter.getFormattedText(fullText: subCOntext7Text, highlightTexts: ["Know your triggers:".localized, "Positive thoughts:".localized], highlightColor: UIColor(hex: "6E6BB3"))
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Apply styling
        [view1, view2, view3, view4, view5, view6, view7].forEach { $0?.applyShadow() }
        [circle1, circle2, circle3, circle4, circle5, circle6, circle7].forEach { $0?.makeCircle(with: UIColor(hex: "#6E6BB3")) }
    }

    
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}
