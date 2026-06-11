//
//  StatusBarBackgroundOverlay.swift
//  Calmscient
//
//  Paints the status bar region when SwiftUI TabView leaves a white strip above UIKit nav stacks.
//
//  Vivek
//  19 May 2026
//

import UIKit

@MainActor
enum ManagingAnxietyBeginStatusBarAppearance {
    static var usesLightContent = false
}

@MainActor
enum StatusBarBackgroundOverlay {

    private static let overlayTag = 939_001

    static let discoveryNavBarPurple = UIColor(
        red: 0.5218948722,
        green: 0.5200269818,
        blue: 0.7418552041,
        alpha: 1
    )

    static func show(color: UIColor) {
        guard let window = keyWindow else { return }
        hide()

        let statusBarHeight = window.windowScene?.statusBarManager?.statusBarFrame.height ?? window.safeAreaInsets.top
        guard statusBarHeight > 0 else { return }

        let overlay = UIView(frame: CGRect(x: 0, y: 0, width: window.bounds.width, height: statusBarHeight))
        overlay.tag = overlayTag
        overlay.backgroundColor = color
        overlay.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        overlay.isUserInteractionEnabled = false
        window.addSubview(overlay)
    }

    static func hide() {
        keyWindow?.viewWithTag(overlayTag)?.removeFromSuperview()
    }

    private static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
    }
}
