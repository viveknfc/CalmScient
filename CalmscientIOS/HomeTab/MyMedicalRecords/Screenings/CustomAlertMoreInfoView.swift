
import UIKit

class CustomAlertMoreInfoView: UIView {

    @IBOutlet weak var moreInfoLabel: UILabel!
    
    @IBOutlet weak var descriptionLbl: UILabel!
    
    @IBOutlet weak var highlightLbl: UILabel!

    @IBOutlet weak var okButton: LinearGradientButton!
    
    
    @IBOutlet weak var lebelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionHeight: NSLayoutConstraint!
    
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
        
        let description = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "This assessment is based on the Patient Health Questionnaire (PHQ), which is a self-administered version of the PRIME-MD diagnostic instrument for common mental disorders.\n\nPHQ9 Copyright © Pfizer Inc. All rights reserved. Reproduced with permission. PRIME-MD ® is a trademark of Pfizer Inc." : "Esta evaluación se basa en el Cuestionario de salud del paciente (PHQ), que es una versión autoadministrada del instrumento de diagnóstico PRIME-MD para trastornos mentales comunes.\n\nPHQ9 Copyright © Pfizer Inc. Todos los derechos reservados. Reproducido con permiso. PRIME-MD® es una marca comercial de Pfizer Inc."

        descriptionLbl.text = description
        
        okButton.setAttributedTitleWithGradientDefaults(title: UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Ok" : "Ok")
        
        
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
                lebelHeightConstraint.constant = 10
//                descriptionHeight.constant = 80
            } else {
                print("small mobbbbb")
                lebelHeightConstraint.constant = 3
                // Smaller iPhones (like iPhone 8 and below)
            }
        }
        self.inputView?.reloadInputViews()
//        addAttributeText()
    }
  
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
