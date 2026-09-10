//
//  HomeDashboardMenuCardView.swift
//  Calmscient
//
//  Vivek
//  14 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct HomeDashboardMenuCardView: View {

    let title: String
    let imageName: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.94, green: 0.94, blue: 0.95))
                        .frame(width: 56, height: 56)
                    if let ui = UIImage(named: imageName) {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 52, height: 52)
                    }
                }

                Text(title)
                    .font(LoginDesignSystem.Typography.lexendMedium(size: 16))
                    .foregroundStyle(LoginDesignSystem.ColorName.titleGray)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(LoginDesignSystem.ColorName.purple)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.10), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Home menu card") {
    VStack(spacing: 14) {
        HomeDashboardMenuCardView(
            title: "My medical records",
            imageName: "MyMedicalRecordsIcon",
            onTap: {}
        )
        HomeDashboardMenuCardView(
            title: "Mental wellbeing tracker",
            imageName: "mentalWellbeing",
            onTap: {}
        )
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 16)
    .background(LoginDesignSystem.ColorName.pageBackground)
}
#endif

