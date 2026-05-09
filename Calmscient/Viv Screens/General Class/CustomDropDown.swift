//
//  CustomDropDown.swift
//  CalmscientIOS
//
//  Created by NFC User on 27/01/25.
//

import Foundation
import UIKit

class DropdownView: UIView {
    var editButton: UIButton = UIButton(type: .system)
    var deleteButton: UIButton = UIButton(type: .system)
    weak var cell: UITableViewCell?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4

//        editButton.setTitle("Edit", for: .normal)
//        deleteButton.setTitle("Delete", for: .normal)
        
        editButton.setTitle("Edit".localized, for: .normal)
        deleteButton.setTitle("Delete".localized, for: .normal)

        
        editButton.setImage(UIImage(named: "editIcon"), for: .normal)  // Replace with your image
        deleteButton.setImage(UIImage(named: "deleteIcon"), for: .normal)
        
        editButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 15)
        deleteButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 15)
        
        editButton.setTitleColor(.black, for: .normal)  // Replace with your desired color
        deleteButton.setTitleColor(.black, for: .normal)
        
        editButton.contentHorizontalAlignment = .leading
        deleteButton.contentHorizontalAlignment = .leading
        
        editButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)  // Adjust image position
        deleteButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)  // Adjust image position
        
        editButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)  // Add space after the image
        deleteButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

        editButton.tintColor = UIColor(named: "circleCellSelectedColor")  // Set the tint color for the image
        deleteButton.tintColor = UIColor(named: "circleCellSelectedColor")
        
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [editButton, deleteButton])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8)
        ])
    }
    
    func configure(with cell: UITableViewCell) {
           self.cell = cell
       }

       @objc func editButtonTapped() {
           print("Edit button tapped")
           guard let cell = cell as? EditableCell, let delegate = cell.delegate else { return }
           delegate.didTapEditButton(in: cell as! UITableViewCell)
//           guard let cell = cell, let delegate = (cell as? UserMedicationsTableCell)?.delegate else { return }
//           delegate.didTapEditButton(in: cell)
           delegate.dismissDropdown()
       }

       @objc func deleteButtonTapped() {
           print("Delete button tapped")
           guard let cell = cell as? EditableCell, let delegate = cell.delegate else { return }
           delegate.didTapDeleteButton(in: cell as! UITableViewCell)
//           guard let cell = cell, let delegate = (cell as? UserMedicationsTableCell)?.delegate else { return }
//           delegate.didTapDeleteButton(in: cell)
           delegate.dismissDropdown()
       }
}
