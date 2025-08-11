//
//  GlossyController.swift
//  CalmscientIOS
//
//  Created by BVK on 30/09/24.
//

import UIKit

struct TermData {
    let term: String
    let summary: String
}
struct TermData1 {
    let term1: String
    let summary1: String
}

class GlossyController: ViewController,  UITableViewDataSource, UITableViewDelegate {
    var selectedIndexPath: IndexPath?
    
    @IBOutlet weak var glossyTableview: UITableView!
    let termsData: [TermData] = [
        TermData(term: "Adrenaline", summary: "Adrenaline, also known as epinephrine, is a hormone and neurotransmitter produced by the adrenal glands, which are located on top of the kidneys. It plays a crucial role in the body's response to stress and triggering the \"Fight or Flight\" response.\nWhen a person perceives a threat or danger, whether real or perceived, the brain signals the adrenal glands to release adrenaline into the bloodstream. Adrenaline acts as a chemical messenger, rapidly preparing the body for action to deal with the perceived threat."),
        
        TermData(term: "Anxiety attack", summary: "The term \"anxiety attack\" is not officially recognized in the diagnostic manuals; DSM-5 (Diagnostic and Statistical Manual of Mental Disorders). It is often used to describe a period of heightened anxiety or a more prolonged state of anxiousness. Anxiety attacks may involve similar symptoms to panic attacks, such as excessive worry, restlessness, irritability, muscle tension, difficulty concentrating, and sleep disturbances."),
        
        TermData(term: "Automatic thinking", summary: "Automatic thinking refers to the rapid, involuntary, and often unconscious thoughts that arise in response to situations or triggers. These thoughts are automatic in the sense that they occur automatically and effortlessly, without deliberate intention or conscious awareness.\nAutomatic thinking patterns can be influenced by past experiences, beliefs, and cognitive biases. They can be helpful or unhelpful, depending on their content and impact on emotions and behaviors. In the context of anxiety, automatic thoughts often lean towards negative and worrisome interpretations of situations, leading to increased anxiety and distress."),
        
        TermData(term: "Biased thinking", summary: "Biased thinking refers to cognitive distortions or errors in thinking that influence how we perceive and interpret information. It involves a tendency to view situations, events, or ourselves in a distorted or exaggerated manner, often leading to negative or irrational thoughts. Biased thinking can contribute to the development and maintenance of anxiety and other mental health issues."),
        
        TermData(term: "Cortisol", summary: "Cortisol is a hormone produced by the adrenal glands in response to stress. It is often referred to as the primary stress hormone. When the brain detects a threat or perceives stress, it signals the release of cortisol into the bloodstream. While cortisol is important for short-term stress adaptation, chronic or prolonged elevation of cortisol levels due to chronic stress can cause a loss of neurons in the prefrontal cortex and hippocampus. It also decreases serotonin, the “happy hormone”, which makes a person feel angry, depressed, and feel physical pain more quickly and easily."),
        
        TermData(term: "Cognitive distortion", summary: "Cognitive distortions, also known as biased thinking or irrational thoughts, refer to exaggerated or irrational patterns of thinking that can contribute to emotional distress and maintain anxiety or other mental health issues.\nCognitive distortions are common and can affect the way individuals interpret and perceive events, situations, and themselves. They often involve biases or errors in reasoning that lead to distorted or negative thinking patterns."),
        
        TermData(term: "Competency", summary: "Competency refers to the ability to perform or execute a task or set of skills effectively. It is often associated with knowledge, expertise, and proficiency in a particular area. Competency is measured by evaluating our aptitude, qualifications, or capabilities in a specific situation."),
        
        TermData(term: "Compulsive behavior", summary: "Compulsive behavior refers to repetitive and often ritualistic actions or thoughts that individuals feel driven to perform in response to anxiety or distressing thoughts. These behaviors are typically aimed at reducing anxiety, preventing perceived harm, or maintaining a sense of control. However, they are often excessive, time-consuming, and interfere with daily functioning."),
        
        TermData(term: "Dependency", summary: "Dependency refers to reliance on substances such as alcohol, drugs, or tobacco as a means of coping with anxiety or seeking quick relief or escape from anxiety or help coping with overwhelming emotions. However, substance dependency can be problematic and can lead to long-term physical, psychological, and social consequences."),
        
        TermData(term: "GABA", summary: "GABA stands for gamma-aminobutyric acid, which is a neurotransmitter in the brain. It is known as the brain's natural anti-anxiety drug because it has inhibitory effects on the central nervous system, helping to reduce neuronal excitability and promote relaxation. GABA acts as a calming agent, counteracting the effects of excitatory neurotransmitters in the brain.\nBy increasing GABA levels through exercise, individuals may experience a reduction in anxiety symptoms, improved mood, and an overall sense of well-being. This is one of the ways in which exercise can have a positive impact on mental health and help alleviate anxiety."),
        
        TermData(term: "Hyperventilation", summary: "Hyperventilation refers to a rapid or excessive increase in breathing rate and volume. It involves taking in more oxygen and exhaling more carbon dioxide than the body needs. Hyperventilation can be a physiological response to anxiety or stress and is often associated with panic attacks."),
        
        TermData(term: "Mindful breathing", summary: "Mindful breathing is a technique that involves intentionally bringing awareness to the breath and focusing on the present moment. It is a fundamental practice in mindfulness and can help promote relaxation, reduce stress, and cultivate a sense of calm."),
        
        TermData(term: "Obsession", summary: "Obsession refers to intrusive, persistent, and unwanted thoughts, images, or urges that repeatedly and uncontrollably enter a person's mind. Individuals with obsessions often recognize that their thoughts are irrational or excessive, but they find it challenging to dismiss or ignore them. As a result, they may engage in various repetitive behaviors or mental rituals, known as compulsions, to alleviate the anxiety caused by the obsessions temporarily."),
        
        TermData(term: "Panic attack", summary: "A panic attack is a sudden and intense episode of fear or discomfort that typically peaks within minutes. It is a manifestation of anxiety and can occur without any apparent trigger or in response to a specific situation or object. Panic attacks can be accompanied by various physical and psychological symptoms, such as a rapid heart rate, chest pain, shortness of breath, dizziness, trembling, sweating, a sense of impending doom or loss of control, and feelings of unreality or detachment."),
        
        TermData(term: "Progressive muscle relaxation", summary: "Progressive muscle relaxation (PMR) is a relaxation technique that involves systematically tensing and relaxing different muscle groups in the body. It aims to reduce muscle tension, release physical stress, and promote overall relaxation."),
        
        TermData(term: "Resilience", summary: "Resilience refers to the capacity to bounce back, adapt, and recover in the face of adversity, challenges, or stressful situations. It is the ability to withstand, cope with, and effectively navigate through difficulties, setbacks, or hardships. Resilience involves psychological, emotional, and sometimes physical strength to maintain a positive mindset and being able to function despite adversity.\nResilience is not about avoiding or eliminating challenges, but rather about how we respond and recover from them. It involves skills such as emotional regulation, problem-solving, flexibility, optimism, and social support. Resilience helps us persevere, learn from setbacks, and grow stronger as a result."),
        
        TermData(term: "Rigid thinking", summary: "Rigid thinking refers to inflexible and narrow patterns of thinking that limit flexibility, adaptability, and open-mindedness. People with rigid thinking tend to adhere strictly to their beliefs, rules, and expectations without considering alternative perspectives or possibilities. They may have a black-and-white view of the world, categorizing things as either all good or all bad, with little room for shades of gray or ambiguity.\nWhen faced with challenges or uncertainties, individuals with rigid thinking may become overwhelmed or stuck, as they struggle to adapt and find alternative solutions. Rigid thinking can also lead to self-criticism, perfectionism, and a constant need for control, which can perpetuate anxiety and stress."),
        
        TermData(term: "Rumination", summary: "The tendency to continuously and excessively think about negative events, situations, or problems. It involves repetitively focusing on one's distressing thoughts, often with a lack of resolution or progress toward a solution.\nRumination is a common cognitive process associated with anxiety and other mental health conditions. When someone ruminates, they may replay past events, worry about future outcomes, or excessively analyze their thoughts and feelings. This prolonged dwelling on negative thoughts can contribute to heightened anxiety and a sense of feeling stuck or trapped in one's worries."),
        
        TermData(term: "Self-compassion", summary: "Self-compassion refers to the practice of treating oneself with kindness, understanding, and non-judgment during times of difficulty, failure, or suffering. It involves extending the same warmth, care, and support to oneself that one would offer to a close friend or loved one who is struggling."),
        
        TermData(term: "Serotonin", summary: "Serotonin is a neurotransmitter, a chemical messenger in the brain and nervous system that plays a crucial role in regulating various physiological and psychological processes. It is often referred to as the \"feel-good\" neurotransmitter because of its association with mood regulation and feelings of well-being."),
        
        TermData(term: "Window of tolerance", summary: "Window of tolerance refers to a concept in psychology that describes an optimal range of arousal or activation that allows an individual to effectively cope with and respond to stressors and emotions. The window of tolerance suggests that individuals have a range in which they can handle and adapt to stressors without becoming overwhelmed or shutting down. When a person is within their window of tolerance, they are able to think clearly, make rational decisions, and engage in effective problem-solving. They are also able to experience and regulate emotions in a balanced and healthy manner.")
    ]

