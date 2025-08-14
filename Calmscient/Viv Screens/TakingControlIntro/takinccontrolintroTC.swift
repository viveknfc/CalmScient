//
//  takinccontrolintroTC.swift
//  CalmscientIOS
//
//  Created by NFC User on 12/05/25.
//

import UIKit

class takinccontrolintroTC: UITableViewCell {
    
    @IBOutlet weak var questionLabel: FontLM18!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    var yesTapped: (() -> Void)?
    var noTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        styleButton(yesButton)
        styleButton(noButton)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func yesButtonPressed(_ sender: Any) {
        yesTapped?()
    }
    
    
    @IBAction func noButtonPressed(_ sender: Any) {
        noTapped?()
    }
    
    private func styleButton(_ button: UIButton) {
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)

        button.applyShadow(
            cornerRadius: 8,
            shadowColor: .black,
            shadowOpacity: 0.2,
            shadowOffset: CGSize(width: 0, height: 1),
            shadowRadius: 2
        )
    }

    

}
