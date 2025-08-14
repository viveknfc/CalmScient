//
//  Header.swift
//  CalmscientIOS
//
//  Created by Krishna on 8/13/24.
//

import UIKit


class HeaderView: UICollectionReusableView {
    static let identifier = "HeaderView"

    private let label: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont(name: Fonts().lexendRegular, size: 20)
            label.textColor = .black
            label.textAlignment = .center
            return label
        }()
    
    private let underlineView: UIView = {
           let view = UIView()
        view.backgroundColor = UIColor.separator.withAlphaComponent(0.2)
           view.translatesAutoresizingMaskIntoConstraints = false
           return view
       }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
//        addSubview(underlineView)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // Underline View Constraints
//        NSLayoutConstraint.activate([
//           underlineView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 4),
//           underlineView.leadingAnchor.constraint(equalTo: leadingAnchor), // Full-width start
//           underlineView.trailingAnchor.constraint(equalTo: trailingAnchor), // Full-width end
//           underlineView.heightAnchor.constraint(equalToConstant: 1)
//               ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with text: String) {
        label.textColor = (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as! Bool ? .white : UIColor(hex: "#424242")
        label.text = text
    }
}
