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

    var isFav: Int = 0
    var favExcercises:[ExcercisesModel] = []

    
    private enum L10n {
        static let introHighlight = "mindfulness_intro_highlight".localized
        static let introBody = "mindfulness_intro_body".localized
        static let autoPilotText = "mindfulness_auto_pilot_text".localized
        static let autoPilotHighlight = "mindfulness_auto_pilot_highlight".localized
        static let oppositeText = "mindfulness_opposite_text".localized
        static let oppositeHighlightPrimary = "mindfulness_opposite_highlight_primary".localized
        static let oppositeHighlightSecondary = "mindfulness_opposite_highlight_secondary".localized
        static let anxietyTitle = "mindfulness_anxiety_title".localized
        static let anxietyBody = "mindfulness_anxiety_body".localized
        static let reminderBody = "mindfulness_reminder_body".localized
        static let exampleBody = "mindfulness_example_body".localized
        static let dailyRoutineBody = "mindfulness_daily_routine_body".localized
    }
    
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
            
//        self.titleLabel.text = "Mindfulness - what is it?".localized
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
                        (text: L10n.introHighlight, attributes: highlightAttr),
                        (text: L10n.introBody, attributes: attrs2)
                    ]

                    // Create the combined attributed string
                    let combinedAttributedString = createAttributedString(segments: segments)
                    
            text1.attributedText = combinedAttributedString//textArray[0]
            
            let fulltxt2 = L10n.autoPilotText
            
                    // Create a mutable attributed string
                    let attributedString = NSMutableAttributedString(string: fulltxt2, attributes: attrs2)
                    
                    // Define the range of the highlighted text
            let highlightedTextRange = (fulltxt2 as NSString).range(of: L10n.autoPilotHighlight)
                    
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
            
            let fullString = L10n.oppositeText

            // Create an NSMutableAttributedString with the entire string
            let attributedString = NSMutableAttributedString(string: fullString)

            

            // Apply the default attributes to the entire string
            attributedString.addAttributes(attrs2, range: NSRange(location: 0, length: fullString.count))

            // Define the ranges of the words you want to highlight
            let mindfulnessRange = (fullString as NSString).range(of: L10n.oppositeHighlightPrimary)
            let beingRange = (fullString as NSString).range(of: L10n.oppositeHighlightSecondary)

            

            // Apply the highlighted attributes to the specific ranges
            attributedString.addAttributes(highlightAttr, range: mindfulnessRange)
            attributedString.addAttributes(highlightAttr, range: beingRange)

            text1.attributedText = attributedString
            text2.text = ""
        }
        else if(counter == 2){
            text1.text = L10n.anxietyTitle
            text1.font = UIFont(name: Fonts().lexendRegular, size: 15)!
            imgView.image = imagesArray[2]
            completeButton.isHidden = true
            stepsImgView.image = UIImage(named: "step3")
            imgView.contentMode = .scaleAspectFit
            text2.text = L10n.anxietyBody
        }
        else if(counter == 3){
            text1.text = L10n.reminderBody
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
            text1.text = L10n.exampleBody
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
            text1.text = L10n.dailyRoutineBody
            text2.text = ""
            imgView.image = imagesArray[5]
            stepsImgView.image = UIImage(named: "step6")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = "Mindfulness - what is it?".localized
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
