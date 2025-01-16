import UIKit

class ButtonCell: UITableViewCell {
    @IBOutlet var buttons: UILabel!

    @IBOutlet weak var tickMarkButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        buttons.textAlignment = .left
            buttons.layer.borderWidth = 2
//            button.layer.borderColor = UIColor.black.cgColor
            buttons.layer.cornerRadius = 20
            buttons.layer.borderColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1).cgColor
        
    }
    
    func enableButton() {
        buttons.layer.borderColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1).cgColor
        buttons.textColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1)
    }
    
    func disableButton() {
        buttons.layer.borderColor = UIColor.lightGray.cgColor
        buttons.textColor = UIColor.lightGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
