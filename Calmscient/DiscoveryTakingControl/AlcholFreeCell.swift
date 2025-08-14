import UIKit

class AlcholFreeCell: UITableViewCell {
    @IBOutlet weak var leftBox: UIView!
    @IBOutlet weak var rightBox: UIView!

    @IBOutlet weak var rightValue: UILabel!
    @IBOutlet weak var rightTitle: UILabel!
    
    @IBOutlet weak var leftValue: UILabel!
    @IBOutlet weak var leftTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        leftBox.backgroundColor = UIColor(hex: "#F5F5F5")
        rightBox.backgroundColor = UIColor(hex: "#F5F5F5")
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
