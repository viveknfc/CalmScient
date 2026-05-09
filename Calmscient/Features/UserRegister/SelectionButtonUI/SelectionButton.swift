//
//  SelectionButton.swift
//  HealthApp
//
//

import Foundation
import UIKit

public enum SelectionButtonState {
    case dafault
    case selected
    
    func getAssetImageForState() -> UIImage? {
        switch self {
        case.dafault: return UIImage(named: "cellUnselectedImage")
        case .selected: return UIImage(named: "CellSelectionImage")
        }
    }
}

class SelectionButton : UIView {
    
    @IBOutlet weak var userSelectionImage: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var rememberMeImg: UIImageView!
    @IBOutlet weak var rememberMeLabel: UILabel!
    
    
    public var isSelected = true
    private var buttonState:SelectionButtonState = .selected {
        didSet {
            self.isSelected = (buttonState == .selected)
        }
    }
    
    var rememberMeState:SelectionButtonState = .dafault {
        didSet {

        }
    }
    
    var isRememberMeSelected: Bool {
        return rememberMeState == .selected
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromNib(nibName: "SelectionButton")
        setupInitialStates()
        setupGestureRecognizers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib(nibName: "SelectionButton")
        setupInitialStates()
        setupGestureRecognizers()
    }
    
    private func setupInitialStates() {
           userSelectionImage.image = buttonState.getAssetImageForState()
           rememberMeImg.image = rememberMeState.getAssetImageForState()
       }
    
    private func setupGestureRecognizers() {
        let userSelectionTap = UITapGestureRecognizer(target: self, action: #selector(didTapOnUserSelectionImage))
        userSelectionImage.isUserInteractionEnabled = true
        userSelectionImage.addGestureRecognizer(userSelectionTap)
        
        let rememberMeTap = UITapGestureRecognizer(target: self, action: #selector(didTapOnRememberMeImage))
        rememberMeImg.isUserInteractionEnabled = true
        rememberMeImg.addGestureRecognizer(rememberMeTap)
    }
    
    @objc private func didTapOnUserSelectionImage() {
        buttonState = (buttonState == .dafault) ? .selected : .dafault
        UIView.transition(with: userSelectionImage, duration: 0.5, options: .transitionCrossDissolve) {
            self.userSelectionImage.image = self.buttonState.getAssetImageForState()
        }
    }
    
    @objc private func didTapOnRememberMeImage() {
        rememberMeState = (rememberMeState == .dafault) ? .selected : .dafault
        UIView.transition(with: rememberMeImg, duration: 0.5, options: .transitionCrossDissolve) {
            self.rememberMeImg.image = self.rememberMeState.getAssetImageForState()
        }

    }
    
    private func loadViewFromNib(nibName: String? = "\(type(of: SelectionButton.self))") {
        guard let nibName = nibName else { return }
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        setupLanguage()

    }
    func setupLanguage() {
        
contentLabel.text = AppHelper.getLocalizeString(str: "I agree to share my info with medical provider")
        rememberMeLabel.text = AppHelper.getLocalizeString(str: "Remember me")
        
        }
}
