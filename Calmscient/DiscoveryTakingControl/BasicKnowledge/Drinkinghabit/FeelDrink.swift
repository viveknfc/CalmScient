//
//  FeelDrink.swift
//  CalmscientIOS
//
//  Created by mac on 07/06/24.
//

import Foundation
import UIKit

class FeelDrink: UITableViewCell {
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var main_lble: UILabel!
    @IBOutlet weak var main_view: UIView!

    @IBOutlet weak var newBackGroundView: UIView!
    @IBOutlet weak var drinkTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
       // main_view.layer.cornerRadius = 10
        //main_view.layer.borderWidth = 1
       // main_view.layer.borderColor = UIColor(red: 232/255, green: 231/255, blue: 244/255, alpha: 1).cgColor
//        main_view.layer.shadowColor = UIColor.black.cgColor
//        main_view.layer.shadowOffset = CGSize(width: 0, height: 2)
//        main_view.layer.shadowOpacity = 2
//        main_view.layer.shadowRadius = 2
        
        
     //   drinkTextView.layer.masksToBounds = false
        newBackGroundView.layer.cornerRadius = 10
        newBackGroundView.layer.borderWidth = 1
        newBackGroundView.layer.borderColor = UIColor(red: 232/255, green: 231/255, blue: 244/255, alpha: 1).cgColor
//        main_view.layer.shadowColor = UIColor.black.cgColor
//        main_view.layer.shadowOffset = CGSize(width: 0, height: 2)
//        main_view.layer.shadowOpacity = 2
//        main_view.layer.shadowRadius = 2
        newBackGroundView.layer.masksToBounds = false
        newBackGroundView.applyShadow()
        
//        configureLabel(label1, withText: "I only drink to relax, it’s not a big deal.")
//        configureLabel(label2, withText: "I've started taking medication to manage craving, I'm working with a therapist or I'm attending a support group meeting.")
//        configureLabel(label3, withText: "I've set a date to start cutting back on my drinking, and I'm telling my friends and family for support.")
    }
    func configureLabel(_ label: UILabel, withText text: String) {
            let bulletPoint = "• \(text)"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.headIndent = 10
            paragraphStyle.firstLineHeadIndent = 0
            paragraphStyle.lineSpacing = 4

            let attributedString = NSAttributedString(string: bulletPoint, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
            label.attributedText = attributedString
        }
}
