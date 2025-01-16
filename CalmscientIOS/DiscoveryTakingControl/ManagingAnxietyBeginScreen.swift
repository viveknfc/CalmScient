//
//  ManagingAnxietyBeginScreen.swift
//  CalmscientIOS
//
//  Created by BVK on 21/08/24.
//

import UIKit

class ManagingAnxietyBeginScreen: ViewController {

    @IBOutlet weak var letsBeginButton: LinearGradientButton!
    @IBOutlet weak var managingTextView: UITextView!
    
    @IBOutlet weak var calmsLabels: UILabel!
    @IBOutlet weak var areYouReadyLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "Managing anxiety" : "Manejo de la Ansiedad"
        managingTextView.font = UIFont(name: Fonts().lexendLight, size: 16)
        calmsLabels.font = UIFont(name: Fonts().lexendMedium, size: 16)
        letsBeginButton.titleLabel?.font = UIFont(name: Fonts().lexendSemiBold, size: 18)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        letsBeginButton.setTitle(UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Let's begin!" : "¡Empecemos!", for: .normal)
        areYouReadyLbl.font = UIFont(name: Fonts().lexendRegular, size: 22)
        areYouReadyLbl.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Are you ready?" : "¿Estás listo?"
        
        calmsLabels.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "The Calmscient discovery will only be as effective as you make it." : "El descubrimiento de Calmscient será tan efectivo como usted lo haga."
        
        managingTextView.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "So be determined to dedicate time to following along and completing the exercises. Each section has interesting and informative content that is designed to keep you actively thinking about your specific challenges. But, like taking a road trip to an unknown destination, you’ll need to be committed to following the map! It may be a little more work than you’re used to, but it will absolutely pay off in the end." : "Así que esté decidido a dedicar tiempo a seguir y completar los ejercicios. Cada sección tiene contenido interesante e informativo diseñado para mantenerlo pensando activamente en sus desafíos específicos. Pero, al igual que hacer un viaje por carretera a un destino desconocido, ¡deberás comprometerte a seguir el mapa! Puede que suponga un poco más de trabajo del que estás acostumbrado, pero al final dará sus frutos."

    }
    @IBAction func letBeginButtonAction(_ sender: Any) {
        
        let backItem = UIBarButtonItem()
        backItem.title = "" // Set an empty string for the back button
        self.navigationItem.backBarButtonItem = backItem
        
        let next = UIStoryboard(name: "CourseViewController", bundle: nil)
        let vc = next.instantiateViewController(withIdentifier: "CoursesViewController") as? CoursesViewController
        vc?.title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  "Managing anxiety" : "Manejo de la Ansiedad"
        vc?.courseID = 2
        self.navigationController?.pushViewController(vc!, animated: true)
    }

}
