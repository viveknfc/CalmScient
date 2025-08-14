import UIKit

class ResourceCell: UITableViewCell {
    @IBOutlet weak var mainView: UIView!

    @IBOutlet weak var videoImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var headLable: UILabel!
    
    @IBOutlet weak var resourcesLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Configure corner radius
        mainView.layer.cornerRadius = 10
        mainView.layer.masksToBounds = true
               // Configure shadow
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOpacity = 0.1
        mainView.layer.shadowOffset = CGSize(width: 2, height: 2)
        mainView.layer.shadowRadius = 5
        mainView.layer.masksToBounds = false
               
               // Adding a shadow path for better performance
        mainView.layer.shadowPath = UIBezierPath(roundedRect: mainView.bounds, cornerRadius: mainView.layer.cornerRadius).cgPath
          
    }
}
