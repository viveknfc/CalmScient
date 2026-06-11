//
//  DiscoveryMainHostingController.swift
//  Calmscient
//
//  UIKit container for `DiscoveryMainView` (tab root — no back button; child screens pop here).
//
//  Vivek
//  19 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class DiscoveryMainHostingController: UIViewController {

    private let viewModel = DiscoveryMainViewModel()
    private var hostingController: UIHostingController<DiscoveryMainView>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        viewModel.hostViewController = self

        hostingController = UIHostingController(rootView: DiscoveryMainView(viewModel: viewModel))
        hostingController.view.backgroundColor = .clear
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hostingController.didMove(toParent: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isHidden = false
        viewModel.onHostWillAppear()
        applyNavigationChrome()
    }

    private func applyNavigationChrome() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = viewModel.screenTitle

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

        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        navigationItem.compactScrollEdgeAppearance = appearance

        if let navBar = navigationController?.navigationBar {
            navBar.isTranslucent = false
            navBar.standardAppearance = appearance
            navBar.scrollEdgeAppearance = appearance
            navBar.compactAppearance = appearance
            navBar.compactScrollEdgeAppearance = appearance
            navBar.shadowImage = UIImage()
        }

        navigationItem.leftBarButtonItem = nil
        navigationItem.hidesBackButton = true

        let iconSide: CGFloat = 28
        let profileButton = DiscoveryNavBarIconButton(
            image: Self.navBarIconImage(named: "profileIcon.png", side: iconSide, fill: false),
            side: iconSide,
            action: UIAction { [weak self] _ in self?.viewModel.openProfile() }
        )
        let citationButton = DiscoveryNavBarIconButton(
            image: Self.navBarIconImage(named: "Citation", side: iconSide, fill: true, circular: true),
            side: iconSide,
            isCircular: true,
            action: UIAction { [weak self] _ in self?.viewModel.openCitationSources() }
        )

        let trailingIcons = UIStackView(arrangedSubviews: [citationButton, profileButton])
        trailingIcons.axis = .horizontal
        trailingIcons.spacing = 8
        trailingIcons.alignment = .center
        trailingIcons.distribution = .fill

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: trailingIcons)
    }

    private static func navBarIconImage(named name: String, side: CGFloat, fill: Bool, circular: Bool = false) -> UIImage? {
        guard let image = UIImage(named: name) else { return nil }
        let canvas = CGSize(width: side, height: side)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale
        return UIGraphicsImageRenderer(size: canvas, format: format).image { ctx in
            let bounds = CGRect(origin: .zero, size: canvas)
            if circular {
                ctx.cgContext.addEllipse(in: bounds)
                ctx.cgContext.clip()
            } else {
                ctx.cgContext.clip(to: bounds)
            }
            var scale = fill
                ? max(side / image.size.width, side / image.size.height)
                : min(side / image.size.width, side / image.size.height)
            if fill { scale *= 1.35 }
            let drawSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            let origin = CGPoint(x: (side - drawSize.width) / 2, y: (side - drawSize.height) / 2)
            image.draw(in: CGRect(origin: origin, size: drawSize))
        }.withRenderingMode(.alwaysOriginal)
    }
}

// MARK: - Nav bar icon button

private final class DiscoveryNavBarIconButton: UIButton {

    init(image: UIImage?, side: CGFloat, isCircular: Bool = false, action: UIAction) {
        super.init(frame: CGRect(x: 0, y: 0, width: side, height: side))
        setImage(image, for: .normal)
        addAction(action, for: .touchUpInside)
        translatesAutoresizingMaskIntoConstraints = false
        contentHorizontalAlignment = .center
        contentVerticalAlignment = .center
        if isCircular {
            layer.cornerRadius = side / 2
            clipsToBounds = true
        }
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: side),
            heightAnchor.constraint(equalToConstant: side),
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
