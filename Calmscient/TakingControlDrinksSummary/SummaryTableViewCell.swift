//
//  SummaryTableViewCell.swift
//  CalmscientIOS
//
//  Created by NFC Solutions on 6/17/24.
//

import UIKit

class SummaryTableViewCell: UITableViewCell {
    @IBOutlet weak var summaryImageView: UIImageView!
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var summaryCellView: UIView!
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var summaryProgressBar: UIProgressView!
    @IBOutlet weak var summaryTitle: UILabel!
    
    @IBOutlet weak var daysSublable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        summaryImageView.maskCircle()
       // setupShadowAndCornerRadius()
        summaryCellView.layer.cornerRadius = 10
        summaryCellView.layer.shadowColor = UIColor.black.cgColor
        summaryCellView.layer.shadowOpacity = 0.1
        summaryCellView.layer.shadowOffset = CGSize(width: 0, height: 2)
        summaryCellView.layer.shadowRadius = 2
        summaryCellView.layer.masksToBounds = false

        // Add shadow path for better performance
      //  summaryCellView.layer.shadowPath = UIBezierPath(roundedRect: summaryCellView.bounds, cornerRadius: summaryCellView.layer.cornerRadius).cgPath

        summaryCellView.layer.borderWidth = 1
        summaryCellView.layer.borderColor = UIColor(red: 232/255, green: 231/255, blue: 244/255, alpha: 1).cgColor
               
               // Adding a shadow path for better performance
       // summaryCellView.layer.shadowPath = UIBezierPath(roundedRect: summaryCellView.bounds, cornerRadius: summaryCellView.layer.cornerRadius).cgPath
        

                summaryProgressBar.clipsToBounds = true
                summaryProgressBar.layer.sublayers![1].cornerRadius = 4
                summaryProgressBar.subviews[1].clipsToBounds = true
                summaryProgressBar.progressTintColor = UIColor(red: 0.34, green: 0.35, blue: 0.70, alpha: 1.0) // Your desired color
                summaryProgressBar.trackTintColor = UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0) // Your desired color
              //  summaryProgressBar.layer.borderWidth = 1
                summaryProgressBar.layer.borderColor = UIColor(red: 0.34, green: 0.35, blue: 0.70, alpha: 1.0).cgColor
        
        summaryProgressBar.transform = summaryProgressBar.transform.scaledBy(x: 1, y: 3)
                summaryProgressBar.layer.cornerRadius = 3
                summaryProgressBar.layer.masksToBounds = true
                
                // Ensure the progress bar layer is rounded
                if let progressLayer = summaryProgressBar.layer.sublayers?.first as? CALayer {
                    progressLayer.cornerRadius = 2
                    progressLayer.masksToBounds = true
                }
        summaryTitle.font = UIFont(name: Fonts().lexendMedium, size: 20)


        // Initialization code
    }
    private func setupShadowAndCornerRadius() {
//           summaryCellView.layer.cornerRadius = 10
//           summaryCellView.layer.shadowColor = UIColor.black.cgColor
//           summaryCellView.layer.shadowOpacity = 0.1
//           summaryCellView.layer.shadowOffset = CGSize(width: 0, height: 2)
//           summaryCellView.layer.shadowRadius = 4
//           summaryCellView.layer.masksToBounds = false
//
//           // Add shadow path for better performance
//           summaryCellView.layer.shadowPath = UIBezierPath(roundedRect: summaryCellView.bounds, cornerRadius: summaryCellView.layer.cornerRadius).cgPath
        
        
        summaryCellView.layer.cornerRadius = 10
       // summaryCellView.layer.shadowColor = UIColor.black.cgColor
    //    summaryCellView.layer.shadowOpacity = 0.1
       // summaryCellView.layer.shadowOffset = CGSize(width: 0, height: 2)
       // summaryCellView.layer.shadowRadius = 2
        summaryCellView.layer.masksToBounds = false
       // backGroundView.layer.borderWidth = 1
        summaryCellView.layer.borderColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1).cgColor
       // summaryCellView.layer.shadowPath = UIBezierPath(roundedRect: summaryCellView.bounds, cornerRadius: summaryCellView.layer.cornerRadius).cgPath
           
           // Adding shadow to the cell's layer for better floating effect
//           self.layer.shadowColor = UIColor.black.cgColor
//           self.layer.shadowOpacity = 0.1
//           self.layer.shadowOffset = CGSize(width: 0, height: 2)
//           self.layer.shadowRadius = 4
//           self.layer.masksToBounds = false
//           self.layer.cornerRadius = 10
//           self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
       }
//
}
//extension UIImageView {
//    public func maskCircle() {
//        self.contentMode = UIView.ContentMode.scaleAspectFill
//        self.layer.cornerRadius = self.frame.height / 2
//        self.layer.masksToBounds = false
//        self.clipsToBounds = true
//        
//        // make square(* must to make circle),
//        // resize(reduce the kilobyte) and
//        // fix rotation.
//        // self.image = anyImage
//    }
//}
