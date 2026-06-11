//
//  ScreeningResultHostingController.swift
//  Calmscient
//
//  UIKit shell for `ScreeningResultView` (navigation, `NavigationBack`, tab bar).
//
//  Vivek
//  15 May 2026
//

import Combine
import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class ScreeningResultHostingController: UIViewController {

    let viewModel = ScreeningResultViewModel()
    private var hostingController: UIHostingController<ScreeningResultView>!
    private var moreInfoHostingController: UIHostingController<ScreeningResultMoreInfoOverlayView>?
    private var moreInfoOverlayCancellable: AnyCancellable?

    private static let moreInfoOverlayTag = 9_001

    private var navigationItemOwner: UIViewController {
        if let parent = parent as? ScreeningResultVC {
            return parent
        }
        return self
    }

    func configure(
        selectedScreening: Screening,
        isComingFromParticularVC: Bool = false,
        isComingFromParticularVC1: Bool = false,
        isComingFromParticularVC2: Bool = false
    ) {
        viewModel.configure(selectedScreening: selectedScreening)
        viewModel.isComingFromParticularVC = isComingFromParticularVC
        viewModel.isComingFromParticularVC1 = isComingFromParticularVC1
        viewModel.isComingFromParticularVC2 = isComingFromParticularVC2
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: ScreeningResultView(viewModel: viewModel))
        hostingController.view.backgroundColor = .clear
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hostingController.didMove(toParent: self)

        moreInfoOverlayCancellable = viewModel.$showsMoreInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shows in
                if shows {
                    self?.presentMoreInfoOverlay()
                } else {
                    self?.dismissMoreInfoOverlay()
                }
            }
    }

    deinit {
        dismissMoreInfoOverlay(animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isHidden = false
        viewModel.onHostWillAppear()
        applyNavigationChrome()
        tabBarController?.tabBar.isHidden = false
        tabBarController?.tabBar.selectedItem?.title = "main_tab_bar_home".localized
    }

    private func applyNavigationChrome() {
        let owner = navigationItemOwner
        owner.navigationItem.largeTitleDisplayMode = .never
        owner.navigationItem.title = viewModel.navigationChromeTitle

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        if let customFont = UIFont(name: Fonts().lexendMedium, size: 18) {
            appearance.titleTextAttributes = [
                .font: customFont,
                .foregroundColor: UIColor.black,
            ]
        }
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()

        owner.navigationItem.standardAppearance = appearance
        owner.navigationItem.scrollEdgeAppearance = appearance
        owner.navigationItem.compactAppearance = appearance
        owner.navigationItem.compactScrollEdgeAppearance = appearance

        if let navBar = navigationController?.navigationBar {
            navBar.isTranslucent = false
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            navBar.compactAppearance = appearance
            navBar.compactScrollEdgeAppearance = appearance
            navBar.shadowImage = UIImage()
        }

        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "NavigationBack")?.withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.addAction(UIAction { [weak self] _ in
            self?.viewModel.openBack()
        }, for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
        owner.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }

    // MARK: - Full-screen More Info (covers nav bar + tab bar; parity with legacy alert)

    private func presentMoreInfoOverlay() {
        guard moreInfoHostingController == nil,
              let window = Self.keyWindow else { return }

        window.subviews.filter { $0.tag == Self.moreInfoOverlayTag }.forEach { $0.removeFromSuperview() }

        navigationController?.navigationBar.layer.zPosition = -1

        let overlayHost = UIHostingController(
            rootView: ScreeningResultMoreInfoOverlayView { [weak self] in
                self?.viewModel.dismissMoreInfo()
            }
        )
        overlayHost.view.backgroundColor = .clear
        overlayHost.view.frame = window.bounds
        overlayHost.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlayHost.view.tag = Self.moreInfoOverlayTag
        overlayHost.view.alpha = 0

        window.addSubview(overlayHost.view)
        moreInfoHostingController = overlayHost

        let overlayView = overlayHost.view!
        UIView.transition(with: overlayView, duration: 0.25, options: .transitionCrossDissolve) {
            overlayView.alpha = 1
        }
    }

    private func dismissMoreInfoOverlay(animated: Bool = true) {
        guard let overlayView = moreInfoHostingController?.view else {
            navigationController?.navigationBar.layer.zPosition = 0
            return
        }

        let finish = {
            overlayView.removeFromSuperview()
            self.moreInfoHostingController = nil
            self.navigationController?.navigationBar.layer.zPosition = 0
        }

        guard animated else {
            finish()
            return
        }

        UIView.transition(with: overlayView, duration: 0.25, options: .transitionCrossDissolve, animations: {
            overlayView.alpha = 0
        }, completion: { _ in
            finish()
        })
    }

    private static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
    }
}
