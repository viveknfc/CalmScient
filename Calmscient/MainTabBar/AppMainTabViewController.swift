//
//  AppMainTabViewController.swift
//  MainTabBarApp
//
//  Created by KA on 13/03/24.
//

import SwiftUI
import UIKit

var tabTitles: [String] = []

@available(iOS 16.0, *)
@available(iOS 16.0, *)
final class AppMainTabViewController: UIViewController {

    private let viewModel = MainTabBarViewModel()

    /// When `medicineFlagString == "0"`, the first tab shows medications instead of the home dashboard (typo preserved).
    var isInitalView: Bool {
        get { viewModel.isInitalView }
        set { viewModel.isInitalView = newValue }
    }

    private var hostingController: UIHostingController<MainTabBarView>!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(languageChanged(_:)),
            name: .languageChanged,
            object: nil
        )

        navigationController?.setNavigationBarHidden(true, animated: false)

        MainTabBarAppearance.apply()

        let rootView = MainTabBarView(viewModel: viewModel)
        hostingController = UIHostingController(rootView: rootView)
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
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        ManagingAnxietyBeginStatusBarAppearance.usesLightContent ? .lightContent : .default
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        viewModel.prepareTabsCycle(reason: "viewWillAppear")
    }

    @objc private func languageChanged(_ notification: Notification) {
        viewModel.refreshLocalizedTabTitles()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .languageChanged, object: nil)
    }
}

@available(iOS 16.0, *)
final class TestViewController4: UIViewController {

    private let viewModel = TestViewController4ViewModel()
    private var hostingController: UIHostingController<TestViewController4View>!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        hostingController = UIHostingController(rootView: TestViewController4View(viewModel: viewModel))
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
    }
}

extension UIColor {
    class func randomColor(randomAlpha: Bool = false) -> UIColor {
        let redValue = CGFloat(arc4random_uniform(255)) / 255.0
        let greenValue = CGFloat(arc4random_uniform(255)) / 255.0
        let blueValue = CGFloat(arc4random_uniform(255)) / 255.0
        let alphaValue = randomAlpha ? CGFloat(arc4random_uniform(255)) / 255.0 : 1

        return UIColor(red: redValue, green: greenValue, blue: blueValue, alpha: alphaValue)
    }
}

extension Notification.Name {
    static let languageChanged = Notification.Name("languageChanged")
}
