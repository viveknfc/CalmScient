//
//  MindfulNess.swift
//  sample
//
//  Created by Krishna on 8/4/24.
//

import Foundation
import UIKit



class MindfulNess: ViewController {
    
    
    @IBOutlet weak var favImg: UIImageView!
    @IBOutlet weak var stepsImgView: UIImageView!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var backActionImg: UIImageView!
    @IBOutlet weak var frontActionImg: UIImageView!
    
    @IBOutlet weak var text1: UILabel!
    @IBOutlet weak var text2: UILabel!
    
    @IBOutlet weak var leftBtn: UIImageView!
    @IBOutlet weak var rightBtn: UIImageView!
    
    @IBOutlet weak var imgStack: UIStackView!
    
    @IBOutlet weak var stackHeight: NSLayoutConstraint!
    
    @IBOutlet weak var completeButton: CapsuleButton1!
    
    var languageId : Int = 1
    var isFav: Int = 0
    var favExcercises:[ExcercisesModel] = []

    
    let textArray = [
        "Have you ever caught your mind wandering or daydreaming while you are in the middle of a familiar or repetitive task? You could be walking, working or even driving your car, and your mind is miles away, perhaps fantasizing about going on vacation, thinking about your to-do list, or worrying about some upcoming event.",
                     
                     "Mindfulness is the opposite of automatic pilot. It is about experiencing the world that is firmly in the ‘here and now’. This is referred to as the being mode. It liberates you from automatic and unhelpful thoughts and responses.",
                     
                     "How does mindfulness help with anxiety?",
                     
    "Mindfulness reminds us that we don’t have to take immediate control of, remove or fix unpleasant experiences. Instead, we can identify and actively engage in something that will give us a sense of safety and connection.",
                     
                     "As a simple example: Instead of focusing on how many miles you walked in the morning, can you be mindfully aware of the birds singing, actively feel the fresh air, and sense the changing of the season? When you connect your senses to nature, animals, people and your own body, you capture the attention of your nervous system, which in turn soothes your anxiety. When you return home, you will be in a better frame of mind and more prepared to face your day.",
                     
                     "Which mindfulness exercises would you like to make part of your daily routine? Calmscient can remind you of some easy mindfulness routines that will help you stay in a healthy, being mode."
    ]
    
    let imagesArray = [
                       UIImage(named: "stpe1_img"),
                       UIImage(named: "step2_img"),
                       UIImage(named: "step3_img"),
                       UIImage(named: "step4_img"),
                       UIImage(named: "step5_img"),
                       UIImage(named: "step6_img"),
                    ]
    
    var counter = 0

    
    func createAttributedString(segments: [(text: String, attributes: [NSAttributedString.Key: Any])]) -> NSMutableAttributedString {
            let attributedString = NSMutableAttributedString()
            
            for segment in segments {
                let attributedSegment = NSAttributedString(string: segment.text, attributes: segment.attributes)
                attributedString.append(attributedSegment)
            }
            
            return attributedString
        }
    
