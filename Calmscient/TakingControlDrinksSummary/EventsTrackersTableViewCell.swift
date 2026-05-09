//
//  EventsTrackersTableViewCell.swift
//  CalmscientIOS
//
//  Created by NFC Solutions on 6/17/24.
//

import UIKit

class EventsTrackersTableViewCell: UITableViewCell {
    @IBOutlet weak var eventsImageView: UIImageView!
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var eventView: UIView!
    @IBOutlet weak var eventsSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    
    var switchAction: ((Bool) -> Void)?
    private var defaultImage = UIImage(named: "ToggleSwitch_No")
    private var selectedImage = UIImage(named: "ToggleSwitch_Yes".localized)
    
    private var currentImage:UIImage? = UIImage(named: "ToggleSwitch_No")
    
    public var isCellSelected = false {
        didSet {
            if isCellSelected {
                currentImage = selectedImage
            } else {
                currentImage = defaultImage
            }
        }
    }
    @IBOutlet weak var yesAndNobutton: UIButton!
    var yesAndNobuttonAction: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        eventsImageView.maskCircle()
        backGroundView.layer.cornerRadius = 10
        backGroundView.layer.shadowColor = UIColor(named: "blackAndWhite")?.cgColor
        backGroundView.layer.shadowOpacity = 0.1
        backGroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        backGroundView.layer.shadowRadius = 4
        backGroundView.layer.masksToBounds = false
       // backGroundView.layer.borderWidth = 1
        backGroundView.layer.borderColor = UIColor(named: "blackAndWhite")?.cgColor
      //  backGroundView.layer.shadowPath = UIBezierPath(roundedRect: backGroundView.bounds, cornerRadius: backGroundView.layer.cornerRadius).cgPath
        eventsSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        
       // titleLabel.attributedText = attributedString
        titleLabel.font = UIFont(name: Fonts().lexendMedium, size: 20)
        yesAndNobutton.addTarget(self, action: #selector(yesAndNobuttonActionClicked), for: .touchUpInside)

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @objc func switchToggled() {
           switchAction?(eventsSwitch.isOn)
       }
    
    @objc func yesAndNobuttonActionClicked() {
        yesAndNobuttonAction?()
       }
}
extension UIImageView {
  public func maskCircle() {
      self.contentMode = UIView.ContentMode.scaleAspectFill
    self.layer.cornerRadius = self.frame.height / 2
    self.layer.masksToBounds = false
    self.clipsToBounds = true

   // make square(* must to make circle),
   // resize(reduce the kilobyte) and
   // fix rotation.
  // self.image = anyImage
  }
}
