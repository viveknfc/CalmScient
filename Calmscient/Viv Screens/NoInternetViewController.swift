import UIKit

class NoInternetViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background overlay
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        
        setupUI()
    }
    
    private func setupUI() {
        
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.clipsToBounds = true
        
        view.addSubview(container)
        
        // Constraints (Bottom Sheet style)
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            container.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            container.heightAnchor.constraint(equalToConstant: 240)
        ])
        
        // Title
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "no_internet_title".localized
        title.font = UIFont.systemFont(ofSize: 17, weight: .semibold) // Android-like
        title.textColor = .black
        
        // Description (Android-style bullets)
        let desc = UILabel()
        desc.translatesAutoresizingMaskIntoConstraints = false
        desc.text = "no_internet_desc".localized
        desc.numberOfLines = 0
        desc.font = UIFont.systemFont(ofSize: 16) // smaller like Android
        desc.textColor = .darkGray
        
        // Close Button
        let close = UIButton(type: .system)
        close.translatesAutoresizingMaskIntoConstraints = false
        close.setTitle("✕", for: .normal)
        close.setTitleColor(.gray, for: .normal)
        close.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        close.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        container.addSubview(title)
        container.addSubview(desc)
        container.addSubview(close)
        
        // Layout Constraints (Proper padding like Android)
        NSLayoutConstraint.activate([
            
            // Close button
            close.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
            close.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            close.widthAnchor.constraint(equalToConstant: 30),
            close.heightAnchor.constraint(equalToConstant: 30),
            
            // Title
            title.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            title.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: close.leadingAnchor, constant: -8),
            
            // Description
            desc.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 12),
            desc.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            desc.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            desc.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor, constant: -20)
        ])
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
