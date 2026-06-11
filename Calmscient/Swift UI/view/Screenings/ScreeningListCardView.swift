//
//  ScreeningListCardView.swift
//  Calmscient
//
//  Single screening card with icon, copy, and action buttons.
//
//  Vivek
//  15 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct ScreeningListCardView: View {

    let title: String
    let description: String
    let iconURLString: String
    let showsViewHistory: Bool
    let viewHistoryTitle: String
    let takeScreeningTitle: String
    let onViewHistory: () -> Void
    let onTakeScreening: () -> Void

    private let brandPurple = Color(red: 0.464, green: 0.506, blue: 0.755)
    private let lightPurpleBackground = Color(red: 0.903, green: 0.901, blue: 0.945)
    private let descriptionGray = Color(red: 0.33, green: 0.33, blue: 0.33)
    private let cardBorder = Color(red: 0.90, green: 0.90, blue: 0.92)

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 20) {
                screeningIcon
                    .frame(width: 60, height: 60)

                VStack(alignment: .leading, spacing: 0) {
                    Text(title)
                        .font(LoginDesignSystem.Typography.lexendMedium(size: 16))
                        .foregroundStyle(brandPurple)
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(description)
                        .font(LoginDesignSystem.Typography.lexendMedium(size: 14))
                        .foregroundStyle(descriptionGray)
                        .multilineTextAlignment(.leading)
                        .padding(.top, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(lightPurpleBackground)
            )

            HStack(spacing: 10) {
                if showsViewHistory {
                    outlineButton(title: viewHistoryTitle, action: onViewHistory)
                }

                filledButton(title: takeScreeningTitle, action: onTakeScreening)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(cardBorder, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var screeningIcon: some View {
        if let url = URL(string: iconURLString), !iconURLString.isEmpty {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                case .failure, .empty:
                    placeholderIcon
                @unknown default:
                    placeholderIcon
                }
            }
        } else {
            placeholderIcon
        }
    }

    private var placeholderIcon: some View {
        Image("placeholder")
            .resizable()
            .scaledToFit()
    }

    private func outlineButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 14))
                .foregroundStyle(brandPurple)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(brandPurple, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func filledButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 14))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(brandPurple)
                )
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Screening card with history") {
    ScreeningListCardView(
        title: "PHQ-9",
        description: "Evaluates symptoms of depression over the past two weeks.",
        iconURLString: "",
        showsViewHistory: true,
        viewHistoryTitle: "View history",
        takeScreeningTitle: "Take the screening",
        onViewHistory: {},
        onTakeScreening: {}
    )
    .padding()
}

@available(iOS 16.0, *)
#Preview("Screening card without history") {
    ScreeningListCardView(
        title: "GAD-7",
        description: "Measures symptoms of anxiety over the past two weeks.",
        iconURLString: "",
        showsViewHistory: false,
        viewHistoryTitle: "View history",
        takeScreeningTitle: "Take the screening",
        onViewHistory: {},
        onTakeScreening: {}
    )
    .padding()
}
#endif
