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
    
    /// Localization keys matching `exercises` titles (English key → translated per bundle).
    private let exerciseLocalizedTitleKeys: [String] = [
        "Mindfulness - what is it?",
        "Progressive muscle relaxation",
        "Touch and the butterfly hug",
        "Hand over your heart",
        "Mindful walking",
        "Movement: dance",
        "Movement: running",
        "Mindful body movement",
        "Breathing technique"
    ]
    
    var titleStr : String = ""
    
    override func viewDidLoad() {
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = nil
        
        if let image = UIImage(named: "Citation")?.withRenderingMode(.alwaysOriginal) {
            let button = UIButton(type: .custom)
            button.setImage(image, for: .normal)
            button.imageView?.contentMode = .scaleAspectFill
            button.contentHorizontalAlignment = .fill
            button.contentVerticalAlignment = .fill
            button.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
            button.addTarget(self, action: #selector(rightBarButtonTapped), for: .touchUpInside)

            let rightBarButton = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = rightBarButton
        } else {
            print("❌ Failed to load image named 'Citation'")
        }

        
        if let layout = excercisesCollection.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            let spacing: CGFloat = 10
            let itemWidth = (view.frame.size.width - 30) / 2
                                layout.itemSize = CGSize(width: itemWidth, height: 125)
            layout.minimumInteritemSpacing = spacing
                                layout.minimumLineSpacing = spacing
                            }

        self.excercisesCollection.clipsToBounds = false

    }
    
    @objc func rightBarButtonTapped() {
        // Action when right bar button is tapped
        print("Right bar button tapped")
        
        if #available(iOS 16.0, *) {
            CitationWebNavigation.pushSourcesAndCitations(from: navigationController)
        } else {
            let next = UIStoryboard(name: "WebView_Ciitation", bundle: nil)
            let vc = next.instantiateViewController(withIdentifier: "CitationWebViewController") as? CitationWebViewController
            vc?.favURL = CitationWebPresentation.defaultSourcesURL
            if let vc {
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func setupLanguage() {
        
titleStr = "Exercises".localized
        
        
        }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        self.navigationItem.leftBarButtonItem = nil
        setupLanguage()
//        self.title = titleStr;
        
        let titleLabel = UILabel()
        titleLabel.text = titleStr
        titleLabel.font = UIFont(name: Fonts().lexendMedium, size: 18)
        titleLabel.textColor = .label // or any color you want
        navigationItem.titleView = titleLabel
        
        excercisesCollection.reloadData()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
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
            BreathingTechniqueNavigation.push(from: self)
        }
        //
        
            
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExerciseCell", for: indexPath) as! ExerciseCell
        cell.layoutSubviews()
        let exerciseAsset = exercises[indexPath.row]
        cell.label.text = exerciseLocalizedTitleKeys[indexPath.row].localized
        cell.label.font = UIFont(name: Fonts().lexendRegular, size: 14)
        cell.imageView.image = UIImage(named: exerciseAsset.1)
        return cell
    }
}

