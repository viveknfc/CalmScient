import UIKit

protocol InfoAlertViewActionProtocol: AnyObject {
    
    func didClickOnCancelButton()
}

class InfoAlert: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var infotableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var alertActionDelegate: InfoAlertViewActionProtocol?
    
    // Sample data for the table view
    var infoItems: [String] =  ["AUDIT","DUST-10","CAGE"]
    var infoalertItems: [String] = ["(Alcohol Use Disorder Identification Test)", "(Drug Abuse Screening Test)", "(Cut, Annoyed, Guilty and Eye)"]
    var spanishInfoItems = ["(Test de Identificación de Trastornos por Consumo de Alcohol)", "(Test de Detección de Abuso de Drogas)","(Cortar, Molestar, Culpable y Ojo)"]
    var details_value: [String] = ["Do you enjoy a drink now or then? Many of us do, often when socializing with friends and family. Let's take a look at your drinking patterns and how they may affect your health.The AUDIT questionnaire is designed to help in the self-assessment of alcohol consumption and to identify any implications for the person's health and well being, now and in the future. Conduct a quick self-test with AUDIT above. Click on \("Submit") at the end for an instant assessment.", "\("Drug use") refers to the use of prescribed or over-the-counter drugs in excess of the directions, and any non medical use of drugs.The various classes of drugs may include cannabis (marijuana, hashish), solvents (e.g., paint thinner), tranquilizers (e.g., valium), barbiturates, cocaine, stimulants (e.g., speed), hallucinogens (e.g., LSD) or narcotics (e.g., heroin). The questions do not include alcoholic beverages. Please answer the questions in this survey. If you have difficulty with a statement, simply choose the best response possible. These questions refer to drug use in the past 12 months. Please answer NO or YES to each question.", "The CAGE questionnaire for smoking (modified from the familiar CAGE questionnaire for alcoholism), the \("four Cs") test and the Fagerström Test for Nicotine Dependence help diagnose nicotine dependence based on standard criteria. Additional questions can  be used to determine a patient's readiness to change and the nature of reinforcement the patient receives  from smoking. These tools can assist family physicians in guiding patients to quit smoking-the single most important thing smokers can do to improve their health."]
    let spanish_details = [
        "¿Disfruta de una bebida de vez en cuando? Muchos de nosotros lo hacemos, a menudo cuando socializamos con amigos y familiares. Echemos un vistazo a sus patrones de consumo de alcohol y cómo pueden afectar su salud. El cuestionario AUDIT está diseñado para ayudar en la autoevaluación del consumo de alcohol e identificar cualquier implicación para la salud y el bienestar de la persona, ahora y en el futuro. Realice una autoevaluación rápida con AUDIT arriba. Haga clic en \"Enviar\" al final para obtener una evaluación instantánea.",
        
        "\"Consumo de drogas\" se refiere al uso de medicamentos recetados o de venta libre en exceso de las indicaciones, y cualquier uso no médico de drogas. Las diversas clases de drogas pueden incluir cannabis (marihuana, hachís), solventes (por ejemplo, diluyente de pintura), tranquilizantes (por ejemplo, valium), barbitúricos, cocaína, estimulantes (por ejemplo, speed), alucinógenos (por ejemplo, LSD) o narcóticos (por ejemplo, heroína). Las preguntas no incluyen bebidas alcohólicas. Por favor, responda las preguntas de esta encuesta. Si tiene dificultades con una afirmación, simplemente elija la mejor respuesta posible. Estas preguntas se refieren al uso de drogas en los últimos 12 meses. Por favor responda NO o SÍ a cada pregunta.",
        
        "El cuestionario CAGE para fumar (modificado del familiar cuestionario CAGE para el alcoholismo), la prueba de las \"cuatro Cs\" y el Test de Fagerström para la Dependencia a la Nicotina ayudan a diagnosticar la dependencia a la nicotina según criterios estándar. Se pueden usar preguntas adicionales para determinar la disposición del paciente para cambiar y la naturaleza del refuerzo que recibe al fumar. Estas herramientas pueden ayudar a los médicos de familia a guiar a los pacientes a dejar de fumar, lo más importante que los fumadores pueden hacer para mejorar su salud."
    ]

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadViewFromNib(nibName: "InfoAlert")
        setupTableView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib(nibName: "InfoAlert")
        setupTableView()
    }
    
    private func loadViewFromNib(nibName: String) {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(view)
    }
    
    private func setupTableView() {
        infotableView.delegate = self
        infotableView.dataSource = self
        //        infotableView.register(UITableViewCell.self, forCellReuseIdentifier: "InfoAlertCell")
        infotableView.register(UINib(nibName: "InfoAlertCell", bundle: nil), forCellReuseIdentifier: "InfoAlertCell")
    }
    
    // UITableViewDataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoAlertCell", for: indexPath) as! InfoAlertCell
        cell.name_label?.text = infoItems[indexPath.row]
        cell.caption_label.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? infoalertItems[indexPath.row] : spanishInfoItems[indexPath.row]
        cell.description_label.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ?  details_value[indexPath.row] : spanish_details[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
    
    // UITableViewDelegate Methods
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Selected \(infoItems[indexPath.row])")
    }
    
    @IBAction func didClickOnCancelButton(_ sender: UIButton) {
        alertActionDelegate?.didClickOnCancelButton()
       
      //  self.removeFromSuperview()
    }
    
    
}
