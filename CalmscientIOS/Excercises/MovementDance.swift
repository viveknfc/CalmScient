//
//  MovementDance.swift
//  sample
//
//  Created by Krishna on 8/6/24.
//

import Foundation
import UIKit


class MovementDance: ViewController {

    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var favImg: UIImageView!
    
    @IBOutlet weak var completeButton: UIButton!
    
    
    var isFav: Int = 0
    var favExcercises:[ExcercisesModel] = []
    var languageId : Int = 1
    
    override func viewDidLoad() {
        
        self.descriptionLbl.font = UIFont(name: Fonts().lexendLight, size: 15)
        completeButton.titleLabel?.font = UIFont(name: Fonts().lexendLight, size: 14)


        if let data = UserDefaults.standard.value(forKey: "favoriteExcersises") as? Data {
            favExcercises = try! PropertyListDecoder().decode([ExcercisesModel].self, from: data)
            if let abc  = favExcercises.filter({$0.screenCode == ExcercisesTypeEnum.movementDance.rawValue}).first {
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
    
    
    func setupLanguage() {
        
             languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        
        descriptionLbl.text = AppHelper.getLocalizeString(str: "Moving your body to music can be a fun and fast way to shift your state and reconnect with your body, rhythm and expression.")
        
        }
    
    override func viewWillAppear(_ animated: Bool) {
        title = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Movement: dance" : "Movimiento: Danza"
        setupLanguage()
    }

    func setFavImage() {
        self.favImg.image = UIImage(named: self.isFav == 1 ? "redFav" : "fav")
    }

    @objc func favImgTapped(sender: UITapGestureRecognizer) {
        isFav = (isFav == 0) ? 1 : 0
        self.view.showToastActivity()
        ExcercisesRepository.shared.addFavAPICall(isFav: isFav, pageId: 1, title: ExcercisesTypeEnum.movementDance.addFavCode) { [self] result in
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
    
    
    @IBAction func completeButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
