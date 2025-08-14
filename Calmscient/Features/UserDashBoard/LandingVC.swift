//
//  LandingVC.swift
//  MentalHealth
//
//  Created by KA on 21/02/24.
//

import UIKit

class LandingVC: UIViewController {
    
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var needToTalkButton: CapsuleButton!
    @IBOutlet weak var listTable: UITableView!
    @IBOutlet weak var happyToSeeYouLbl: UILabel!
    
    @IBOutlet weak var favouritesCollectionView: UICollectionView!
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var listData = Array<ListData>()

    override func viewDidLoad() {
        super.viewDidLoad()

        let attributsBold = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 34, weight: .bold)]
        let attributsNormal = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 34, weight: .regular)]
        let attributedString = NSMutableAttributedString(string: "Hello ", attributes:attributsNormal)
        let boldStringPart = NSMutableAttributedString(string: "John", attributes:attributsBold)
        attributedString.append(boldStringPart)
      
        helloLabel.attributedText = attributedString
        
        setupCollectioView()
        mockDataSetup()
    }
    override func viewWillAppear(_ animated: Bool) {
        setupLanguage()
    }
    func setupLanguage() {
        
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            
            if languageId == 1 {
                UserDefaults.standard.set("en", forKey: "Language")
            } else if languageId == 2 {
                UserDefaults.standard.set("es", forKey: "Language")
            }
        needToTalkButton.titleLabel!.text = AppHelper.getLocalizeString(str: "Need to talk with someone?")
        happyToSeeYouLbl.text = AppHelper.getLocalizeString(str: "We are happy to see you")
        //helloLabel have attributed string
        
        }
    private func setupCollectioView() {
//        let nib = UINib(nibName: "FavouriteCell", bundle: nil)
//        favouritesCollectionView.register(nib, forCellWithReuseIdentifier: "FavouriteCell")
        
        let edgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
        flowLayout.sectionInset = edgeInsets
        flowLayout.itemSize = CGSize(width:  160.0, height:  100.0)
        
        //collectionViewHeightConstraint.constant = 100 + flowLayout.sectionInset.top + flowLayout.sectionInset.bottom
    }
    
    @IBAction func needToTalkButtonAction(_ sender: GradientButton) {
        
    }
    
    func mockDataSetup(){
        let obj1 = ListData(iconImageName: "medicalRecord", descriptionData: "My medical records")
        let obj2 = ListData(iconImageName: "medicalRecord", descriptionData: "Weekly Summary")
        listData.append(obj1)
        listData.append(obj2)
    }

}

struct ListData{
    var iconImageName: String
    var descriptionData: String
}

extension LandingVC: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HomeTableCell = self.listTable.dequeueReusableCell(withIdentifier: "HomeTableCell") as! HomeTableCell
       // cell.iconView.layer.cornerRadius = cell.iconImage.frame.height/2
        //cell.iconView = UIImage(named: listData[indexPath.row].iconImageName)
        cell.nameLabel.text = listData[indexPath.row].descriptionData
        return cell
    }
    
}

extension LandingVC: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10//data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavouriteCell", for: indexPath) as! FavouriteCell
//        let example = data[indexPath.item]
//        let viewModel = ExampleViewModel(example: example)
//
//        cell.configure(with: viewModel)
        return cell
    }
   
    
    
}


class HomeTableCell: UITableViewCell{
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconView: UIView!
    
}


final class FavouriteCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    private static let sizingCell = UINib(nibName: "FavouriteCell", bundle: nil).instantiate(withOwner: nil, options: nil).first! as! FavouriteCell
    
//    public func configure(with viewModel: ExampleViewModel, isSizing: Bool = false) {
//        body.text = viewModel.body
//
//        guard !isSizing else {
//            return
//        }
//
//        title.text = viewModel.title
//
//        layer.cornerRadius = 2.0
//    }

    public static func height(forWidth width: CGFloat) -> CGFloat {
        sizingCell.prepareForReuse()
        //sizingCell.configure(with: viewModel, isSizing: true)
        sizingCell.layoutIfNeeded()
        var fittingSize = UIView.layoutFittingCompressedSize
        fittingSize.width = width
        let size = sizingCell.contentView.systemLayoutSizeFitting(fittingSize,
                                                                  withHorizontalFittingPriority: .required,
                                                                  verticalFittingPriority: .defaultLow)

//        guard size.height < Constants.maximumCardHeight else {
//            return Constants.maximumCardHeight
//        }

        return size.height
    }
    
}


