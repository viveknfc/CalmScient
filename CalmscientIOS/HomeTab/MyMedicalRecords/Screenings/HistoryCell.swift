//
//  HistoryCell.swift
//  HealthScreeningApp
//
//  Created by KA on 22/03/24.
//

import UIKit

class HistoryCell: UITableViewCell {

    
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var dateTimeLbl: UILabel!
    @IBOutlet weak var questionCompletionStatusLbl: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var cornerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        progress.subviews.forEach { subview in
            subview.layer.masksToBounds = true
            subview.layer.cornerRadius = progress.frame.height / 2.0
        }
        progress.transform = CGAffineTransform(scaleX: 1, y: 2)
        addShadowAndBorder()
    }
    
    public func configureData(data:ScreeningHistory) {
        // Assuming appointDetails.appointmentDetails.dateAndTime is a string
        let originalDateString = data.completionDateTime
print("originalDateString,\(originalDateString)")
        // Define the date formatter for the original date string
        let originalDateFormatter = DateFormatter()
        // Set the format of the original date string according to its current format
        originalDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        originalDateFormatter.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())
        // Parse the original date string into a Date object
        if let date = originalDateFormatter.date(from: originalDateString) {
            // Define the date formatter for the desired output format
            let outputDateFormatter = DateFormatter()
            // Set the desired output format
            outputDateFormatter.dateFormat = "MM/dd/yyyy | h:mm a"
            
            // Convert the Date object to the desired output format
            let formattedDateString = outputDateFormatter.string(from: date)
            print("formattedDateString,\(formattedDateString)")
            // Assign the formatted date string to the label
            dateTimeLbl.text = formattedDateString
        } else {
            // Handle the case where the date string could not be parsed
            dateTimeLbl.text = "Invalid Date"
        }

       // dateTimeLbl.text = data.completionDateTime
        progress.setProgress(Float(data.score)/Float(data.totalScore), animated: true)
        let blueTextAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor(hex: "#6E6BB3")
        ]
        let firstPart = NSAttributedString(string: "\(data.score)", attributes: blueTextAttr)
        let greyTextAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor(hex: "#9B9B9B")
        ]
        let secondPart = NSAttributedString(string: " / ", attributes: greyTextAttr)
        let blackTextAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor(hex: "#000000")
        ]
        let thirdPart = NSAttributedString(string: "\(data.totalScore)", attributes: blackTextAttr)
        let attributedString = NSMutableAttributedString()
        attributedString.append(firstPart)
        attributedString.append(secondPart)
        attributedString.append(thirdPart)
        questionCompletionStatusLbl.attributedText = attributedString
    }
    
    fileprivate func addShadowAndBorder() {
        shadowView.layer.masksToBounds = true
        shadowView.layer.backgroundColor = UIColor.clear.cgColor
        shadowView.layer.shadowColor = UIColor(named: "AppViewShadowColor")?.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
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
    
}
