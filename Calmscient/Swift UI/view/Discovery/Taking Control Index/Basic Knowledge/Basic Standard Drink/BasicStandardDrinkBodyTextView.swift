//
//  BasicStandardDrinkBodyTextView.swift
//  Calmscient
//
//  Secondary explanatory copy below the drink carousel.
//
//  Vivek
//  21 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct BasicStandardDrinkBodyTextView: View {

    let text: String

    var body: some View {
        Text(text)
            .font(LoginDesignSystem.Typography.lexendLight(size: 14))
            .foregroundStyle(Color("AppointmentsTextColor"))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Standard drink body") {
    BasicStandardDrinkBodyTextView(
        text: "standard drink description2".localized
    )
    .padding(.horizontal, 20)
}
#endif
