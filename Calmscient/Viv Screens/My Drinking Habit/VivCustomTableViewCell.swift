//
//  VivCustomTableViewCell.swift
//  CalmscientIOS
//
//  Created by NFC User on 10/12/24.
//

import UIKit

class VivCustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var mainHeading: FontLR12!
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var subTasks: UIStackView!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure containerView with border and shadow
                containerView.layer.cornerRadius = 8
                containerView.layer.borderWidth = 1
                containerView.layer.borderColor = UIColor.systemGray5.cgColor//lightGray.cgColor
                containerView.layer.shadowColor = UIColor.black.cgColor
                containerView.layer.shadowOpacity = 0.2
                containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
                containerView.layer.shadowRadius = 3
                containerView.layer.masksToBounds = false
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func configureCell(heading: String, image: UIImage, subtasks: [String], isSelected: Bool) {
        mainHeading.text = heading
        tickImage.image = image
        tickImage.isHidden = isSelected == true ? false : true
        
        subTasks.spacing = 0
        
            // Clear existing subtask views
        subTasks.arrangedSubviews.forEach { $0.removeFromSuperview() }

            // Add subtasks with bullet icons dynamically
            for subtask in subtasks {
                // Create a horizontal stack view for the subtask
                let horizontalStack = UIStackView()
                horizontalStack.axis = .horizontal
                horizontalStack.alignment = .top
                horizontalStack.spacing = 12

                // Add a bullet icon
                let bulletImageView = UIImageView()
                bulletImageView.image = UIImage(systemName: "circle.fill") // Filled circle with dot
                bulletImageView.tintColor = .black  // Replace with your bullet image name
                bulletImageView.contentMode = .scaleAspectFit
                bulletImageView.translatesAutoresizingMaskIntoConstraints = false
                bulletImageView.widthAnchor.constraint(equalToConstant: 8).isActive = true
//                bulletImageView.heightAnchor.constraint(equalToConstant: 8).isActive = true

                // Add the subtask label
                let label = UILabel()
                label.text = subtask
                label.font = UIFont(name: Fonts().lexendLight, size: 14)
                label.numberOfLines = 0
                label.lineBreakMode = .byWordWrapping

                // Add the bullet and label to the horizontal stack view
                horizontalStack.addArrangedSubview(bulletImageView)
                horizontalStack.addArrangedSubview(label)
                
                let containerView = UIView()
                    containerView.translatesAutoresizingMaskIntoConstraints = false
                    containerView.addSubview(horizontalStack)
                
                horizontalStack.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    horizontalStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
                    horizontalStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
                    horizontalStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                    horizontalStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
                ])

                // Add the horizontal stack view to the main vertical stack view
                subTasks.addArrangedSubview(containerView)
            }
        }
    
    func configureCell1(heading: String, image: UIImage, subtasks: [String], isSelected: Bool) {
        mainHeading.text = heading
        tickImage.image = image
        tickImage.isHidden = !isSelected
        
        subTasks.spacing = 0
        
        // Clear existing subtask views
        subTasks.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add subtasks as multiline labels
        for subtask in subtasks {
            let label = UILabel()
            label.text = subtask
            label.font = UIFont(name: Fonts().lexendLight, size: 14)
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(label)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
                label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
                label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
            ])
            
            subTasks.addArrangedSubview(containerView)
        }
    }

}
