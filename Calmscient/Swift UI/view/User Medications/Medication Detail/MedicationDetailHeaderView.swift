//
//  MedicationDetailHeaderView.swift
//  Calmscient
//
//  Lavender header with medicine illustration (matches `MedicationDetail.storyboard`).
//

//  Vivek
//  15 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct MedicationDetailHeaderView: View {
    let medicineName: String
    let providerName: String

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 68, height: 68)
                Image("MedicineBottle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 52, height: 52)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(medicineName)
                    .font(LoginDesignSystem.Typography.lexendMedium(size: 20))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(providerName)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 16))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("AppViewTextColor").opacity(1))
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Medication detail header") {
    MedicationDetailHeaderView(medicineName: "Dolo650", providerName: "Dr. Ramesh G")
        .padding()
        .background(Color.white)
}
#endif
