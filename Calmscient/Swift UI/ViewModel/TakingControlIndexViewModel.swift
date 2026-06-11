//
//  TakingControlIndexViewModel.swift
//  Calmscient
//
//  Container state for Taking Control index (drinking / smoking tabs, back navigation).
//
//  Vivek
//  20 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class TakingControlIndexViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    var shouldPopBack = false
    var moveToIntro = false

    @Published var selectedSegment: TakingControlSegment = .drinking
    @Published private(set) var screenTitle: String = ""

    let drinkingViewModel = DrinkingControlViewModel()
    let smokingViewModel = SmokingControlViewModel()

    func configure(initialSegment: Int, shouldPopBack: Bool, moveToIntro: Bool) {
        selectedSegment = initialSegment == 1 ? .smoking : .drinking
        self.shouldPopBack = shouldPopBack
        self.moveToIntro = moveToIntro
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
        drinkingViewModel.hostViewController = hostViewController
        smokingViewModel.hostViewController = hostViewController
        drinkingViewModel.onHostWillAppear()
        smokingViewModel.onHostWillAppear()

        if moveToIntro, let host = hostViewController {
            moveToIntro = false
            TakingControlIntroNavigation.push(from: host, animated: true)
        }
    }

    func reloadLocalizedStrings() {
        screenTitle = "Taking control".localized
        drinkingViewModel.reloadLocalizedStrings()
        smokingViewModel.reloadLocalizedStrings()
    }

    func selectSegment(_ segment: TakingControlSegment) {
        selectedSegment = segment
        switch segment {
        case .drinking:
            drinkingViewModel.onHostWillAppear()
        case .smoking:
            smokingViewModel.onHostWillAppear()
        }
    }

    func openBack() {
        guard let nav = hostViewController?.navigationController else { return }
        if shouldPopBack {
            nav.popViewController(animated: true)
            return
        }
        nav.setViewControllers([DiscoveryMainHostingController()], animated: true)
    }
}

// MARK: - Navigation

@available(iOS 16.0, *)
enum TakingControlIndexNavigation {

    static func push(
        from host: UIViewController,
        initialSegment: Int = 0,
        shouldPopBack: Bool = false,
        moveToIntro: Bool = false,
        animated: Bool = true
    ) {
        guard let nav = host.navigationController else { return }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        host.navigationItem.backBarButtonItem = backItem

        let indexScreen = TakingControlIndexHostingController()
        indexScreen.configure(
            initialSegment: initialSegment,
            shouldPopBack: shouldPopBack,
            moveToIntro: moveToIntro
        )
        nav.pushViewController(indexScreen, animated: animated)
    }
}
