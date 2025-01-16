//
//  CustomAlertView1.swift
//  CalmscientIOS
//
//  Created by BVK on 03/07/24.
//

import Foundation
import UIKit

class CustomAlertView1: UIView {
    
    let alertIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "exclamationmark.triangle.fill") // Use SF Symbol for simplicity
        imageView.tintColor = .red
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "You selected more than what is suggested"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dismiss", for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemPurple.cgColor
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let changeGoalButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change goal", for: .normal)
        button.backgroundColor = UIColor.systemPurple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        setupLanguage()
        backgroundColor = .white
        layer.cornerRadius = 15
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        addSubview(alertIcon)
        addSubview(messageLabel)
        addSubview(dismissButton)
        addSubview(changeGoalButton)
        addSubview(closeButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            alertIcon.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            alertIcon.centerXAnchor.constraint(equalTo: centerXAnchor),
            alertIcon.heightAnchor.constraint(equalToConstant: 40),
            alertIcon.widthAnchor.constraint(equalToConstant: 40),
            
            messageLabel.topAnchor.constraint(equalTo: alertIcon.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            dismissButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            dismissButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            dismissButton.heightAnchor.constraint(equalToConstant: 40),
            dismissButton.widthAnchor.constraint(equalToConstant: 100),
            
            changeGoalButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            changeGoalButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            changeGoalButton.heightAnchor.constraint(equalToConstant: 40),
            changeGoalButton.widthAnchor.constraint(equalToConstant: 100),
            
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        
        messageLabel.text = AppHelper.getLocalizeString(str: "You selected more than what is suggested")
        dismissButton.titleLabel!.text = AppHelper.getLocalizeString(str: "Dismiss" )
        changeGoalButton.titleLabel!.text = AppHelper.getLocalizeString(str:"Change goal")
        
        }
}
