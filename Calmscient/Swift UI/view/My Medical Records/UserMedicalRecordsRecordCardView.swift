//
//  UserMedicalRecordsRecordCardView.swift
//  Calmscient
//
//  Full-bleed image card with bottom title strip (medical records categories).
//
//  Vivek
//  14 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct UserMedicalRecordsRecordCardView: View {

    let title: String
    let imageName: String
    let onTap: () -> Void

    private let cardHeight: CGFloat = 172
    private let corner: CGFloat = 14

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottom) {
                Group {
                    if let ui = UIImage(named: imageName) {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal, 12)
                    } else {
                        Rectangle()
                            .fill(Color(red: 0.9, green: 0.9, blue: 0.92))
                            .padding(.horizontal, 12)
                    }
                }
                .frame(height: cardHeight)
                .frame(maxWidth: .infinity)
                .clipped()

                LinearGradient(
                    colors: [
                        Color.black.opacity(0.0),
                        Color.black.opacity(0.78),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0.42),
                    endPoint: .bottom
                )
                
                .frame(height: cardHeight)
                .allowsHitTesting(false)

                HStack(alignment: .center) {
                    Text(title)
                        .font(LoginDesignSystem.Typography.lexendRegular(size: 16))
                        .foregroundStyle(Color.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)
            }
            .frame(height: cardHeight)
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Medications card") {
    UserMedicalRecordsRecordCardView(
        title: "Medications",
        imageName: "Medications_Cell",
        onTap: {}
    )
    .padding(.horizontal, 20)
    .background(LoginDesignSystem.ColorName.pageBackground)
}

@available(iOS 16.0, *)
#Preview("Appointments card") {
    UserMedicalRecordsRecordCardView(
        title: "Upcoming medical appointments",
        imageName: "MedicalAppointment_Cell",
        onTap: {}
    )
    .padding(.horizontal, 20)
    .background(LoginDesignSystem.ColorName.pageBackground)
}

@available(iOS 16.0, *)
#Preview("Screenings card") {
    UserMedicalRecordsRecordCardView(
        title: "Screenings",
        imageName: "Screening_Cell",
        onTap: {}
    )
    .padding(.horizontal, 20)
    .background(LoginDesignSystem.ColorName.pageBackground)
}
#endif