    let termsData1: [TermData1] = [
        TermData1(term1: "Adrenalina", summary1: "La adrenalina, también conocida como epinefrina, es una hormona y un neurotransmisor producido por las glándulas suprarrenales, que se encuentran encima de los riñones. Desempeña un papel crucial en la respuesta del cuerpo al estrés y desencadena la respuesta de 'lucha o huida'. Cuando una persona percibe una amenaza o peligro, ya sea real o percibido, el cerebro envía señales a las glándulas suprarrenales para que liberen adrenalina en el torrente sanguíneo. La adrenalina actúa como mensajero químico, preparando rápidamente al cuerpo para actuar y hacer frente a la amenaza percibida."),
        
        TermData1(term1: "Ataque de ansiedad", summary1: "El término 'ataque de ansiedad' no está reconocido oficialmente en los manuales de diagnóstico; DSM-5 (Manual Diagnóstico y Estadístico de los Trastornos Mentales). A menudo se utiliza para describir un período de mayor ansiedad o un estado de ansiedad más prolongado. Los ataques de ansiedad pueden implicar síntomas similares a los ataques de pánico, como preocupación excesiva, inquietud, irritabilidad, tensión muscular, dificultad para concentrarse y alteraciones del sueño."),
        
        TermData1(term1: "Pensamiento automático", summary1: "El pensamiento automático se refiere a los pensamientos rápidos, involuntarios y, a menudo, inconscientes que surgen en respuesta a situaciones o desencadenantes. Estos pensamientos son automáticos en el sentido de que ocurren automáticamente y sin esfuerzo, sin intención deliberada ni conciencia consciente. Los patrones de pensamiento automático pueden verse influenciados por experiencias, creencias y sesgos cognitivos pasados."),
        
        TermData1(term1: "Pensamiento sesgado", summary1: "El pensamiento sesgado se refiere a distorsiones cognitivas o errores en el pensamiento que influyen en cómo percibimos e interpretamos la información. Implica una tendencia a ver situaciones, acontecimientos o a nosotros mismos de manera distorsionada o exagerada, lo que a menudo conduce a pensamientos negativos o irracionales."),
        
        TermData1(term1: "Cortisol", summary1: "El cortisol es una hormona producida por las glándulas suprarrenales en respuesta al estrés. A menudo se la conoce como la principal hormona del estrés. Cuando el cerebro detecta una amenaza o percibe estrés, indica la liberación de cortisol al torrente sanguíneo."),
        
        TermData1(term1: "Distorsión cognitiva", summary1: "Las distorsiones cognitivas, también conocidas como pensamiento sesgado o pensamientos irracionales, se refieren a patrones de pensamiento exagerados o irracionales que pueden contribuir a la angustia emocional y mantener la ansiedad u otros problemas de salud mental."),
        
        TermData1(term1: "Competencia", summary1: "La competencia se refiere a la capacidad de realizar o ejecutar una tarea o un conjunto de habilidades de manera efectiva. A menudo se asocia con el conocimiento, la experiencia y la competencia en un área en particular."),
        
        TermData1(term1: "Comportamiento compulsivo", summary1: "El comportamiento compulsivo se refiere a acciones o pensamientos repetitivos y a menudo rituales que los individuos se sienten impulsados a realizar en respuesta a la ansiedad o pensamientos angustiosos."),
        
        TermData1(term1: "Dependencia", summary1: "La dependencia se refiere a la dependencia de sustancias como el alcohol, las drogas o el tabaco como medio para afrontar la ansiedad o buscar un alivio rápido."),
        
        TermData1(term1: "GABA", summary1: "GABA significa ácido gamma-aminobutírico, que es un neurotransmisor en el cerebro. Se le conoce como el ansiolítico natural del cerebro porque tiene efectos inhibidores sobre el sistema nervioso central, ayudando a reducir la excitabilidad neuronal y promover la relajación."),
        
        TermData1(term1: "Hiperventilación", summary1: "La hiperventilación se refiere a un aumento rápido o excesivo de la frecuencia y el volumen de la respiración. Implica tomar más oxígeno y exhalar más dióxido de carbono del que el cuerpo necesita."),
        
        TermData1(term1: "Respiración consciente", summary1: "La respiración consciente es una técnica que implica concienciar intencionalmente de la respiración y concentrarse en el momento presente."),
        
        TermData1(term1: "Obsesión", summary1: "La obsesión se refiere a pensamientos, imágenes o impulsos intrusivos, persistentes y no deseados que entran repetida e incontrolablemente en la mente de una persona."),
        
        TermData1(term1: "Ataque de pánico", summary1: "Un ataque de pánico es un episodio repentino e intenso de miedo o malestar que normalmente alcanza su punto máximo en cuestión de minutos."),
        
        TermData1(term1: "Relajación muscular progresiva", summary1: "La relajación muscular progresiva (PMR) es una técnica de relajación que consiste en tensar y relajar sistemáticamente diferentes grupos de músculos del cuerpo."),
        
        TermData1(term1: "Resiliencia", summary1: "La resiliencia se refiere a la capacidad de recuperarse, adaptarse y recuperarse ante la adversidad, los desafíos o las situaciones estresantes."),
        
        TermData1(term1: "Pensamiento rígido", summary1: "El pensamiento rígido se refiere a patrones de pensamiento inflexibles y estrechos que limitan la flexibilidad, la adaptabilidad y la apertura de mente."),
        
        TermData1(term1: "Rumia", summary1: "La tendencia a pensar continua y excesivamente en eventos, situaciones o problemas negativos. Implica concentrarse repetidamente en los pensamientos angustiosos."),
        
        TermData1(term1: "Autocompasión", summary1: "La autocompasión se refiere a la práctica de tratarse a uno mismo con amabilidad, comprensión y sin juzgarse en momentos de dificultad."),
        
        TermData1(term1: "Serotonina", summary1: "La serotonina es un neurotransmisor, un mensajero químico en el cerebro y el sistema nervioso que desempeña un papel crucial en la regulación de diversos procesos fisiológicos y psicológicos."),
        
        TermData1(term1: "Ventana de tolerancia", summary1: "La ventana de tolerancia se refiere a un concepto en psicología que describe un rango óptimo de excitación o activación que permite a un individuo afrontar y responder eficazmente a los factores estresantes y las emociones.")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        glossyTableview.dataSource = self
        glossyTableview.delegate = self
        glossyTableview.translatesAutoresizingMaskIntoConstraints = false
        glossyTableview.register(UINib(nibName: "glossyTableCellTableViewCell", bundle: nil), forCellReuseIdentifier: "glossyTableCellTableViewCell")
        
        glossyTableview.rowHeight = UITableView.automaticDimension
        glossyTableview.estimatedRowHeight = 100
 
    }

