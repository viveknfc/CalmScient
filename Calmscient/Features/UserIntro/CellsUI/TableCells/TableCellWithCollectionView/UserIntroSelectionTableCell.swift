//
//  UserIntroSelectionTableCell.swift
//  HealthApp
//

import UIKit

protocol UserIntroSelectionDelegate: AnyObject {
    func didChangeSelectedIndex(forTag tag: Int, selectedIndex: Int)
}

class UserIntroSelectionTableCell: UITableViewCell {
    
    @IBOutlet weak var borderContainerView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableCellCollectionView: UICollectionView!
    
    private var shouldNotifyDelegate = false
    
    let spendOptions = ["FAMILY", "FRIENDS", "WORKMATES", "OTHERS", "ALONE"]
    
    // Use separate properties for different cell types
    private var cellType: UserEntryDayFeedbackTableCell! {
        didSet {
            let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 0
                             ? 1 : UserDefaults.standard.integer(forKey: "SelectedLanguageID")
            self.titleLabel.font = UIFont(name: Fonts().lexendMedium, size: 16)

            var labelText: String
            switch cellType {
            case .UserMoodHoursCell:
                labelText = languageId == 1
                    ? (instance.moodData?.moodQuestion ?? "How's your mood so far?")
                    : "¿Cómo está tu estado de ánimo?"

            case .UserFocusHoursCell:
                labelText = languageId == 1
                    ? "How is your focus / mental clarity?"
                    : "¿Cómo está tu concentración / claridad mental?"

            default: // UserEntryTimeSpendCell
                labelText = languageId == 1
                    ? (instance.timeSpendData?.timeSpendQuestion ?? "")
                    : "¿Con quién pasaste tiempo?"
            }

            let attributedText = NSMutableAttributedString(string: labelText)
            let redAsterisk = NSAttributedString(string: " *", attributes: [.foregroundColor: UIColor.red])
            attributedText.append(redAsterisk)
            self.titleLabel.attributedText = attributedText
        }
    }
    private var instance:UserStartupScreenDayData!
    
    weak var delegate: UserIntroSelectionDelegate?
    var isFromAPISetup = false
    
    var apiSelectedIndex = -1

    // ✅ Separate selected index for Mood
    var selectedMoodIndex = -1 {
        willSet {
            if newValue != selectedMoodIndex && newValue != apiSelectedIndex {
                shouldNotifyDelegate = true
            } else {
                shouldNotifyDelegate = false
            }
        }
        didSet {
            tableCellCollectionView.reloadData()
            // ✅ REMOVE the delegate call from here — handled in didSelectItemAt directly
        }
    }

    var selectedFocusIndex = -1 {
        willSet {
            if newValue != selectedFocusIndex && newValue != apiSelectedIndex {
                shouldNotifyDelegate = true
            } else {
                shouldNotifyDelegate = false
            }
        }
        didSet {
            tableCellCollectionView.reloadData()
            // ✅ REMOVE the delegate call from here — handled in didSelectItemAt directly
        }
    }
    
