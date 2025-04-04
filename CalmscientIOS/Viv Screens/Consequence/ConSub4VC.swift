//
//  ConSub4VC.swift
//  CalmscientIOS
//
//  Created by NFC User on 05/12/24.
//

import UIKit

class ConSub4VC: ViewController {
    
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    let details = [
        "Half of liver disease deaths in the United States are caused by alcohol, and alcohol-associated liver disease is increasing, particularly among women and young people.",
        "Research has shown an important association between alcohol consumption and breast cancer—for each 10 grams of alcohol consumed (less than 1 standard drink) on an average daily basis, a woman’s chance of developing postmenopausal breast cancer increases by around 9 percent.",
        "Research has also shown that alcohol misuse increases the risk of liver disease, cardiovascular diseases, depression, and stomach bleeding, as well as cancers of the oral cavity, esophagus, larynx, pharynx, liver, colon, and rectum.",
        "People who misuse alcohol may also have problems managing conditions such as diabetes, high blood pressure, pain, and sleep disorders.",
        "And people who misuse alcohol are more likely to engage in unsafe sexual behavior, putting themselves and others at risk for sexually transmitted infections and unintentional pregnancies.",
        "Birth defects. Prenatal alcohol exposure can result in brain damage and other serious problems in babies. The effects are known as fetal alcohol spectrum disorders, or FASD, and can result in lifelong physical, cognitive, and behavioral problems. Because there is no known safe level of alcohol for a developing baby, women who are pregnant or might be pregnant should not drink."
    ]
    
    @IBOutlet weak var bulletPointsLabel: FontLL15!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the bullet point text with proper indentation for wrapped lines
        let bulletPointText = details.map { "•  \($0)" }.joined(separator: "\n")

        // Create an NSMutableAttributedString
        let attributedString = NSMutableAttributedString(string: bulletPointText)

        // Define paragraph style to control line breaks and indentation
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.paragraphSpacing = 3
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.headIndent = 16  // Indentation for wrapped lines
        paragraphStyle.alignment = .left

        // Apply the paragraph style to the entire text
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        // Optionally, you can also apply a font attribute
//        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 0, length: attributedString.length))
        
        bulletPointsLabel.attributedText = attributedString
    }
    

    @IBAction func completeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
