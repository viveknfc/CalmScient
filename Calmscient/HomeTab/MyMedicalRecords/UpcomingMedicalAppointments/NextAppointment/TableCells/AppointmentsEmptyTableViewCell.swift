//
//  AppointmentsEmptyTableViewCell.swift
//  MainTabBarApp
//
//  Created by KA on 03/04/24.
//

import UIKit

class AppointmentsEmptyTableViewCell: UITableViewCell, EditableCell {

    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var contentTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var editDeletButton: UIButton!
    
    @IBOutlet weak var forwardButton: UIButton!
    
    @IBOutlet weak var cellIconImageView: UIImageView!
    
    @IBOutlet weak var dateLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var dateToAppointmentHeight: NSLayoutConstraint!
    
    weak var delegate: CustomTableViewCellDelegate?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowAndBorder()
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    fileprivate func addShadowAndBorder() {
        shadowView.layer.backgroundColor = UIColor.clear.cgColor
        shadowView.layer.shadowColor = UIColor(named: "AppViewShadowColor")?.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2.0
        
        borderView.layer.cornerRadius = 8
        borderView.layer.masksToBounds = true
        borderView.layer.borderWidth = 1
        borderView.layer.borderColor = UIColor(named: "AppViewBorderColor")?.cgColor
    }
    
    @IBAction func editDeleteButtonTapped(_ sender: UIButton) {
        guard let tableView = self.superview as? UITableView,
                      let indexPath = indexPath else { return }

                // Convert the button's frame to the table view's coordinate system
                let buttonFrame = sender.convert(sender.bounds, to: tableView)
                delegate?.didTapMoreButton(in: self, at: indexPath, buttonFrame: buttonFrame)
    }
    

    
}
