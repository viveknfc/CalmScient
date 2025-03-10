//
//  UserEntrySleepHoursCell.swift
//  HealthApp
//
//  Created by KA on 28/02/24.
//

import UIKit

class UserEntrySleepHoursCell: UITableViewCell {

    @IBOutlet weak var cornerView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sleepHoursCollectionView: UICollectionView!
    
    @IBOutlet weak var sleepHoursLabel: UILabel!
    
    let selectedBorderColor = UIColor(named: "circleCellSelectedColor")
    let defaultBorderColor = UIColor(named: "circleIntroBorderColor")
    let selectedTextColor = UIColor.white
    let defaultTextColor = UIColor(named: "circleTextColor")
    let selectedFillColor = UIColor(named: "circleCellSelectedColor")
    let defaultFillColor = UIColor(named: "circleFillColor")
    
    let languageId = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
    
    let sleepData = ["Less","4","5","6","7","8","9","10","More"]
    let sleepData1 = ["Menos","4","5","6","7","8","9","10","Más"]
    
    var selectedIndex: Int = 7 {
           didSet {
               print("the selected index value for sleep is", selectedIndex)
               sleepHoursCollectionView.reloadData()
           }
       }
    
    
    private var cellType:UserEntryDayFeedbackTableCell!
    private var instance:UserStartupScreenDayData!
    
    let colors = [UIColor(named: "medicationsWeekCellColor"),UIColor(named: "medicationsWeekCellColor"),UIColor(named: "medicationscelldefaulttextcolor"),UIColor(named: "medicationsSelectedColor"),UIColor(named: "medicationsSelectedColor"),UIColor.white]
    override func awakeFromNib() {
        super.awakeFromNib()
        addShadowAndBorder()
        let nib = UINib(nibName: "UserEntrySleepCell", bundle: nil)
        sleepHoursCollectionView.register(CustomCollectionViewCell.self, forCellWithReuseIdentifier: "CustomCollectionViewCell")
        sleepHoursCollectionView.register(CustomOvalCollectionViewCell.self, forCellWithReuseIdentifier: "CustomOvalCollectionViewCell")
        sleepHoursCollectionView.register(nib, forCellWithReuseIdentifier: "UserEntrySleepCell")
        if let layout = sleepHoursCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
        sleepHoursCollectionView.contentInsetAdjustmentBehavior = .never

        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func getUpdatedData() -> Int? {
        return self.selectedIndex + 1
    }

    
    func updateUIWithCellInstance(instance:UserStartupScreenDayData, cellType:UserEntryDayFeedbackTableCell, slpHrs: Int) {
        self.instance = instance
        self.cellType = cellType
        
        self.titleLabel.font = UIFont(name: Fonts().lexendMedium, size: 16)
        
        let labelText = languageId == 1 ? "How many hours did you sleep last night?" : "¿Cuántas horas dormiste anoche?"
        
        let attributedText = NSMutableAttributedString(string: labelText)
        let redAsterisk = NSAttributedString(
            string: " *",
            attributes: [.foregroundColor: UIColor.red]
        )
        attributedText.append(redAsterisk)
        
        self.titleLabel.attributedText = attributedText
        selectedIndex = slpHrs
        
        if slpHrs < 0 {
            self.sleepHoursLabel.isHidden = true
        } else {
            self.sleepHoursLabel.isHidden = false
            
            if slpHrs < 1 {
                self.sleepHoursLabel.text = "Less than 4 Hours"
            } else if slpHrs > 7 {
                self.sleepHoursLabel.text = "More than 10 Hours"
            } else {
                self.sleepHoursLabel.text = "\(sleepData[slpHrs]) Hours"
            }
            
        }
        
        sleepHoursCollectionView.delegate = self
        sleepHoursCollectionView.dataSource = self
        sleepHoursCollectionView.reloadData() //instance.sleepData?.sleepQuestion
    }
    
    func updateSelectedIndex(newIndex: Int) {
        print("the index value is", newIndex)
            selectedIndex = newIndex
        }
    
    fileprivate func addShadowAndBorder() {
        shadowView.layer.backgroundColor = UIColor.clear.cgColor
        shadowView.layer.shadowColor = UIColor(named: "AppViewShadowColor")?.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        shadowView.layer.shadowOpacity = 0.2
        shadowView.layer.shadowRadius = 2.0
        
        cornerView.layer.cornerRadius = 8
        cornerView.layer.masksToBounds = true
        cornerView.layer.borderWidth = 1
        cornerView.layer.borderColor = UIColor(named: "AppViewBorderColor")?.cgColor
    }

    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension UserEntrySleepHoursCell : UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sleepData.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
  
        if indexPath.row == 0 || indexPath.row == 8 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as? CustomCollectionViewCell else {
                return UICollectionViewCell()
            }
            if indexPath.row == selectedIndex {
                print("entered cell for row selected index")
                cell.circleStrokeColor = selectedBorderColor
                cell.circleFillColor = selectedFillColor
                cell.contentTextColor = UIColor.white
            } else {
                cell.circleStrokeColor = defaultBorderColor
                cell.circleFillColor = defaultFillColor
                cell.contentTextColor = defaultTextColor
            }
            
            let cellText: () = languageId == 1 ? cell.setCircleText(text: sleepData[indexPath.row]) : cell.setCircleText(text: sleepData1[indexPath.row])
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomOvalCollectionViewCell", for: indexPath) as? CustomOvalCollectionViewCell else {
                return UICollectionViewCell()
            }
            if indexPath.row == selectedIndex {
                print("entered cell for row selected index from oval cell")

                    cell.circleStrokeColor = self.selectedBorderColor
                    cell.circleFillColor = self.selectedFillColor
                    cell.contentTextColor = UIColor.white
                
            } else {
                cell.circleStrokeColor = defaultBorderColor
                cell.circleFillColor = defaultFillColor
                cell.contentTextColor = defaultTextColor
            }
            