    @objc func bottomBackTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        counter = counter - 1
        if(counter < 0){
            counter = 0
        }
        setupData()
        
    }
    
    @objc func bottomFrontTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        print("front tapped")
        counter = counter + 1
        setupData()
        // Your action
    }
    
    
    func outputAttStr(highlightedStr1: String,normalStr: String)->NSMutableAttributedString{
        let highlightAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor(hex: "#6E6BB3")
        ]

        let attrs2: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor(hex: "#110E0E")
        ]

        // Define the text segments
        let segments = [
            (text: highlightedStr1, attributes: highlightAttr),
            (text: normalStr, attributes: attrs2)
        ]

        // Create the combined attributed string
        let combinedAttributedString = createAttributedString(segments: segments)
        return combinedAttributedString
    }
    
    
    func setupLanguage() {
        
             languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
//        self.titleLabel.text = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Mindfulness - what is it?" : "Mindfulness: ¿qué es?"
        setupData()
        
        }
    
    func setupData(){
        if(counter == 0){
            imgStack.isHidden = true
            stackHeight.constant = 0
            leftBtn.isHidden = true
            // Define the attributes for each text segment
                    let highlightAttr: [NSAttributedString.Key: Any] = [
                        .font: UIFont(name: Fonts().lexendLight, size: 15)!,
                        .foregroundColor: (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as! Bool ? UIColor(hex: "#F48383") : UIColor(hex: "#6E6BB3")
                    ]

                    let attrs2: [NSAttributedString.Key: Any] = [
                        .font: UIFont(name: Fonts().lexendLight, size: 15)!,
                        .foregroundColor: (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as! Bool ? .white : UIColor(hex: "#110E0E")
                        
                    ]

                    // Define the text segments
                    let segments = [
                        (text: languageId == 1 ? "Have you ever caught your mind wandering or daydreaming" : "¿Alguna vez estuviste pensando en otra cosa o soñando despierto", attributes: highlightAttr),
                        (text: languageId == 1 ?  " while you are in the middle of a familiar or repetitive task? You could be walking, working or even driving your car, and your mind is miles away, perhaps fantasizing about going on vacation, thinking about your to-do list, or worrying about some upcoming event." : " mientras estás en medio de una tarea familiar o repetitiva? Podrías estar caminando, trabajando o incluso conduciendo el auto, pero tu mente está a kilómetros de distancia, quizás fantaseando con ir de vacaciones, pensando en tu lista de tareas o preocupándote por algún próximo evento." , attributes: attrs2)
                    ]

                    // Create the combined attributed string
                    let combinedAttributedString = createAttributedString(segments: segments)
                    
            text1.attributedText = combinedAttributedString//textArray[0]
            
            let fulltxt2 = languageId == 1 ? "In either case, you are not focusing on the current situation and not in touch with the ‘here and now’.  This mode of operation is often referred to as automatic pilot." : "En cualquiera de los casos, no estás prestando atención a la situación actual y no estás en contacto con el “aquí y ahora”. \n A este comportamiento se le conoce a menudo como piloto automático."
            
                    // Create a mutable attributed string
                    let attributedString = NSMutableAttributedString(string: fulltxt2, attributes: attrs2)
                    
                    // Define the range of the highlighted text
            let highlightedTextRange = (fulltxt2 as NSString).range(of: languageId == 1 ? "automatic pilot." : "piloto automático" )
                    
                    // Apply the highlighted attributes to the specific range
                    attributedString.addAttributes(highlightAttr, range: highlightedTextRange)
                    
            
            text2.attributedText = attributedString
            stepsImgView.image = UIImage(named: "step1")
            imgView.image = imagesArray[0]
            
        }else if(counter == 1){
            
            leftBtn.isHidden = false
            completeButton.isHidden = true
            stepsImgView.image = UIImage(named: "step2")
            imgView.image = imagesArray[1]
            let highlightAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: Fonts().lexendLight, size: 15)!,
                .foregroundColor: (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as! Bool ? UIColor(hex: "#F48383") : UIColor(hex: "#6E6BB3")
            ]

            let attrs2: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: Fonts().lexendLight, size: 15)!,
                .foregroundColor: (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as! Bool ? .white : UIColor(hex: "#110E0E")
                
            ]
            
            let fullString = languageId == 1 ? "Mindfulness is the opposite of automatic pilot. It is about experiencing the world that is firmly in the ‘here and now’. This is referred to as the being mode. It liberates you from automatic and unhelpful thoughts and responses." : "La conciencia es lo contrario del piloto automático. Se trata de vivir el momento presente, de estar realmente en el “aquí y ahora”. Esto se llama modo de presencia. Te ayuda a liberarte de pensamientos y reacciones automáticas que no son útiles."

            // Create an NSMutableAttributedString with the entire string
            let attributedString = NSMutableAttributedString(string: fullString)

            

            // Apply the default attributes to the entire string
            attributedString.addAttributes(attrs2, range: NSRange(location: 0, length: fullString.count))

            // Define the ranges of the words you want to highlight
            let mindfulnessRange = (fullString as NSString).range(of:languageId == 1 ? "Mindfulness" : "conciencia es" )
            let beingRange = (fullString as NSString).range(of:languageId == 1 ?  "being" : "modo de presencia")

            

            // Apply the highlighted attributes to the specific ranges
            attributedString.addAttributes(highlightAttr, range: mindfulnessRange)
            attributedString.addAttributes(highlightAttr, range: beingRange)

            text1.attributedText = attributedString
            text2.text = ""
        }
        else if(counter == 2){
            text1.text = languageId == 1 ? textArray[2] : "¿Cómo ayuda la atención plena con la ansiedad?"
            text1.font = UIFont(name: Fonts().lexendRegular, size: 15)!
            imgView.image = imagesArray[2]
            completeButton.isHidden = true
            stepsImgView.image = UIImage(named: "step3")
            imgView.contentMode = .scaleAspectFit
            text2.text = languageId == 1 ? "When we allow our brain to enter automatic pilot mode too often, it can be at risk of being conditioned to be overly preoccupied about the future, past experiences or our emotions in negative ways. If we have fallen into this old and unhelpful habit, we can unlearn it and replace it with skills that help us resist ‘buying into’ automatic worry and anxiety. " : "Cuando dejamos que nuestro cerebro entre en modo piloto automático con demasiada frecuencia, corremos el riesgo de acostumbrarnos a preocuparnos en exceso por el futuro, por experiencias pasadas o por nuestras emociones de manera negativa. Si hemos caído en este hábito poco útil, podemos desaprenderlo y reemplazarlo con habilidades que nos ayuden a no dejarnos llevar por la preocupación y la ansiedad automáticas."
        }
        else if(counter == 3){
            text1.text = languageId == 1 ? textArray[3] : "La atención plena nos recuerda que no necesitamos controlar, eliminar o solucionar de inmediato las experiencias desagradables. En lugar de eso, podemos identificar algo que nos haga sentir seguros y conectados, para poder dedicarnos a ello."
            text1.font = UIFont(name: Fonts().lexendLight, size: 15)!
            text2.text = ""
            imgView.contentMode = .scaleAspectFill
            imgView.image = imagesArray[3]
            stepsImgView.image = UIImage(named: "step4")
            completeButton.isHidden = true
        }
        else if(counter == 4){
            imgStack.isHidden = true
            stackHeight.constant = 0
            completeButton.isHidden = true
            rightBtn.isHidden = false
            text1.text = languageId == 1 ? textArray[4] : "Como un ejemplo sencillo: en lugar de preocuparte por cuántos kilómetros caminaste por la mañana, ¿puedes ser consciente de los pájaros cantando, sentir el aire fresco y notar cómo cambia el día? Al conectar tus sentidos con la naturaleza, los animales, las personas y tu propio cuerpo, atraes la atención de tu sistema nervioso, lo que a su vez calma tu ansiedad. Cuando regreses a casa, estarás en un mejor estado de ánimo y más preparado para enfrentar tu día."
            text2.text = ""
            imgView.contentMode = .scaleAspectFit
            imgView.image = imagesArray[4]
            stepsImgView.image = UIImage(named: "step5")
        }
        else if(counter == 5){
            imgStack.isHidden = false
            stackHeight.constant = 41
            rightBtn.isHidden = true
            completeButton.isHidden = false
            text1.text = languageId == 1 ? textArray[5] : "¿Qué ejercicios de atención plena te gustaría incluir en tu rutina diaria? Calmscient puede recordarte algunas rutinas sencillas de atención plena que te ayudarán a mantenerte saludable."
            text2.text = ""
            imgView.image = imagesArray[5]
            stepsImgView.image = UIImage(named: "step6")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Mindfulness - what is it?" : "Mindfulness: ¿qué es?"
        imgStack.isHidden  =   (counter == 5) ?  false :  true
        stackHeight.constant = (counter == 5) ? 41 : 0
        setupLanguage()
    }
    override func viewDidLoad() {
        //back button tapped
        
       
        let arrowBack = UITapGestureRecognizer(target: self, action: #selector(bottomBackTapped(tapGestureRecognizer:)))
        
        backActionImg.isUserInteractionEnabled = true
        backActionImg.addGestureRecognizer(arrowBack)

        
        //front button tapped
        let arrowFront = UITapGestureRecognizer(target: self, action: #selector(bottomFrontTapped(tapGestureRecognizer:)))
        
        frontActionImg.isUserInteractionEnabled = true
        frontActionImg.addGestureRecognizer(arrowFront)
        setupData()
        
        text1.font = UIFont(name: Fonts().lexendLight, size: 15)
        text2.font = UIFont(name: Fonts().lexendLight, size: 15)
        
        if let data = UserDefaults.standard.value(forKey: "favoriteExcersises") as? Data {
            favExcercises = try! PropertyListDecoder().decode([ExcercisesModel].self, from: data)
            if let abc  = favExcercises.filter({$0.screenCode == ExcercisesTypeEnum.mindfulness.rawValue}).first {
                isFav = abc.isFav
            }
        }
        setFavImage()
        let favImgTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(favImgTapped(sender:)))
        favImg.addGestureRecognizer(favImgTapGestureRecognizer)
        
        completeButton.isHidden = true
        
        completeButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14)
        
        //nav bar back button start
        let backButtonImage = UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal)

        // Create a UIButton
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonOverrideAction), for: .touchUpInside)

        // Set constraints to adjust the size
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true // Set desired width
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true // Set desired height

        // Create a UIBarButtonItem using the UIButton
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
        
        //end
    }
    
    @objc func backButtonOverrideAction() {
            self.navigationController?.popViewController(animated: true)
    
        }
    
    func setFavImage() {
        self.favImg.image = UIImage(named: self.isFav == 1 ? "redFav" : "fav")
    }

    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        self.navigationController?.popViewController(animated: true)
        // Your action
    }
    
    @objc func favImgTapped(sender: UITapGestureRecognizer) {
        isFav = (isFav == 0) ? 1 : 0
        self.view.showToastActivity()
        ExcercisesRepository.shared.addFavAPICall(isFav: isFav, pageId: 6, title: ExcercisesTypeEnum.mindfulness.addFavCode) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        debugPrint("response -> \(json)")
                        DispatchQueue.main.async {
                            self.setFavImage()
                            self.view.hideToastActivity()
                            if let msg = json["responseMessage"] {
                                self.view.showToast(message: msg as! String)
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.view.hideToastActivity()
                        }
                    }
                } catch {
                    print("Error converting data to JSON: \(error)")
                    DispatchQueue.main.async {
                        self.view.hideToastActivity()
                    }
                }
            case .failure(let error):
                print("Error: \(error)")
                DispatchQueue.main.async {
                    self.view.hideToastActivity()
                }
            }
        }

    }
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
