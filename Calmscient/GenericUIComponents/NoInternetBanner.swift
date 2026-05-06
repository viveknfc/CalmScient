import UIKit

final class NoInternetBanner {
    
    static let shared = NoInternetBanner()
    
    private var banner: UIView?
    
    private init() {}
    
    // ✅ Get correct window (FIXED BUG)
    private func getKeyWindow() -> UIWindow? {
        return UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
    
    func show() {
        guard banner == nil,
              let window = getKeyWindow() else { return }
        
        let height: CGFloat = 70
        
        let container = UIView(frame: CGRect(
            x: 16,
            y: window.frame.height - height - 30,
            width: window.frame.width - 32,
            height: height
        ))
        
        container.backgroundColor = .white
        container.layer.cornerRadius = 12
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.2
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        let label = UILabel(frame: CGRect(
            x: 16,
            y: 0,
            width: container.frame.width - 80,
            height: height
        ))
        label.text = "No Internet Connection"
        label.textColor = .red
        label.font = UIFont.boldSystemFont(ofSize: 15)
        
        // ❌ Remove "Details" button
        // ✅ Add Close (✕) button
        let closeButton = UIButton(frame: CGRect(
            x: container.frame.width - 50,
            y: 0,
            width: 50,
            height: height
        ))
        
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.darkGray, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        container.addSubview(label)
        container.addSubview(closeButton)
        
        window.addSubview(container)
        
        // animation
        container.transform = CGAffineTransform(translationX: 0, y: 100)
        UIView.animate(withDuration: 0.3) {
            container.transform = .identity
        }
        
        banner = container
    }
    
    @objc private func closeTapped() {
        hide()
    }
    
    func hide() {
        guard let banner = banner else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            banner.alpha = 0
        }) { _ in
            banner.removeFromSuperview()
        }
        
        self.banner = nil
    }
    
    @objc func openDetails() {
        guard let topVC = UIApplication.topViewController() else { return }
        let vc = NoInternetViewController()
        vc.modalPresentationStyle = .overFullScreen
        topVC.present(vc, animated: true)
    }
}
