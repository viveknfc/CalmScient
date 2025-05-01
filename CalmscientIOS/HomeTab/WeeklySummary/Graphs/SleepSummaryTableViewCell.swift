//
//  SleepSummaryTableViewCell.swift
//  CalmscientIOS
//
//  Created by Aishuu on 22/10/24.
//

import UIKit

class SleepSummaryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var noOfHrsSlept: UILabel!
    @IBOutlet weak var sleepMsg: UILabel!
    @IBOutlet weak var mostHrsSleptTitle: UILabel!
    @IBOutlet weak var mostHrsSleptLbl: UILabel!
    @IBOutlet weak var avgHrsSleptTitle: UILabel!
    @IBOutlet weak var avgHrsSleptLbl: UILabel!
    @IBOutlet weak var leastHrsSleptTitle: UILabel!
    @IBOutlet weak var leastHrsSleptLbl: UILabel!
    
    @IBOutlet weak var bgView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.applyShadow()
        titleLbl.font = UIFont(name: Fonts().lexendRegular, size: 16)
        titleLbl.text = AppHelper.getLocalizeString(str: "Average_sleep_score")
        progressView.subviews.forEach { subview in
            subview.layer.masksToBounds = true
            subview.layer.cornerRadius = 6
        }
//        noOfHrsSlept.attributedText = NSMutableAttributedString(string: "5/9")
        sleepMsg.font = UIFont(name: Fonts().lexendRegular, size: 14)
        sleepMsg.textColor = UIColor(hex: "#F48383")
        let titleFont = UIFont(name: Fonts().lexendLight, size: 14)
        let lblFont = UIFont(name: Fonts().lexendMedium, size: 14)
        mostHrsSleptTitle.font  = titleFont
        avgHrsSleptTitle.font  = titleFont
        leastHrsSleptTitle.font = titleFont
        mostHrsSleptLbl.font = lblFont
        avgHrsSleptLbl.font = lblFont
        leastHrsSleptLbl.font = lblFont
        sleepMsg.text = ""//AppHelper.getLocalizeString(str: "More_sleep_needed")
        mostHrsSleptTitle.text = AppHelper.getLocalizeString(str: "Most_hours_slept")
        avgHrsSleptTitle.text = AppHelper.getLocalizeString(str: "Average_hours_slept")
        leastHrsSleptTitle.text = AppHelper.getLocalizeString(str: "Least_hours_slept")
    }
    
    func configureCell(with sleptHours: Float) {

        let progress = sleptHours / 10.0
        progressView.progress = progress
         
         // Change progress bar color based on sleep range
        progressView.progressTintColor = getProgressColor(for: Int(sleptHours))
        progressView.trackTintColor = UIColor.lightGray
     }
    
    private func getProgressColor(for sleptHours: Int) -> UIColor {
            switch sleptHours {
            case 0...5:
                return UIColor.red  // Low sleep -> Red
            case 6...8:
                return UIColor.green  // Moderate sleep -> Orange
            case 9...12:
                return UIColor.red  // Good sleep -> Green
            default:
                return UIColor.gray  // Default case
            }
        }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
