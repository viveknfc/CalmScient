//
//  TouchAndButterFly2.swift
//  sample
//
//  Created by Krishna on 8/6/24.
//

import Foundation
import UIKit

class TouchAndButterFly2: ViewController {
    
    
    @IBOutlet weak var text1: UILabel!
    
    @IBOutlet weak var backImg: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var nextIcon: UIImageView!
    
    @IBOutlet weak var favImg: UIImageView!
    var isFav: Int = 0
    var favExcercises:[ExcercisesModel] = []
    
    
    override func viewDidLoad() {
        
        descriptionLabel.font = UIFont(name: Fonts().lexendLight, size: 15)
        
        let nextPageRecognizer = UITapGestureRecognizer(target: self, action: #selector(nextTapped(tapGestureRecognizer:)))
        nextIcon.isUserInteractionEnabled = true
        nextIcon.addGestureRecognizer(nextPageRecognizer)
        if let data = UserDefaults.standard.value(forKey: "favoriteExcersises") as? Data {
            favExcercises = try! PropertyListDecoder().decode([ExcercisesModel].self, from: data)
            if let abc  = favExcercises.filter({$0.screenCode == ExcercisesTypeEnum.touchAndButterfly.rawValue}).first {
                isFav = abc.isFav
            }
        }
        setFavImage()

        let favImgTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(favImgTapped(sender:)))
        favImg.addGestureRecognizer(favImgTapGestureRecognizer)
        
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

    
    override func viewWillAppear(_ animated: Bool) {
        title = "Touch and the butterfly hug".localized
        setupLanguage()
    }
    
    
    func setupLanguage() {
        
//        titleLabel.text = languageId == 1 ? "Touch and the butterfly hug" : "Toque y el abrazo de mariposa"
        
        descriptionLabel.text = AppHelper.getLocalizeString(str: "Humans respond powerfully to touch. Gentle, affectionate touch helps calm the nervous system and can trigger the release of oxytocin, the attachment hormone. Interestingly, when it comes to releasing oxytocin, our bodies don’t differentiate between the touch of a loved one or our own touch as we hold ourselves.\nWhen you are feeling upset, ungrounded, agitated or irritable, try giving yourself a hug or a gentle stroke on the cheek and see how it impacts the way you feel.")
        
        }
    
    @objc func nextTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
                let destinationVC = storyboard.instantiateViewController(withIdentifier: "TouchButterflyHug") as! TouchButterflyHug
                
                // Push to the destination view controller
                self.navigationController?.pushViewController(destinationVC, animated: true)
        // Your action
    }
    
    @objc func favImgTapped(sender: UITapGestureRecognizer) {
        isFav = (isFav == 0) ? 1 : 0
        self.view.showToastActivity()
        ExcercisesRepository.shared.addFavAPICall(isFav: isFav, pageId: 1, title: ExcercisesTypeEnum.touchAndButterfly.addFavCode) { [self] result in
            switch result {
            case .success(let data):
                // Convert data to JSON object and print it
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
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
    

}
    
