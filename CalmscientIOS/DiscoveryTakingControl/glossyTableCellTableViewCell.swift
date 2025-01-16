//
//  glossyTableCellTableViewCell.swift
//  CalmscientIOS
//
//  Created by BVK on 30/09/24.
//

import UIKit

class glossyTableCellTableViewCell: UITableViewCell {
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var roundLabel: UILabel!

    var isExpanded: Bool = false {
        didSet {
            summaryLabel.isHidden = !isExpanded
            updateButtonImage() // Update button image when expanded/collapsed
        }
    }

    // Closure to handle the button tap
    var plusButtonAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        self.titleLabel.font = UIFont(name: Fonts().lexendRegular, size: 19)
        self.roundLabel.font = UIFont(name: Fonts().lexendRegular, size: 17)
        roundLabel.layer.cornerRadius = roundLabel.frame.size.width / 2
        roundLabel.clipsToBounds = true
        roundLabel.layer.masksToBounds = true
        // Set initial button image
        updateButtonImage()

        // Add action to plus button
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    override func layoutSubviews() {
           super.layoutSubviews()

           // Apply shadow to backGroundView after the layout is set
        contentView.applyShadow()
       }
    @objc func plusButtonTapped() {
        // Execute the closure when the button is tapped
        plusButtonAction?()
    }

    private func updateButtonImage() {
        let imageName = isExpanded ? "cellCollapse" : "cellExpansion"
        plusButton.setImage(UIImage(named: imageName), for: .normal)
    }
}

