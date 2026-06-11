//
//  ManagingAnxietyBeginViewModel.swift
//  Calmscient
//
//  State and navigation for the Managing Anxiety discovery intro (parity with storyboard screen).
//
//  Vivek
//  19 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
final class ManagingAnxietyBeginViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    @Published private(set) var screenTitle: String = ""
    @Published private(set) var headlineText: String = ""
    @Published private(set) var bodyText: String = ""
    @Published private(set) var readyQuestionText: String = ""
    @Published private(set) var beginButtonTitle: String = ""

    init() {
        reloadLocalizedStrings()
    }

    func reloadLocalizedStrings() {
        screenTitle = "The Discovery".localized
        headlineText = "The Calmscient discovery will only be as effective as you make it.".localized
        bodyText = "So be determined to dedicate time to following along and completing the exercises. Each section has interesting and informative content that is designed to keep you actively thinking about your specific challenges. But, like taking a road trip to an unknown destination, you’ll need to be committed to following the map! It may be a little more work than you’re used to, but it will absolutely pay off in the end.".localized
        readyQuestionText = "Are you ready?".localized
        beginButtonTitle = "Let's begin!".localized
    }

    func onHostWillAppear() {
        reloadLocalizedStrings()
    }

    func openBack() {
        hostViewController?.navigationController?.popViewController(animated: true)
    }

    func beginManagingAnxietyCourse() {
        guard let host = hostViewController, let _ = host.navigationController else { return }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        host.navigationItem.backBarButtonItem = backItem

        CoursesNavigation.push(
            courseID: 2,
            title: "Managing anxiety".localized,
            from: host
        )
    }
}

// MARK: - Navigation

enum ManagingAnxietyBeginNavigation {

    static func push(from host: UIViewController, animated: Bool = true) {
        guard let nav = host.navigationController else { return }

        let backItem = UIBarButtonItem()
        backItem.title = ""
        host.navigationItem.backBarButtonItem = backItem

        let beginScreen = ManagingAnxietyBeginHostingController()
        nav.pushViewController(beginScreen, animated: animated)
    }
}
