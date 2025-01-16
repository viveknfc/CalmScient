import UIKit

@IBDesignable
class CustomSegmentedControl: UIControl {

    private var labels = [UILabel]()
    var thumbView = UIView()
    
    var bottomBorderViews = [UIView]()
    
    var items: [String] = [
        UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Drinking control" : "Control del Consumo de Alcohol",
        UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Smoking control" : "Control del Tabaquismo" ] {
        didSet {
            setupLabels()
            setupBorders()
        }
    }

    var selectedIndex: Int = 0 {
        didSet {
            displayNewSelectedIndex()
        }
    }

    @IBInspectable
    var selectedColor: UIColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1) {
        didSet {
            setSelectedColors()
        }
    }

    @IBInspectable
    var unselectedColor: UIColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1) {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable
    var selectedBorderColor: UIColor = UIColor(red: 110/255, green: 107/255, blue: 179/255, alpha: 1) {
        didSet {
            setSelectedColors()
        }
    }
    
    @IBInspectable
    var unselectedBorderColor: UIColor = UIColor(red: 224/255, green: 224/255, blue: 224/255, alpha: 1) {
        didSet {
            setSelectedColors()
        }
    }

    @IBInspectable
    var thumbColor: UIColor = UIColor(named: "lightF2F2F2Color")! {
        didSet {
            thumbView.backgroundColor = thumbColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupView() {
        backgroundColor = thumbColor
        setupLabels()
        setupBorders()
        insertSubview(thumbView, at: 0)
    }

    func setupLabels() {
        for label in labels {
            label.removeFromSuperview()
        }
        labels.removeAll()
        
        for index in 0..<items.count {
            let label = UILabel(frame: .zero)
            label.text = [
                UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Drinking Control" : "Control del Consumo de Alcohol",
                UserDefaults.standard.integer(forKey: "SelectedLanguageID") == 1 ? "Smoking Control" : "Control del Tabaquismo" ][index]
            label.textAlignment = .center
            label.font = UIFont(name: Fonts().lexendRegular, size: 16)!
            label.textColor = index == selectedIndex ? selectedColor : unselectedColor
            addSubview(label)
            labels.append(label)
        }
    }
    
    func setupBorders() {
        for border in bottomBorderViews {
            border.removeFromSuperview()
        }
        bottomBorderViews.removeAll()
        
        for _ in 0..<items.count {
            let borderView = UIView()
            borderView.backgroundColor = unselectedBorderColor
            addSubview(borderView)
            bottomBorderViews.append(borderView)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        var selectFrame = bounds
        let newWidth = selectFrame.width / CGFloat(items.count)
        selectFrame.size.width = newWidth
        thumbView.frame = selectFrame
        thumbView.backgroundColor = thumbColor
        thumbView.layer.cornerRadius = thumbView.frame.height / 2

        let labelHeight = bounds.height
        let labelWidth = bounds.width / CGFloat(labels.count)
        for index in 0..<labels.count {
            let label = labels[index]
            let xPos = CGFloat(index) * labelWidth
            label.frame = CGRect(x: xPos, y: 0, width: labelWidth, height: labelHeight)
            
            let borderView = bottomBorderViews[index]
            borderView.frame = CGRect(x: xPos, y: labelHeight - 2, width: labelWidth, height: 6)
        }

        displayNewSelectedIndex()
    }

    func displayNewSelectedIndex() {
        for (index, label) in labels.enumerated() {
            label.textColor = index == selectedIndex ? selectedColor : unselectedColor
            bottomBorderViews[index].backgroundColor = index == selectedIndex ? selectedBorderColor : unselectedBorderColor
        }

        let label = labels[selectedIndex]
        UIView.animate(withDuration: 0.3, animations: {
            self.thumbView.frame = label.frame
        })
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)

        var calculatedIndex: Int?
        for (index, item) in labels.enumerated() {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }

        if let calculatedIndex = calculatedIndex {
            selectedIndex = calculatedIndex
            sendActions(for: .valueChanged)
        }

        return false
    }

    private func setSelectedColors() {
        for (index, label) in labels.enumerated() {
            label.textColor = index == selectedIndex ? selectedColor : unselectedColor
            bottomBorderViews[index].backgroundColor = index == selectedIndex ? selectedBorderColor : unselectedBorderColor
        }
        thumbView.backgroundColor = thumbColor
    }
}
