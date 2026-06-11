//
//  VapingReferenceLinkView.swift
//  Calmscient
//
//  Tappable CDC reference link on the vaping education screen.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct VapingReferenceLinkView: View {

    let urlText: String
    let onTap: () -> Void

    private let linkColor = Color("barColor1")

    var body: some View {
        Button(action: onTap) {
            Text(urlText)
                .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                .foregroundStyle(linkColor)
                .underline()
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Vaping reference link") {
    VapingReferenceLinkView(
        urlText: "vaping_reference_url".localized,
        onTap: {}
    )
    .padding(.horizontal, 20)
}
#endif
