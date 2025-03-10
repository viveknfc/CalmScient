//
//  UserIntroSelectionTableCell.swift
//  HealthApp
//
//  Created by KA on 26/02/24.
//

import UIKit

class UserIntroSelectionTableCell: UITableViewCell {
    
    @IBOutlet weak var borderContainerView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableCellCollectionView: UICollectionView!
    
    private var cellType:UserEntryDayFeedbackTableCell! {
        didSet {
             var languageId: Int?
             languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
             self.titleLabel.font = UIFont(name: Fonts().lexendMedium, size: 16)
             
             var labelText: String
             if cellType == .UserMoodHoursCell {
                 labelText = instance.moodData?.moodQuestion ?? ""
             } else {
                 labelText = (languageId == 0 ? 1 : languageId) == 1 ? instance.timeSpendData?.timeSpendQuestion ?? "" : "¿Con quién pasaste tiempo?"
             }
             
             // Create an attributed string with red asterisk
             let attributedText = NSMutableAttributedString(string: labelText)
             let redAsterisk = NSAttributedString(
                 string: " *",
                 attributes: [.foregroundColor: UIColor.red]
             )
             attributedText.append(redAsterisk)
             
             self.titleLabel.attributedText = attributedText
         }
    }
    private var instance:UserStartupScreenDayData!
    var selectedIndex = -1 {
        didSet {
            tableCellCollectionView.reloadData()
        }
    }
    
    var spendIndex = -1 {
        didSet {
            tableCellCollectionView.reloadData()
        }
    }
    
    var moodIdAnswer: Int?
    var spendHoursAnswer: String?
    
    func getUpdatedData4MoodId() -> (Int?) {
        return instance.moodAnswer
    }
    
    func getUpdatedData4SpendHours() -> (String?) {
        print("spend hours inside updated data is", spendHoursAnswer ?? -4)
        return (spendHoursAnswer)
    }

    
    let dummyData:[String:[(String,String)]] = (UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 0 ? 1 : UserDefaults.standard.integer(forKey: "SelectedLanguageID")) == 1 ? ["UserMoodHoursCell":[
        ("UserIntro_Bad","BAD"),
        ("UserIntro_Couldbe","COULD BE BETTER"),
        ("UserIntro_Fair","FAIR"),
        ("UserIntro_Good","GOOD"),
        ("UserIntro_Excellent","EXCELLENT")
    ],"UserEntryTimeSpendCell":[
        ("UserIntro_Family","FAMILY"),
        ("UserIntro_Friends","FRIENDS"),
        ("UserIntro_Workmates","WORKMATES"),
        ("UserIntro_Others","OTHERS"),
        ("UserIntro_Alone","ALONE")
    ]]
    
    :
    
    ["UserMoodHoursCell":[
        ("UserIntro_Bad","Mal"),
        ("UserIntro_Couldbe","Podría ser mejor"),
        ("UserIntro_Fair","Más o menos"),
        ("UserIntro_Good","Bueno"),
        ("UserIntro_Excellent","Excelente")
    ],"UserEntryTimeSpendCell":[
        ("UserIntro_Family","Familia"),
        ("UserIntro_Friends","Amigos"),
        ("UserIntro_Workmates","Compaňeros de trabajo"),
        ("UserIntro_Others","Otras personas"),
        ("UserIntro_Alone","Solo")
    ]]
    
    let selectedSmileyImgs = ["bad_selected","could_better_selected","fair_selected","good_selected","excellent_selected"]
    
    let selectedFamilyImages = ["family_selected","friends_selected","workmates_selected","others","alone_selected"]
    
    var collectionData:[(String,String)]!
    fileprivate func addShadowAndBorder() {
        shadowView.layer.backgroundColor = UIColor.clear.cgColor
        shadowView.layer.shadowColor = UIColor(named: "AppViewShadowColor")?.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2.0
//        shadowView.applyShadow(radius: 8)
        
        borderContainerView.layer.cornerRadius = 8
        borderContainerView.layer.masksToBounds = true
        borderContainerView.layer.borderWidth = 1
        borderContainerView.layer.borderColor = UIColor(named: "AppViewBorderColor")?.cgColor
        borderContainerView.applyShadow(cornerRadius: 8)
    }
    
