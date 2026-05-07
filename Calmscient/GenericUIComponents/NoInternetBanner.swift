// NoInternetBanner.swift
import UIKit

final class NoInternetBanner {

    static let shared = NoInternetBanner()
    private var banner: UIView?
    private var isAnimatingOut = false  // ✅ Track hide animation separately

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .networkStatusChanged,
            object: nil
        )

        // ✅ Re-evaluate on foreground in case status changed while backgrounded
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func appDidBecomeActive() {
        if !NetworkMonitor.shared.isConnected {
            show()
        } else {
            hide()
        }
    }

    @objc private func networkStatusChanged(_ notification: Notification) {
        guard let isConnected = notification.object as? Bool else { return }
        DispatchQueue.main.async {
            if isConnected {
                self.hide()
            } else {
                self.show()
            }
        }
    }

    // MARK: - Window

    private func getKeyWindow() -> UIWindow? {
        UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }

    // MARK: - Show

    func show() {
        // ✅ Allow re-show if currently animating out (disconnected again quickly)
        guard (banner == nil || isAnimatingOut), let window = getKeyWindow() else { return }
      
        // Remove any in-progress hide animation
        if isAnimatingOut {
            banner?.layer.removeAllAnimations()
            banner?.removeFromSuperview()
            banner = nil
            isAnimatingOut = false
        }

        let pill = UILabel()
        pill.text = "No internet connection."
        pill.textColor = .white
        pill.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        pill.textAlignment = .center
        pill.numberOfLines = 1
        pill.backgroundColor = UIColor(red: 0.42, green: 0.39, blue: 0.72, alpha: 0.93)
        pill.layer.cornerRadius = 20
        pill.clipsToBounds = true

        pill.sizeToFit()
        let pillWidth = min(pill.frame.width + 48, window.frame.width - 64)
        let pillHeight: CGFloat = 40
        let pillX = (window.frame.width - pillWidth) / 2
        let bottomOffset = window.safeAreaInsets.bottom + 83 + 8
        let pillY = window.frame.height - bottomOffset - pillHeight

        pill.frame = CGRect(x: pillX, y: pillY, width: pillWidth, height: pillHeight)
        window.addSubview(pill)

        pill.transform = CGAffineTransform(translationX: 0, y: 60)
        pill.alpha = 0
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            pill.transform = .identity
            pill.alpha = 1
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // If a banner already exists and isn't animating out,
            // don't just return; maybe give it a "shake" or just let it be.
            if self.banner != nil && !self.isAnimatingOut {
                banner = pill
                return
            }
            
            guard let window = self.getKeyWindow() else {
                print("DEBUG: No Key Window found")
                return
            }
        }

        banner = pill
    }
    
   
       
            
   

    // MARK: - Hide

    func hide() {
        guard let banner, !isAnimatingOut else { return }
        isAnimatingOut = true
        self.banner = nil

        UIView.animate(withDuration: 0.2, animations: {
            banner.transform = CGAffineTransform(translationX: 0, y: 60)
            banner.alpha = 0
        }) { _ in
            banner.removeFromSuperview()
            self.isAnimatingOut = false  // ✅ Reset flag after animation completes
        }
    }
}
