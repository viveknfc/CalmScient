import UIKit

class CustomCheckboxCell: UITableViewCell {

    @IBOutlet weak var customLabel: UILabel!
    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var main_view: UIView!


    override func awakeFromNib() {
        super.awakeFromNib()
        main_view.layer.cornerRadius = 8 // Adjust this value for the desired level of rounding
        main_view.layer.masksToBounds = true
        setShadow()
    }
        
    private func setShadow() {
       // main_view.layer.cornerRadius = main_view.frame.height / 3.5
        main_view.layer.shadowColor = UIColor.gray.cgColor
        main_view.layer.shadowOffset = CGSize(width: 2, height: 2)
        main_view.layer.shadowOpacity = 0.5
        main_view.layer.shadowRadius = 2.0
        main_view.layer.masksToBounds = false
    }

    }