    // Keep for backward compatibility - now routes to appropriate property
    var selectedIndex = -1 {
        didSet {
            if cellType == .UserMoodHoursCell {
                selectedMoodIndex = selectedIndex
            } else if cellType == .UserFocusHoursCell {
                selectedFocusIndex = selectedIndex
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
    
    func getUpdatedData4FocusId() -> (Int?) {
        return instance.focusAnswer
    }
    
    func getUpdatedData4SpendHours1() -> ([String]?) {
        print("spend hours inside updated data is for multi selection is", spendHoursAnswer1)
        return (spendHoursAnswer1)
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
    ]] : ["UserMoodHoursCell":[
        ("UserIntro_Bad","Mal"),
        ("UserIntro_Couldbe","Podría ser mejor"),
        ("UserIntro_Fair","Más o menos"),
        ("UserIntro_Good","Bueno"),
        ("UserIntro_Excellent","Excelente")
    ],"UserEntryTimeSpendCell":[
        ("UserIntro_Family","Familia"),
        ("UserIntro_Friends","Amigos"),
        ("UserIntro_Workmates","Compañeros de trabajo"),
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
        
        borderContainerView.layer.cornerRadius = 8
        borderContainerView.layer.masksToBounds = true
        borderContainerView.layer.borderWidth = 1
        borderContainerView.layer.borderColor = UIColor(named: "AppViewBorderColor")?.cgColor
        borderContainerView.applyShadow(cornerRadius: 8)
    }
    
    func updateUIWithCellInstance(instance: UserStartupScreenDayData, cellType: UserEntryDayFeedbackTableCell) {
        self.instance = instance
        self.cellType = cellType
        
        let dataKey = cellType == .UserFocusHoursCell ? UserEntryDayFeedbackTableCell.UserMoodHoursCell.rawValue : cellType.rawValue
        self.collectionData = dummyData[dataKey] ?? []
        
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
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//
//        selectedMoodIndex = -1
//        selectedFocusIndex = -1
//        shouldNotifyDelegate = false
//    }
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
            let isSelected = indexPath.row == selectedMoodIndex
            configureCell(cell, indexPath: indexPath, isSelected: isSelected, cellData: cellData)
            
        case .UserFocusHoursCell:
            let isSelected = indexPath.row == selectedFocusIndex
            configureCell(cell, indexPath: indexPath, isSelected: isSelected, cellData: cellData)

        case .UserEntryTimeSpendCell:
            let answer = String(indexPath.row + 1)
            let isSelected = spendHoursAnswer1.contains(answer)
            configureCell(cell, indexPath: indexPath, isSelected: isSelected, cellData: cellData)

        default:
            break
        }
        
        return cell
    }
    
    private func configureCell(_ cell: UserIntroDayCollectionCell, indexPath: IndexPath, isSelected: Bool, cellData: (String, String)) {
        
        let defaultSize = cell.defaultImageSize
        let newSize = defaultSize * 1.1
        
        if isSelected {
            cell.cellTitleLabel.textColor = self.cellType == .UserEntryTimeSpendCell ? UIColor(named: "barColor1") :
                [
                    UIColor(hex: "#EF6D6D"),
                    UIColor(hex: "#F28A91"),
                    UIColor(hex: "#F8BEBD"),
                    UIColor(hex: "#A19EBD"),
                    UIColor(hex: "#6E6BB3"),
                ][indexPath.row]
            
            // ✅ Store answer based on cell type
//            switch cellType {
//            case .UserMoodHoursCell:
//                instance.moodAnswer = indexPath.row + 1
//                print("Setting moodAnswer to: \(indexPath.row + 1)")
//                
//            case .UserFocusHoursCell:
//                instance.focusAnswer = indexPath.row + 2
//                print("Setting focusAnswer to: \(indexPath.row + 2)")
//            case .UserEntryTimeSpendCell:
//                break
//                
//            default:
//                break
//            }
            switch cellType {
            case .UserMoodHoursCell:
                instance.moodAnswer = indexPath.row + 1
            case .UserFocusHoursCell:
                instance.focusAnswer = indexPath.row + 1  // also +1, NOT +2
            default:
                break
            }
  
            cell.cellImageView.image = self.cellType == .UserEntryTimeSpendCell ? UIImage(named: self.selectedFamilyImages[indexPath.row]) : UIImage(named: "\(cellData.0)")
            
            UIView.animate(withDuration: 0.2) {
                cell.cellWidth.constant = newSize
                cell.cellHeight.constant = newSize
                cell.layoutIfNeeded()
            }
            
            cell.cellImageView.layer.cornerRadius = newSize / 2
            cell.cellImageView.clipsToBounds = false
            cell.cellImageView.layer.borderWidth = 3
            cell.cellImageView.layer.borderColor = UIColor.darkGray.cgColor
            cell.cellImageView.layer.shadowColor = UIColor.darkGray.cgColor
            cell.cellImageView.layer.shadowOpacity = 0.8
            cell.cellImageView.layer.shadowOffset = CGSize(width: 0, height: 4)
            cell.cellImageView.layer.shadowRadius = 8
            cell.cellImageView.layer.shadowPath = UIBezierPath(ovalIn: cell.cellImageView.bounds).cgPath
            cell.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)

        } else {
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
        
        cell.cellTitleLabel.text = cellData.1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
            selectedMoodIndex = indexPath.row
            print("Selected Mood Index after update: \(selectedMoodIndex)")
            self.instance.moodAnswer = self.instance.moodData?.options[selectedMoodIndex].optionTypeID
            print("Selected moodAnswer after update: \(String(describing: self.instance.moodAnswer))")
            // ✅ Directly call delegate
            delegate?.didChangeSelectedIndex(forTag: self.tag, selectedIndex: selectedMoodIndex)

        case .UserFocusHoursCell:
            selectedFocusIndex = indexPath.row
            print("Selected Focus Index after update: \(selectedFocusIndex)")
            self.instance.focusAnswer = self.instance.focusData?.options[selectedFocusIndex].optionTypeID
            print("Selected focusAnswer after update: \(String(describing: self.instance.focusAnswer))")
            // ✅ Directly call delegate — don't rely on didSet chain
            delegate?.didChangeSelectedIndex(forTag: self.tag, selectedIndex: selectedFocusIndex)

        case .UserEntryTimeSpendCell:
            let answer = String(indexPath.row + 1)
            if spendHoursAnswer1.contains(answer) {
                if let index = spendHoursAnswer1.firstIndex(of: answer) {
                    spendHoursAnswer1.remove(at: index)
                }
            } else {
                spendHoursAnswer1.append(answer)
            }
            self.instance.timeSpendAnswer = spendHoursAnswer1

        default:
            break
        }
        collectionView.reloadData()
    }
}
