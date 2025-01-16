//
//  DrinksTrackerCollectionCell.swift
//  CalmscientIOS
//
//  Created by NFC Solutions on 6/17/24.
//

import UIKit

class DrinksTrackerCollectionCell: UICollectionViewCell {
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var numberView: UIView!
    @IBOutlet weak var drinksTitle: UILabel!
    @IBOutlet weak var drinksIImageView: UIImageView!
    
    var minusButtonAction: (() -> Void)?
    
    var plusButtonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        minusButton.addTarget(self, action: #selector(minusButtonClicked), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusButtonClicked), for: .touchUpInside)
        
       


        mainView.layer.cornerRadius = 10
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOpacity = 0.1
        mainView.layer.shadowOffset = CGSize(width: 0, height: 0)
        mainView.layer.shadowRadius = 2
        mainView.layer.masksToBounds = false
        mainView.layer.borderWidth = 1
        mainView.layer.borderColor = UIColor(hex: "#F2F2F2").cgColor
        
        
        //numberView.layer.cornerRadius = 10
        numberView.layer.shadowColor = UIColor.black.cgColor
        numberView.layer.shadowOpacity = 0.1
        numberView.layer.shadowOffset = CGSize(width: 0, height: 0)
        numberView.layer.shadowRadius = 2
        numberView.layer.masksToBounds = false
        numberView.layer.borderWidth = 1
        numberView.layer.borderColor = UIColor(hex: "#F2F2F2").cgColor
        
        
        
               
               // Adding a shadow path for better performance
        mainView.layer.shadowPath = UIBezierPath(roundedRect: mainView.bounds, cornerRadius: mainView.layer.cornerRadius).cgPath
        // Initialization code
    }
    @objc func minusButtonClicked() {
           minusButtonAction?()
       }
    @objc func plusButtonClicked() {
        plusButtonAction?()
       }
}
