//
//  quizTableViewCell.swift
//  CalmscientIOS
//
//  Created by BVK on 22/07/24.
//

import UIKit

class quizTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var quizProgressBar: UIProgressView!
    @IBOutlet weak var quizView: UIView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var dateandTimeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        quizView.layer.cornerRadius = 10
        // Initialization code
        quizProgressBar.clipsToBounds = true
        quizProgressBar.layer.sublayers![1].cornerRadius = 4
        quizProgressBar.subviews[1].clipsToBounds = true
        quizProgressBar.progressTintColor = UIColor(red: 0.34, green: 0.35, blue: 0.70, alpha: 1.0) // Your desired color
        quizProgressBar.trackTintColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0) // Your desired color
      //  summaryProgressBar.layer.borderWidth = 1
        quizProgressBar.layer.borderColor = UIColor(red: 0.34, green: 0.35, blue: 0.70, alpha: 1.0).cgColor

        quizProgressBar.transform = quizProgressBar.transform.scaledBy(x: 1, y: 3)
        quizProgressBar.layer.cornerRadius = 3
        quizProgressBar.layer.masksToBounds = true
        quizView.layer.borderWidth = 1
        quizView.layer.borderColor = UIColor.systemGray5.cgColor
        quizView.layer.shadowColor = UIColor.black.cgColor
        quizView.layer.shadowOpacity = 0.2
        quizView.layer.shadowOffset = CGSize(width: 0, height: 2)
        quizView.layer.shadowRadius = 3
        quizView.layer.masksToBounds = false
        
        // Ensure the progress bar layer is rounded
        if let progressLayer = quizProgressBar.layer.sublayers?.first as? CALayer {
            progressLayer.cornerRadius = 2
            progressLayer.masksToBounds = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
