
import UIKit

class CustomAlertMoreInfoView: UIView {

    @IBOutlet weak var moreInfoLabel: UILabel!
    
    @IBOutlet weak var descriptionLbl: UILabel!
    
    @IBOutlet weak var highlightLbl: UILabel!
    
    @IBOutlet weak var cancelButton: BorderShadowButton!
    @IBOutlet weak var okButton: LinearGradientButton!
    
    
    @IBOutlet weak var lebelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    
//    @IBOutlet weak var textView2: UITextView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromNib(nibName: "CustomAlertMoreInfoView")
        UISetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib(nibName: "CustomAlertMoreInfoView")
        UISetup()
    }
    
    public var okAction:(() -> Void)?
    
    func UISetup(){
        
//        cancelButton.bottomGradientColor = .white
//        cancelButton.topGradientColor = .white
        
        let description = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "This assessment is based on the Patient Health Questionnaire (PHQ), which is a self-administered version of the PRIME-MD diagnostic instrument for common mental disorders.\n\nPHQ9 Copyright © Pfizer Inc. All rights reserved. Reproduced with permission. PRIME-MD ® is a trademark of Pfizer Inc." : "Esta evaluación se basa en el Cuestionario de salud del paciente (PHQ), que es una versión autoadministrada del instrumento de diagnóstico PRIME-MD para trastornos mentales comunes.\n\nPHQ9 Copyright © Pfizer Inc. Todos los derechos reservados. Reproducido con permiso. PRIME-MD® es una marca comercial de Pfizer Inc."

        descriptionLbl.text = description
        cancelButton.setAttributedTitleWithGradientDefaults(title: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Cancel" : "Cancelar")
        cancelButton.layer.borderWidth = 2
        cancelButton.layer.borderColor = UIColor(named: "AppThemeColor")?.cgColor
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.cornerRadius = cancelButton.frame.height/2
        cancelButton.titleLabel?.highlightedTextColor = UIColor(named: "AppThemeColor")
        
        okButton.setAttributedTitleWithGradientDefaults(title: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Ok" : "De acuerdo")
        
        
        // Create an attributed string with the text and add the underline attribute
        let underLinetext = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "US National Institute of HealthAmerican Psychological AssociationStamford University" : "Instituto Nacional de Salud de EE. UU.Asociación Americana de PsicologíaUniversidad de Stamford"
        let attributedString = NSMutableAttributedString(string: underLinetext)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: underLinetext.count))
        highlightLbl.attributedText = attributedString
        
 
        highlightLbl.font = UIFont(name: Fonts().lexendMedium, size: 15)
        
        moreInfoLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "More Info" : "Más información"
        moreInfoLabel.font = UIFont(name: Fonts().lexendSemiBold, size: 19)
        descriptionLbl.font = UIFont(name: Fonts().lexendLight, size: 15)
        let screenSize = UIScreen.main.bounds.size
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        if traitCollection.userInterfaceIdiom == .phone {
            if screenHeight > 800 {
                // iPhones with larger screens (like iPhone X and above)
                print("big mobbbbb")
                lebelHeightConstraint.constant = 25
                descriptionHeight.constant = 220
            } else {
                print("small mobbbbb")
                lebelHeightConstraint.constant = 3
                // Smaller iPhones (like iPhone 8 and below)
            }
        }
        self.inputView?.reloadInputViews()
//        addAttributeText()
    }
    
//    func addAttributeText(){
//        guard let text = textView2.text, text.count > 0 else { return }
//        let textRange = (text as NSString).range(of: text)
//        let attributedText = NSMutableAttributedString(string: text)
//        attributedText.addAttribute(.underlineStyle,
//                                    value: NSUnderlineStyle.single.rawValue,
//                                    range: textRange)
//        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(named: "MedicationsCellSubtitleColor") ?? UIColor.white, range: textRange)
//        attributedText.addAttributes([.font: (UIFont(name: Fonts().lexendSemiBold, size: 15.0) ?? UIFont.systemFont(ofSize: 15))], range: NSRange(0..<text.count))
//        // Add other attributes if needed
//        self.textView2.attributedText = attributedText
//        textView2.textAlignment = .center
//        
//        self.textView2.isUserInteractionEnabled = true
//        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tappedOntextView2Label(_ :)))
//        tapgesture.numberOfTapsRequired = 1
//        self.textView2.addGestureRecognizer(tapgesture)
//    }
    
    //MARK:- tappedOnLabel
//    @objc func tappedOntextView2Label(_ gesture: UITapGestureRecognizer) {
//        guard let text = self.textView2.text else { return }
//        let allRange = (text as NSString).range(of: text)
////        if gesture.didTapAttributedTextInLabel(label: self.textView2, inRange: allRange) {
////            print("user tapped on textview2")
////        }
//    }
    
    
    
    
    private func loadViewFromNib(nibName: String) {
        let bundle = Bundle(for: type(of: self))
        print(bundle)
        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

    deinit {
        print("CustomAlertMoreInfoView Deinit called")
    }
    
    @IBAction func cancelAction(_ sender: LinearGradientButton) {
        self.okAction?()
    }
    
    @IBAction func okAction(_ sender: LinearGradientButton) {
        self.okAction?()
    }
    
}
