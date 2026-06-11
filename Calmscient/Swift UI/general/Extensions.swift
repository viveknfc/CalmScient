//
//  Extensions.swift
//  Calmscient
//
//  Vivek
//  14 May 2026
//
import SwiftUI
import UIKit

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64

        switch hex.count {
        case 3:
            (a, r, g, b) = (
                255,
                (int >> 8) * 17,
                (int >> 4 & 0xF) * 17,
                (int & 0xF) * 17
            )

        case 6:
            (a, r, g, b) = (
                255,
                int >> 16,
                int >> 8 & 0xFF,
                int & 0xFF
            )

        case 8:
            (a, r, g, b) = (
                int >> 24,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )

        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

/// Shared back control for nav bars and SwiftUI headers (`NavigationBack` asset, 32×32).
struct MedicationNavigationBackButton: View {
    let onBack: () -> Void

    var body: some View {
        Button(action: onBack) {
            Image("NavigationBack")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .frame(width: 32, height: 32)
        .fixedSize()
    }
}

@MainActor
enum MedicationFlowNavigationBarBackItem {
    private static let iconSide: CGFloat = 32

    /// Leading bar button using `MedicationNavigationBackButton`; retain the returned hosting controller for the lifetime of the owning view controller.
    static func leadingBarButton(onBack: @escaping () -> Void) -> (UIBarButtonItem, UIHostingController<MedicationNavigationBackButton>) {
        let host = UIHostingController(rootView: MedicationNavigationBackButton(onBack: onBack))
        host.view.backgroundColor = .clear
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.sizingOptions = [.intrinsicContentSize]

        let wrap = UIView()
        wrap.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(host.view)
        NSLayoutConstraint.activate([
            wrap.widthAnchor.constraint(equalToConstant: iconSide),
            wrap.heightAnchor.constraint(equalToConstant: iconSide),
            host.view.topAnchor.constraint(equalTo: wrap.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: wrap.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: wrap.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: wrap.bottomAnchor),
        ])
        return (UIBarButtonItem(customView: wrap), host)
    }
}
