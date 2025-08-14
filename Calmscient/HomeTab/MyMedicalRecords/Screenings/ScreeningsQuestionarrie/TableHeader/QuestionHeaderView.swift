//
//  QuestionHeaderView.swift
//  CalmscientIOS
//
//  Created by NFC on 27/04/24.
//

import UIKit

class QuestionHeaderView: UIView {

    @IBOutlet weak var headerLabel: UILabel!
    public var onInfoIconClick:(() -> Void)?
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromNib(nibName: "QuestionHeaderView")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib(nibName: "QuestionHeaderView")
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
