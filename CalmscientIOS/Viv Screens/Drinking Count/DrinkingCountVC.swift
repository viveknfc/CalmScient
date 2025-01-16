//
//  DrinkingCountVC.swift
//  CalmscientIOS
//
//  Created by NFC User on 16/12/24.
//

import UIKit

class DrinkingCountVC: ViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, DrinkingCountCellDelegate {
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var totalCount: FontLR12!
    @IBOutlet weak var totalCountView: UIView!
    
    var totalCount1: Int = 0 {
            didSet {
                // Update the total count label whenever the total changes
                totalCount.text = "\(totalCount1)"
            }
        }
    
    private var data: [DrinkingCountData] = [
            DrinkingCountData(countImageName: "check", countLabelText: "1", centreImageName: "beerImage", centreLabelText: "Regular beer (12 fl oz) about 5% alcohol"),
            DrinkingCountData(countImageName: "check", countLabelText: "2", centreImageName: "wine", centreLabelText: "Margarita (3 fl oz) about 33% alcohol"),
            DrinkingCountData(countImageName: "check", countLabelText: "3", centreImageName: "flavour", centreLabelText: "Glass of table wine (5 fl oz) about 12% alcohol"),
            DrinkingCountData(countImageName: "check", countLabelText: "1", centreImageName: "beerImage", centreLabelText: "Regular beer (12 fl oz) about 5% alcohol"),
            DrinkingCountData(countImageName: "check", countLabelText: "2", centreImageName: "wine", centreLabelText: "Margarita (3 fl oz) about 33% alcohol"),
            DrinkingCountData(countImageName: "check", countLabelText: "3", centreImageName: "flavour", centreLabelText: "Glass of table wine (5 fl oz) about 12% alcohol"),
            DrinkingCountData(countImageName: "check", countLabelText: "1", centreImageName: "beerImage", centreLabelText: "Regular beer (12 fl oz) about 5% alcohol")
        ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self

        mainCollectionView.register(UINib(nibName: "DrinkingCountCell", bundle: nil), forCellWithReuseIdentifier: "DrinkingCountCell")
        
        totalCountView.layer.cornerRadius = 8 // Adjust this value as needed
        totalCountView.layer.masksToBounds = true

        // Do any additional setup after loading the view.
    }
    
    func didUpdateCountValue(changeType: CountChangeType) {
         switch changeType {
         case .increase:
             totalCount1 += 1
         case .decrease:
             totalCount1 -= 1
         }
     }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "DrinkingCountCell", for: indexPath) as? DrinkingCountCell else {
            fatalError("Unable to dequeue CustomCollectionViewCell")
        }
        
        cell.delegate = self
        
        let item = data[indexPath.item]
        cell.countImage.image = UIImage(named: item.countImageName)
        cell.countLabel.text = item.countLabelText
        cell.centreImage.image = UIImage(named: item.centreImageName)
        cell.centreLabel.text = item.centreLabelText
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 8) / 2 // Two columns with 10px spacing
        return CGSize(width: width, height: 200)
    }
    


}
