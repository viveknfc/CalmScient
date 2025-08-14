//
//  DrinkEachTimeCell.swift
//  CalmscientIOS
//
//  Created by mac on 06/06/24.
//

import Foundation
import UIKit

class DrinkEachTimeCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "CustomCollectioncell", bundle: nil), forCellWithReuseIdentifier: "CustomCollectioncell")
    }

}
extension DrinkEachTimeCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2 // Adjust this to your data count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectioncell", for: indexPath) as! CustomCollectioncell
        // Configure the cell
        cell.configure(withText: "Item \(indexPath.item)")
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 10) / 2
//        let height = (collectionView.frame.height - 10) / 2
        return CGSize(width: width, height: 200)
    }

}