    override func viewWillAppear(_ animated: Bool) {//kiran diagnostics
        super.viewWillAppear(animated)
    
        self.title = AppHelper.getLocalizeString(str:"Glossary") // Please check the localisation for Glossy we replaced with Glossary
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return termsData.count
        }
        
    // There is just one row in every section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "glossyTableCellTableViewCell", for: indexPath) as! glossyTableCellTableViewCell
 
        let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
                   
        if languageId == 1 {
            let termData = termsData[indexPath.section] //indexPath.section
            cell.titleLabel?.text = termData.term
            cell.summaryLabel.text = termData.summary
            cell.roundLabel.text = String(termData.term.prefix(1)).uppercased()
        }
        else {
            let termData1 = termsData1[indexPath.section] //indexPath.section
            cell.titleLabel?.text = termData1.term1
            cell.summaryLabel.text = termData1.summary1
            cell.roundLabel.text = String(termData1.term1.prefix(1)).uppercased()
        }
 
        cell.contentView.applyShadow()
        
        let isExpanded = (selectedIndexPath == indexPath)
        cell.isExpanded = isExpanded
        print("the cell is exapnded value is ", isExpanded)

        cell.selectionStyle = .none
        return cell
    }


        // MARK: - UITableViewDelegate methods

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var indexPathsToReload: [IndexPath] = []

        if let previousIndexPath = selectedIndexPath {
            indexPathsToReload.append(previousIndexPath)
        }

        if selectedIndexPath == indexPath {
            // Collapse the same cell
            selectedIndexPath = nil
        } else {
            // Expand the new cell
            selectedIndexPath = indexPath
            indexPathsToReload.append(indexPath)
        }

        // Reload affected rows (collapse previous and expand current)
        tableView.reloadRows(at: indexPathsToReload, with: .automatic)
    }

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
 
            if selectedIndexPath == indexPath {
                return UITableView.automaticDimension // Expand to fit the summary text
            } else {
                return 75 // Default collapsed height
            }
        }
    }






