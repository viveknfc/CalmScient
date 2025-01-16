//
//  Excercises.swift
//  sample
//
//  Created by Krishna on 8/5/24.
//

import Foundation
import UIKit


class Excercises: ViewController {
    
    
    @IBOutlet weak var excercisesCollection: UICollectionView!
    @IBOutlet var topView: UIView!
    
    
    let exercises = [
            ("Mindfulness - what is it?", "mindfulness"),
            ("Progressive muscle relaxation", "progressiveWithHeadset"),
            ("Touch and the butterfly hug", "touchAndButterfly"),
            ("Hand over your heart", "handover"),
            ("Mindful walking", "mindfulWalking_index"),
            ("Movement: dance", "movement"),
            ("Movement: running", "movementRunning"),
            ("Mindful body movement", "MindFulBodyMovement"),
            ("Breathing technique", "breathingTechnique")
        ]
    
    let exercisesSpanish = [
         "Mindfulness - ¿qué es?",
         "Relajación muscular progresiva",
         "Toque y el abrazo de mariposa",
        "Mano sobre tu corazón",
         "Caminata consciente",
        "Movimiento: baile",
        "Movimiento: correr",
        "Movimiento corporal consciente",
        "Técnica de respiración"

        ]
    
    var titleStr : String = ""
    
    override func viewDidLoad() {
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.leftBarButtonItem = nil
        setupLanguage()
        if let layout = excercisesCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            let spacing: CGFloat = 10
            let itemWidth = (view.frame.size.width - 30) / 2
                                layout.itemSize = CGSize(width: itemWidth, height: 125)
            layout.minimumInteritemSpacing = spacing
                                layout.minimumLineSpacing = spacing
                            }
        
        self.title = titleStr;

        self.excercisesCollection.clipsToBounds = false
        
    }
    
    
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }

        titleStr = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Exercises" : "Ejercicios"
        
        
        }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false

        self.navigationItem.leftBarButtonItem = nil
        setupLanguage()
        self.title = titleStr;
        excercisesCollection.reloadData()
        
    }

}

extension Excercises: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return exercises.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if(indexPath.item == 0){
            let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "MindfulNess") as! MindfulNess
                    
                    // Push to the destination view controller
                    self.navigationController?.pushViewController(destinationVC, animated: true)
        }
        else if(indexPath.item == 1){
            
            let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "Progressive") as! Progressive
                    
                    // Push to the destination view controller
                    self.navigationController?.pushViewController(destinationVC, animated: true)
        }
        else if(indexPath.item == 2){
            //HandOverYourHeart
            let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "TouchAndButterFly2") as! TouchAndButterFly2
                    
                    // Push to the destination view controller
                    self.navigationController?.pushViewController(destinationVC, animated: true)
        }
        else if(indexPath.item == 3){
            //HandOverYourHeart
            let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "HandOverYourHeart") as! HandOverYourHeart
                    
                    // Push to the destination view controller
                    self.navigationController?.pushViewController(destinationVC, animated: true)
        }
        else if(indexPath.item == 4){
            //HandOverYourHeart
            let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "MindfulWalking") as! MindfulWalking
                    
                    // Push to the destination view controller
                    self.navigationController?.pushViewController(destinationVC, animated: true)
        }
        else if(indexPath.item == 5){
            //HandOverYourHeart
            let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "MovementDance") as! MovementDance
                    
                    // Push to the destination view controller
                    self.navigationController?.pushViewController(destinationVC, animated: true)
        }
        else if(indexPath.item == 6){
            //HandOverYourHeart
            let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "MovementRunning") as! MovementRunning
                    
                    // Push to the destination view controller
                    self.navigationController?.pushViewController(destinationVC, animated: true)
        }
        else if(indexPath.item == 7){
            //HandOverYourHeart
            let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "MindfulBodyMovement") as! MindfulBodyMovement
                    
                    // Push to the destination view controller
                    self.navigationController?.pushViewController(destinationVC, animated: true)
        }
        else if(indexPath.item == 8){
            //HandOverYourHeart
            let storyboard = UIStoryboard(name: "Excercises", bundle: nil)
                    let destinationVC = storyboard.instantiateViewController(withIdentifier: "BreathingTechnique") as! BreathingTechnique
                    
                    // Push to the destination view controller
                    self.navigationController?.pushViewController(destinationVC, animated: true)
        }
        //
        
            
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseCell", for: indexPath) as! ExerciseCell
        cell.layoutSubviews()
        let exercise = exercises[indexPath.row]
        cell.label.text =  UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? (exercise.0) : exercisesSpanish[indexPath.row]
        cell.label.font = UIFont(name: Fonts().lexendRegular, size: 14)
        cell.imageView.image = UIImage(named: exercise.1)
        return cell
    }
}