    func updateUIWithCellInstance(instance:UserStartupScreenDayData, cellType:UserEntryDayFeedbackTableCell) {
        self.instance = instance
        self.cellType = cellType
        self.collectionData = dummyData[cellType.rawValue]!

        self.tableCellCollectionView.delegate = self
        self.tableCellCollectionView.dataSource = self
        self.tableCellCollectionView.reloadData()
        
    }

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowAndBorder()
        let nib = UINib(nibName: "UserIntroDayCollectionCell", bundle: nil)
        tableCellCollectionView.register(nib, forCellWithReuseIdentifier: "UserIntroDayCollectionCell")
        if let layout = tableCellCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        tableCellCollectionView.showsHorizontalScrollIndicator = false
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension UserIntroSelectionTableCell : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.collectionData.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserIntroDayCollectionCell", for: indexPath) as? UserIntroDayCollectionCell else {
            return UICollectionViewCell()
        }
        
        let cellData = collectionData[indexPath.row]
        
        switch self.cellType {
        case .UserMoodHoursCell:
            // Use selectedIndex for UserMoodHoursCell
            configureCell(cell, indexPath: indexPath, isSelected: indexPath.row == selectedIndex, cellData: cellData)
            
        case .UserEntryTimeSpendCell:
            // Use spendIndex for UserEntryTimeSpendCell
            configureCell(cell, indexPath: indexPath, isSelected: indexPath.row == spendIndex, cellData: cellData)
        case .none:
            break
        case .some(.UserIntroSleepCell):
            break
        case .some(.UserEntryMedicineCell):
            break
        case .some(.UserEntryJournalCell):
            break
        }
        
        return cell
    }
    
    //viv start
    
    private func configureCell(_ cell: UserIntroDayCollectionCell, indexPath: IndexPath, isSelected: Bool, cellData: (String, String)) {
        
        let defaultSize = cell.defaultImageSize
        let newSize = defaultSize * 1.1
        
        if isSelected {
            // Configure the selected cell appearance
            cell.cellTitleLabel.textColor = self.cellType == .UserEntryTimeSpendCell ? UIColor(named: "barColor1") :
                [
                    UIColor(hex: "#EF6D6D"),
                    UIColor(hex: "#F28A91"),
                    UIColor(hex: "#F8BEBD"),
                    UIColor(hex: "#A19EBD"),
                    UIColor(hex: "#6E6BB3"),
                ][indexPath.row]
            
            //viv start
            switch cellType {
            case .UserMoodHoursCell:
                print("the selected index value for UserMoodHoursCell is", selectedIndex,"and index path is",indexPath.row)
                instance.moodAnswer = indexPath.row + 1
                
            case .UserEntryTimeSpendCell:

                spendHoursAnswer = String(indexPath.row + 1)
                
            default:
                break
            }
  
            //end
            cell.cellImageView.image = self.cellType == .UserEntryTimeSpendCell ? UIImage(named: self.selectedFamilyImages[indexPath.row]) : UIImage(named: "\(cellData.0)")
            cell.cellImageView.applyShadow()

            cell.cellWidth.constant = newSize
            cell.cellHeight.constant = newSize
            cell.cellImageView.layer.cornerRadius = newSize / 2
            
//            cell.cellImageView.layer.cornerRadius = cell.cellImageView.frame.height / 2
            cell.cellImageView.clipsToBounds = false
            cell.cellImageView.layer.borderWidth = 2
            cell.cellImageView.layer.borderColor = UIColor.white.cgColor
            cell.cellImageView.layer.shadowColor = UIColor.black.cgColor
            cell.cellImageView.layer.shadowOpacity = 0.5
            cell.cellImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.cellImageView.layer.shadowRadius = 4
            cell.cellImageView.layer.shadowPath = UIBezierPath(ovalIn: cell.cellImageView.bounds).cgPath

        } else {
            // Configure the unselected cell appearance

            cell.cellWidth.constant = defaultSize
            cell.cellHeight.constant = defaultSize
            cell.cellImageView.layer.cornerRadius = defaultSize / 2
            
            cell.cellTitleLabel.textColor = UIColor(named: "UserIntroCollectionCellBackgroundColor")
            cell.cellImageView.image = UIImage(named: "\(cellData.0)")
            cell.cellImageView.layer.borderWidth = 1
            cell.cellImageView.layer.borderColor = UIColor.clear.cgColor
            cell.cellImageView.layer.masksToBounds = true
            
        }
        
        cell.cellTitleLabel.text = cellData.1
    }
    
    
    //end
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            // Return the size of each item in your collection view
        let width = (collectionView.frame.width - (4*5) - 10) / 5
        let height = collectionView.frame.height - 10
        return CGSize(width: width, height: height)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 5
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }
    
    
    
}

extension UserIntroSelectionTableCell : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        switch cellType {
        case .UserMoodHoursCell:
            selectedIndex = indexPath.row
            print("Selected Index after update: \(selectedIndex)")
            self.instance.moodAnswer = self.instance.moodData?.options[selectedIndex].optionTypeID
            print("Selected moodAnswer after update: \(String(describing: self.instance.moodAnswer))")

        case .UserEntryTimeSpendCell:
            spendIndex = indexPath.row
            self.instance.timeSpendAnswer = String(spendIndex+1) //cellSelectedItem.1
            print("Selected Index after update: \(spendIndex)")
        default:
            break
        }
        collectionView.reloadData()
        
        
    }
}
