//
//  ProfileLanguageTableViewCell.swift
//  CalmscientIOS
//
//  Created by KA on NA.
//

import UIKit

class ProfileLanguageTableViewCell: UITableViewCell {
//    weak var delegate: LanguageSelectionDelegate?

    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellIconView: UIImageView!
    @IBOutlet weak var languageCollectionView: UICollectionView!
    var languagesArray: [[String: Any]] = [] {
            didSet {
                print("languagesArray updated: \(languagesArray)")
                languageCollectionView.reloadData()
            }
        }
    var languageSelectionClosure: ((Int) -> Void)?
    var selectedIndexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        let nib = UINib(nibName: "ProfileLanguage1CollectionViewCell", bundle: nil)
        languageCollectionView.backgroundColor = UIColor(named: "AppBackGroundColor")
        languageCollectionView.register(nib, forCellWithReuseIdentifier: "ProfileLanguage1CollectionViewCell")
        languageCollectionView.delegate = self
        languageCollectionView.dataSource = self
        if let layout = languageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        languageCollectionView.contentInset = .zero
        languageCollectionView.showsHorizontalScrollIndicator = false
        languageCollectionView.showsVerticalScrollIndicator = false
        languageCollectionView.reloadData()
     //   print("getPatientLanguages===\(self.languagesArray)")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}

extension ProfileLanguageTableViewCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return languagesArray.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileLanguage1CollectionViewCell", for: indexPath) as? ProfileLanguage1CollectionViewCell else {
            return UICollectionViewCell()
        }
        let newData = languagesArray[indexPath.row]
        cell.langaugeLable.text = newData["languageName"] as? String
//        cell.langaugeLable.textColor = (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as! Bool ? UIColor(hex: "#424242") : .white
        if let imageUrlString = newData["flagUrl"] as? String, let url = URL(string: imageUrlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        cell.languageImage.image = UIImage(data: data)
                        
                    }
                }
            }
        }
//        cell.cellBackGroundView.layer.borderWidth = 1
//        cell.cellBackGroundView.layer.borderColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1).cgColor
        cell.cellBackGroundView.layer.cornerRadius = 10
        
        if let preferred = newData["preferred"] as? Int, preferred == 1 {
            cell.cellBackGroundView.backgroundColor = UIColor(named: "AppBorderColor")
            cell.langaugeLable.textColor = (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as! Bool ?  .black : .white
               } else {
                   cell.cellBackGroundView.backgroundColor = UIColor(named: "profileCellSeperaionColor")
                   cell.langaugeLable.textColor = (UserDefaults.standard.value(forKey: "isDarkMode") ?? false) as! Bool ? .white : .black
               }
//        if selectedIndexPath == indexPath {
//            cell.cellBackGroundView.backgroundColor = UIColor.green // Change to desired color
//               } else {
//                   cell.cellBackGroundView.backgroundColor = UIColor.white // Default color
//               }
       return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        // Return the size of each item in your collection view
//        let height = collectionView.frame.height - 4
//        return CGSize(width: height, height: height)
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

//                let newData = languagesArray[indexPath.row]
//                let languageId = newData["languageId"] as! Int
//                if let languageId = newData["languageId"] as? Int {
//                    languageSelectionClosure?(languageId)
//                    tabTitles = languageId == 1 ? tabTitlesEnglish : tabTitlesSpanish
//                }
//                collectionView.reloadData()
//        languageCollectionView.reloadData()
        
        let newData = languagesArray[indexPath.row]
               
               if let languageId = newData["languageId"] as? Int {
                   // Notify the delegate of the language selection
                   languageSelectionClosure?(languageId)
                   // Post notification
                           NotificationCenter.default.post(name: .languageChanged, object: nil)
//                   delegate?.didSelectLanguage(languageId: languageId)
                   collectionView.reloadData()
               }
           }
        
    }


