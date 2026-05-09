//
//  UserIntroSelectionTableCell.swift
//  HealthApp
//
//  Created by KA on 26/02/24.
//

import UIKit

protocol UserIntroSelectionDelegate: AnyObject {
    func didChangeSelectedIndex()
}

class UserIntroSelectionTableCell: UITableViewCell {
    
    @IBOutlet weak var borderContainerView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableCellCollectionView: UICollectionView!
    
    private var shouldNotifyDelegate = false
    
    let spendOptions = ["FAMILY", "FRIENDS", "WORKMATES", "OTHERS", "ALONE"]
    
    private var cellType:UserEntryDayFeedbackTableCell! {
        didSet {
             self.titleLabel.font = UIFont(name: Fonts().lexendMedium, size: 16)
             
             var labelText: String
             if cellType == .UserMoodHoursCell {
                 if let mood = instance.moodData {
                     let trimmed = mood.moodQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
                     if !trimmed.isEmpty {
                         labelText = mood.moodQuestion
                     } else if UserDefaults.standard.bool(forKey: "Morning") {
                         print("viv u r setting text for UserMoodHoursCell from here")
                         labelText = AppHelper.getLocalizeString(str: "UserIntro_fallback_mood_morning")
                     } else {
                         labelText = AppHelper.getLocalizeString(str: "UserIntro_fallback_mood_today")
                     }
                 } else if UserDefaults.standard.bool(forKey: "Morning") {
                     print("viv u r setting text for UserMoodHoursCell from here")
                     labelText = AppHelper.getLocalizeString(str: "UserIntro_fallback_mood_morning")
                 } else {
                     labelText = AppHelper.getLocalizeString(str: "UserIntro_fallback_mood_today")
                 }

             } else {
                 let fallback = AppHelper.getLocalizeString(str: "UserIntro_fallback_time_spend")
                 if let ts = instance.timeSpendData {
                     let q = ts.timeSpendQuestion.trimmingCharacters(in: .whitespacesAndNewlines)
                     labelText = q.isEmpty ? fallback : ts.timeSpendQuestion
                 } else {
                     labelText = fallback
                 }
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
    
    weak var delegate: UserIntroSelectionDelegate?
    var isFromAPISetup = false
    
    var apiSelectedIndex = -1

    var selectedIndex = -1 {
        willSet {
            // Determine if delegate should be notified
            if newValue != selectedIndex && newValue != apiSelectedIndex {
                shouldNotifyDelegate = true
            } else {
                shouldNotifyDelegate = false
            }
        }
        didSet {
            tableCellCollectionView.reloadData()

            if !isFromAPISetup, shouldNotifyDelegate {
                delegate?.didChangeSelectedIndex()
            }
        }
    }
    
    var moodIdAnswer: Int?
    var spendHoursAnswer1: [String] = [] {
        didSet {
            tableCellCollectionView.reloadData()
        }
    }
    
    func getUpdatedData4MoodId() -> (Int?) {
        return instance.moodAnswer
    }
    
    func getUpdatedData4SpendHours1() -> ([String]?) {
        print("spend hours inside updated data isfor multi selection is", spendHoursAnswer1)
        return (spendHoursAnswer1)
    }

    
    /// Image asset name, Localizable key for title (en / es / ja in `Localizable.strings`).
    private static let moodOptionPairs: [(String, String)] = [
        ("UserIntro_Bad", "UserIntro_Mood_BAD"),
        ("UserIntro_Couldbe", "UserIntro_Mood_COULD_BE_BETTER"),
        ("UserIntro_Fair", "UserIntro_Mood_FAIR"),
        ("UserIntro_Good", "UserIntro_Mood_GOOD"),
        ("UserIntro_Excellent", "UserIntro_Mood_EXCELLENT")
    ]
    private static let timeSpendPairs: [(String, String)] = [
        ("UserIntro_Family", "UserIntro_Time_FAMILY"),
        ("UserIntro_Friends", "UserIntro_Time_FRIENDS"),
        ("UserIntro_Workmates", "UserIntro_Time_WORKMATES"),
        ("UserIntro_Others", "UserIntro_Time_OTHERS"),
        ("UserIntro_Alone", "UserIntro_Time_ALONE")
    ]
    
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
        switch cellType {
        case .UserMoodHoursCell:
            self.collectionData = Self.moodOptionPairs
        case .UserEntryTimeSpendCell:
            self.collectionData = Self.timeSpendPairs
        default:
            self.collectionData = []
        }

        self.tableCellCollectionView.delegate = self
        self.tableCellCollectionView.dataSource = self
        self.tableCellCollectionView.allowsMultipleSelection = true
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
            
            let answer = String(indexPath.row + 1)
//            let answer = spendOptions[indexPath.row]

            
            
            let isSelected = spendHoursAnswer1.contains(answer)

            configureCell(cell, indexPath: indexPath, isSelected: isSelected, cellData: cellData)

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
                break
                
            default:
                break
            }
  
            //end
            cell.cellImageView.image = self.cellType == .UserEntryTimeSpendCell ? UIImage(named: self.selectedFamilyImages[indexPath.row]) : UIImage(named: "\(cellData.0)")
            
            // Animate scaling for visual feedback
            UIView.animate(withDuration: 0.2) {
                cell.cellWidth.constant = newSize
                cell.cellHeight.constant = newSize
                cell.layoutIfNeeded()
            }
            
            // Rounded image with shadow and border
            cell.cellImageView.layer.cornerRadius = newSize / 2
            cell.cellImageView.clipsToBounds = false
            cell.cellImageView.layer.borderWidth = 3
            cell.cellImageView.layer.borderColor = UIColor.darkGray.cgColor
            
            // Apply shadow with glow effect
            cell.cellImageView.layer.shadowColor = UIColor.darkGray.cgColor
            cell.cellImageView.layer.shadowOpacity = 0.8
            cell.cellImageView.layer.shadowOffset = CGSize(width: 0, height: 4)
            cell.cellImageView.layer.shadowRadius = 8
            cell.cellImageView.layer.shadowPath = UIBezierPath(ovalIn: cell.cellImageView.bounds).cgPath
            
            // Optional – add slight scale effect for pop animation
            cell.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            

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
            
            cell.cellImageView.layer.shadowOpacity = 0
            cell.transform = .identity
            
            UIView.animate(withDuration: 0.2) {
                cell.layoutIfNeeded()
            }
            
        }
        
        cell.cellTitleLabel.text = cellData.1.localized
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
            
            let answer = String(indexPath.row + 1)
            
//            let answer = spendOptions[indexPath.row]
            
            if spendHoursAnswer1.contains(answer) {
                
                if let index = spendHoursAnswer1.firstIndex(of: answer) {
                    spendHoursAnswer1.remove(at: index)
                    print("the index removed from time spend is :\(answer)")
                }
            } else {
                print("the index added from time spend is :\(answer)")
                spendHoursAnswer1.append(answer)
            }
            
            self.instance.timeSpendAnswer = spendHoursAnswer1
            
        default:
            break
        }
        collectionView.reloadItems(at: [indexPath])
        
    }
    
}
