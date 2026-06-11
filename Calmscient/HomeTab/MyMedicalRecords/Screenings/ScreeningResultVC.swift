//
//  ScreeningResultVC.swift
//  Calmscient
//
//  Storyboard shell that embeds `ScreeningResultHostingController` (SwiftUI) on iOS 16+.
//
//  Vivek
//  15 May 2026
//

import SwiftUI
import UIKit

final class ScreeningResultVC: ViewController {

    public weak var selectedScreening: Screening?

    var isComingFromParticularVC = false
    var isComingFromParticularVC1 = false
    var isComingFromParticularVC2 = false

    private var resultHost: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 16.0, *) {
            installSwiftUIResultHost()
        }
    }

    @available(iOS 16.0, *)
    private func installSwiftUIResultHost() {
        view.subviews.forEach { $0.removeFromSuperview() }

        let host = ScreeningResultHostingController()
        if let selectedScreening {
            host.configure(
                selectedScreening: selectedScreening,
                isComingFromParticularVC: isComingFromParticularVC,
                isComingFromParticularVC1: isComingFromParticularVC1,
                isComingFromParticularVC2: isComingFromParticularVC2
            )
        }
        resultHost = host
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        host.didMove(toParent: self)
    }
}
