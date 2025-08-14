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

    // Expanded state
    private var _isExpanded: Bool = false
    var isExpanded: Bool {
        get { _isExpanded }
        set {
            _isExpanded = newValue
            updateCellAppearance()
        }
    }

    // Closure for button tap
    var plusButtonAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        roundLabel.layer.cornerRadius = roundLabel.frame.size.width / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        _isExpanded = false
        plusButtonAction = nil
        updateCellAppearance()
    }

    func configureCell(isExpanded: Bool) {
        self.isExpanded = isExpanded
    }

    @objc private func plusButtonTapped() {
        plusButtonAction?()
    }

    // MARK: - Private Methods

    private func setupUI() {
        titleLabel.font = UIFont(name: Fonts().lexendRegular, size: 19)
        roundLabel.font = UIFont(name: Fonts().lexendRegular, size: 17)
        roundLabel.clipsToBounds = true
        roundLabel.layer.masksToBounds = true
        updateCellAppearance()
    }

    private func updateCellAppearance() {
        summaryLabel.isHidden = !_isExpanded
        let imageName = _isExpanded ? "cellCollapse" : "cellExpansion"
        plusButton.setImage(UIImage(named: imageName), for: .normal)
    }
}

