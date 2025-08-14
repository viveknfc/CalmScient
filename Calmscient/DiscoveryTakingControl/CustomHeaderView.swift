import UIKit

class CustomHeaderView: UITableViewHeaderFooterView {
    let label = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    private func configure() {
//        contentView.backgroundColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(named: "blackAndWhite")  // Set your desired color here
        label.font = UIFont(name:Fonts().lexendRegular, size: 18)
        
        contentView.addSubview(label)

        // Add constraints to the label
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    func setText(_ text: String) {
        label.text = text
    }
}
