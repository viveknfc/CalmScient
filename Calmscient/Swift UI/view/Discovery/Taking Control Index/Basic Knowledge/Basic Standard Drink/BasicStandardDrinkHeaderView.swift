//
//  BasicStandardDrinkHeaderView.swift
//  Calmscient
//
//  Section headline for the standard drink screen.
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BasicStandardDrinkHeaderView: View {

    let title: String

    var body: some View {
        Text(title)
            .font(LoginDesignSystem.Typography.lexendRegular(size: 16))
            .foregroundStyle(Color("barColor1"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Standard drink header") {
    BasicStandardDrinkHeaderView(title: "What\u{2019}s a standard drink".localized)
        .padding(.horizontal, 20)
}
#endif
