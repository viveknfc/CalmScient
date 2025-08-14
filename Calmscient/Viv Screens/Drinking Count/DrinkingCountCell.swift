//
//  DrinkingCountCell.swift
//  CalmscientIOS
//
//  Created by NFC User on 16/12/24.
//

import UIKit

protocol DrinkingCountCellDelegate: AnyObject {
    func didUpdateCountValue(changeType: CountChangeType)
}

enum CountChangeType {
    case increase
    case decrease
}


class DrinkingCountCell: UICollectionViewCell {
    
    @IBOutlet weak var overallView: UIView!
    @IBOutlet weak var countImage: UIImageView!
    @IBOutlet weak var countLabel: FontLL8!
    @IBOutlet weak var centreImage: UIImageView!
    @IBOutlet weak var centreLabel: FontLL8!
    @IBOutlet weak var minusView: UIView!
    @IBOutlet weak var plusView: UIView!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var rightCountView: UIView!
    @IBOutlet weak var rightCountLabel: FontLM14!
    
    weak var delegate: DrinkingCountCellDelegate?
    
    private var countValue: Int {
           get {
               // Safely unwrap the countLabel's text and convert to an integer
               return Int(rightCountLabel.text ?? "0") ?? 0
           }
           set {
               // Update the count label whenever the count value changes
               rightCountLabel.text = "\(newValue)"
               rightCountView.isHidden = newValue == 0
           }
       }
    
    override func awakeFromNib() {
           super.awakeFromNib()
        
        overallView.layer.borderWidth = 1.5 // Thickness of the border
        overallView.layer.borderColor = #colorLiteral(red: 0.9117125869, green: 0.9046037197, blue: 0.9573999047, alpha: 1)
           
           // Make overallView rounded
        overallView.layer.cornerRadius = 15
        overallView.layer.masksToBounds = true // Ensures content stays within rounded bounds
        
        minusView.layer.cornerRadius = 4 // Adjust as needed for the desired curve
        minusView.layer.masksToBounds = true
        plusView.layer.cornerRadius = 4 // Adjust as needed for the desired curve
        plusView.layer.masksToBounds = true
        
        minusView.layer.borderWidth = 1 // Thickness of the border
        minusView.layer.borderColor = #colorLiteral(red: 0.9117125869, green: 0.9046037197, blue: 0.9573999047, alpha: 1)
        
        plusView.layer.borderWidth = 1 // Thickness of the border
        plusView.layer.borderColor = #colorLiteral(red: 0.9117125869, green: 0.9046037197, blue: 0.9573999047, alpha: 1)
        
        // Add targets for button actions
        minusButton.addTarget(self, action: #selector(didTapMinus), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(didTapPlus), for: .touchUpInside)
        
        rightCountView.layer.cornerRadius = 10 // Half of 20
        rightCountView.clipsToBounds = true
        rightCountView.isHidden = true
       }
    
    // Action for the minus button
     @objc private func didTapMinus() {
         if countValue > 0 {
             countValue -= 1
             delegate?.didUpdateCountValue(changeType: .decrease)
         }
     }
     
     // Action for the plus button
     @objc private func didTapPlus() {
         countValue += 1
         delegate?.didUpdateCountValue(changeType: .increase)
     }
    
}

struct DrinkingCountData {
    let countImageName: String
    let countLabelText: String
    let centreImageName: String
    let centreLabelText: String
}
