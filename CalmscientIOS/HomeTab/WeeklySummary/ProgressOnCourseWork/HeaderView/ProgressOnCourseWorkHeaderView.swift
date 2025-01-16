//
//  ProgressOnCourseWorkHeaderView.swift
//  CalmscientIOS
//
//  Created by NFC on 29/04/24.
//

import UIKit

class ProgressOnCourseWorkHeaderView: UIView {

    @IBOutlet var mainView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    
 
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromNib(nibName: "ProgressOnCourseWorkHeaderView")
        addShadowAndBorder()
        progressView.subviews.forEach { subview in
            subview.layer.masksToBounds = true
            subview.layer.cornerRadius = 6
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib(nibName: "ProgressOnCourseWorkHeaderView")
        addShadowAndBorder()
        cellTitleLabel.text = AppHelper.getLocalizeString(str: "DRINKING_CONTROL_Total_Course_Work_Completed")
        courseLabel.font = UIFont(name: Fonts().lexendMedium, size: 15)
        courseLabel.text = AppHelper.getLocalizeString(str: "Course")
        completedLabel.font = UIFont(name: Fonts().lexendMedium, size: 15)
        completedLabel.text = "% " + AppHelper.getLocalizeString(str: "Completed")
        progressView.subviews.forEach { subview in
            subview.layer.masksToBounds = true
            subview.layer.cornerRadius = 6
        }
        
    }
    
    fileprivate func addShadowAndBorder() {
        shadowView.layer.backgroundColor = UIColor.clear.cgColor
        shadowView.layer.shadowColor = UIColor(named: "AppViewShadowColor")?.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2.0
        
//        borderView.layer.cornerRadius = 8
//        borderView.layer.masksToBounds = true
//        borderView.layer.borderWidth = 1
//        borderView.layer.borderColor = UIColor(named: "AppViewBorderColor")?.cgColor
        borderView.applyShadow()
    }
    
    private func loadViewFromNib(nibName: String) {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
}