            cell.setCircleText(text: sleepData[indexPath.row])
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItems = 9
        let spacing: CGFloat = 6
        let padding: CGFloat = 5
        
        // Calculate available width considering padding and spacing
        let totalSpacing = CGFloat(numberOfItems - 1) * spacing + (2 * padding)
        let availWidth = collectionView.frame.width - totalSpacing
        
        // Determine square width based on available width and collection view height
        let possibleHeight = collectionView.frame.height - 2
        let squareWidth = floor(min(availWidth / CGFloat(numberOfItems), possibleHeight))
        print("the squareWidth is", squareWidth)
        return CGSize(width: squareWidth, height: squareWidth)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let numberOfItems = 9
        let spacing: CGFloat = 6
        let padding: CGFloat = 5
        
        // Calculate available width and square size
        let totalSpacing = CGFloat(numberOfItems - 1) * spacing
        let availWidth = collectionView.frame.width - (2 * padding)
        let possibleHeight = collectionView.frame.height - 2
        let squareWidth = floor(min((availWidth - totalSpacing) / CGFloat(numberOfItems), possibleHeight))
        
        // Calculate total content width
        let totalCellWidth = CGFloat(numberOfItems) * squareWidth
        let totalContentWidth = totalCellWidth + totalSpacing
        
        // Adjust insets to center items if needed
        let inset = max((collectionView.frame.width - totalContentWidth) / 2, 0)
        
        return UIEdgeInsets(top: 10, left: inset + padding, bottom: 10, right: inset + padding)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    
}

extension UserEntrySleepHoursCell : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        instance.sleepAnswer = selectedIndex

        self.sleepHoursLabel.isHidden = false
        if indexPath.row == 0 {
            self.sleepHoursLabel.text = "Less than 4 Hours"
        } else if indexPath.row == 8 {
            self.sleepHoursLabel.text = "More than 10 Hours"
        } else {
            self.sleepHoursLabel.text = "\(sleepData[indexPath.row]) Hours"
        }
        
        
        collectionView.reloadData()
    }
}
