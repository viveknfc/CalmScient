//
//  ScreeningUpdatedCell.swift
//  CalmscientIOS
//
//  Created by NFC User on 10/06/25.
//

import UIKit

class ScreeningUpdatedCell: UITableViewCell {
    
    @IBOutlet weak var mainImg: UIImageView!
    @IBOutlet weak var headText: FontLM18!
    @IBOutlet weak var subtext: FontLM14!
    @IBOutlet weak var viewHistoryButton: UIButton!
    @IBOutlet weak var screeningButton: UIButton!
    
    var onHistoryButtonTapped: (() -> Void)?
    var onScreeningButtonTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func historyButtonTapped(_ sender: Any) {
        onHistoryButtonTapped?()
    }
    
    
    @IBAction func screeningButtonTapped(_ sender: Any) {
        onScreeningButtonTapped?()
    }
    

}
