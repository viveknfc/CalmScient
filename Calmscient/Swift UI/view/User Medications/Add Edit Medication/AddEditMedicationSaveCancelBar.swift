//
//  AddEditMedicationSaveCancelBar.swift
//  Calmscient
//
//  Bottom Cancel (outline) + Save (gradient capsule) actions.
//

//  Vivek
//  15 May 2026
//
import SwiftUI

struct AddEditMedicationSaveCancelBar: View {
    let onCancel: () -> Void
    let onSave: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onCancel) {
                Text(AppHelper.getLocalizeString(str: "Cancel"))
                    .font(LoginDesignSystem.Typography.lexendSemiBold(size: 14))
                    .foregroundStyle(LoginDesignSystem.ColorName.primaryGradientTop)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        Capsule(style: .continuous)
                            .stroke(LoginDesignSystem.ColorName.primaryGradientTop, lineWidth: 2)
                    )
            }
            .buttonStyle(.plain)

            Button(action: onSave) {
                Text(AppHelper.getLocalizeString(str: "Save"))
                    .font(LoginDesignSystem.Typography.lexendSemiBold(size: 14))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        Capsule(style: .continuous)
                            .fill(LoginDesignSystem.ColorName.loginGradient)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 8)
    }
}

#if DEBUG
#Preview("Save / Cancel bar") {
    AddEditMedicationSaveCancelBar(onCancel: {}, onSave: {})
        .padding(.horizontal, 18)
}
#endif
