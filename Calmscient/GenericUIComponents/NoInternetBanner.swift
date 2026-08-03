import UIKit
import SwiftUI

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
        // Toast banner intentionally disabled.
        // Offline messaging is now handled globally by `NoInternetOverlayPresenter`,
        // which shows the localised no-internet popup on whichever screen is active.
        // Kept as a no-op so existing call sites remain valid without any behaviour change.
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

// MARK: - Global No-Internet Popup (SwiftUI)

/// SwiftUI bottom-sheet popup shown app-wide when the internet connection drops.
/// Title and description are localised (`no_internet_title` / `no_internet_desc`).
struct NoInternetPopupView: View {

    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 8) {
                    Text("no_internet_title".localized)
                        .font(.custom(Fonts().lexendMedium, size: 18))
                        .foregroundColor(Color(UIColor.label))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.gray)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(Color.gray.opacity(0.15)))
                    }
                }

                Text("no_internet_desc".localized)
                    .font(.custom(Fonts().lexendRegular, size: 15))
                    .foregroundColor(Color(UIColor.darkGray))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }
}

/// Presents `NoInternetPopupView` over whichever screen is active whenever the
/// connection drops, and dismisses it automatically when the connection returns.
/// Reuses the app-wide `.networkStatusChanged` notification, so it does not
/// interfere with any existing per-screen network handling.
final class NoInternetOverlayPresenter {

    static let shared = NoInternetOverlayPresenter()

    private weak var popupController: UIViewController?
    private var isStarted = false

    private init() {}

    /// Begins observing network changes. Safe to call once at app launch.
    func start() {
        guard !isStarted else { return }
        isStarted = true

        // Ensure the shared monitor is running.
        _ = NetworkMonitor.shared

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNetworkStatusChange(_:)),
            name: .networkStatusChanged,
            object: nil
        )

        // Reflect the current state at launch (e.g. app started while offline).
        if !NetworkMonitor.shared.isConnected {
            DispatchQueue.main.async { [weak self] in
                self?.presentPopup()
            }
        }
    }

    @objc private func handleNetworkStatusChange(_ notification: Notification) {
        let connected = (notification.object as? Bool) ?? NetworkMonitor.shared.isConnected
        DispatchQueue.main.async { [weak self] in
            if connected {
                self?.dismissPopup()
            } else {
                self?.presentPopup()
            }
        }
    }

    private func presentPopup() {
        guard popupController == nil,
              let top = UIApplication.topViewController(),
              !top.isBeingPresented,
              !top.isBeingDismissed else { return }

        let host = UIHostingController(
            rootView: NoInternetPopupView(onClose: { [weak self] in
                self?.dismissPopup()
            })
        )
        host.modalPresentationStyle = .overFullScreen
        host.modalTransitionStyle = .crossDissolve
        host.view.backgroundColor = .clear

        popupController = host
        top.present(host, animated: true)
    }

    private func dismissPopup() {
        guard let host = popupController else { return }
        popupController = nil
        host.dismiss(animated: true)
    }
}
