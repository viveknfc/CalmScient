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
You can also try…

One non-nicotine medicine (prescription from your doctor is required). Varenicline is a pill that works differently from other medicines. It does not contain nicotine. It works by attaching to the same parts of your brain that are stimulated by nicotine. This means that nicotine from a cigarette has fewer places to attach because the varenicline is already there. This makes it harder to get a nicotine "buzz".
"""
        
        let subCOntext4Text = "The benefits of Varenicline are:"
        
        let subCOntext7Text = """
Know your triggers:

Certain things can make you want to smoke, like being around friends you used to smoke with or being in a place where you often smoked. Even memories or feelings can bring it on.

Positive thoughts:

Remember why you decided to quit. You're in control, and cravings don't last forever. They'll pass.
"""
        
        subContext3.attributedText = getFormattedText(fullText: subContext3Text, highlightTexts: ["One non-nicotine medicine"], highlightColor: UIColor(hex: "6E6BB3"))
        subContext4.attributedText = getFormattedText(fullText: subCOntext4Text, highlightTexts: ["Varenicline"], highlightColor: UIColor(hex: "6E6BB3"))
        subContext5.attributedText = getFormattedText(fullText: subCOntext7Text, highlightTexts: ["Know your triggers:", "Positive thoughts:"], highlightColor: UIColor(hex: "6E6BB3"))
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
    
    //MARK: - For Text Line coloring

    func getFormattedText(fullText: String, highlightTexts: [String], highlightColor: UIColor) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: fullText)
        
        
        
        for highlightText in highlightTexts {
            
            print("Searching for:", highlightText)
            if fullText.contains(highlightText) {
                print("\(highlightText) exists in fullText")
            } else {
                print("\(highlightText) NOT FOUND in fullText")
            }
            
            let ranges = rangesOf(text: highlightText, in: fullText)
            for range in ranges {
                attributedString.addAttribute(.foregroundColor, value: highlightColor, range: range)
            }
        }
        
        return attributedString
    }

    // Helper function to find all occurrences of a substring
    func rangesOf(text: String, in fullText: String) -> [NSRange] {
        var ranges: [NSRange] = []
        var searchRange = fullText.startIndex..<fullText.endIndex
        
        while let range = fullText.range(of: text, options: .caseInsensitive, range: searchRange) {
            let nsRange = NSRange(range, in: fullText)
            ranges.append(nsRange)
            
            searchRange = range.upperBound..<fullText.endIndex
        }
        
        return ranges
    }

    

}
