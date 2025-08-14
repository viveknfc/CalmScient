//
//  ScreeningCellTableViewCell.swift
//  HealthScreeningApp
//
//  Created by KA on 22/03/24.
//

import UIKit

class ScreeningCell: UITableViewCell {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var historyIcon: UIImageView!
    
    public var onHistoryClick:(()->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addShadowAndBorder()
        historyIcon.isUserInteractionEnabled = true // Enable user interaction
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(historImageTapped))
        historyIcon.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func historImageTapped(_ sender: UITapGestureRecognizer) {
        // Handle tap gesture here
        print("Image tapped")
        onHistoryClick?()
    }
    
    
    
    
    fileprivate func addShadowAndBorder() {
        shadowView.layer.backgroundColor = UIColor.clear.cgColor
        shadowView.layer.shadowColor = UIColor(named: "AppViewShadowColor")?.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1)
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowRadius = 4.0
        
        cornerView.layer.cornerRadius = 8
        cornerView.layer.masksToBounds = true
        cornerView.layer.borderWidth = 1
        cornerView.layer.borderColor = UIColor(named: "AppViewBorderColor")?.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(celldata: Screening){
        titleLbl.text = celldata.screeningType
        if celldata.archiveFlag > 0 {
            historyIcon.isHidden = false
        }else{
            historyIcon.isHidden = true
        }
        
    }
    
}
