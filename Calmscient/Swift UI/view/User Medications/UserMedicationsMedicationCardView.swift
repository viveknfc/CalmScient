//
//  UserMedicationsMedicationCardView.swift
//  Calmscient
//
//  Single medication row: dose for the selected day-part tab only + Edit/Delete menu.
//
//  Vivek
//  14 May 2026
//

import SwiftUI
import UIKit

@available(iOS 16.0, *)
struct UserMedicationsMedicationCardView: View {

    let title: String
    let subtitle: String
    /// Which tab is selected (morning / afternoon / evening); only this slot’s time is shown.
    let selectedTimeSlot: TimeSlot
    /// Dose UI for `selectedTimeSlot` only (`nil` if no dose in that window).
    let dosePresentation: UserMedicationsDosePresentation?
    let isExpired: Bool
    let onRowTap: () -> Void
    let onToggleDose: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    private let brandPurple = LoginDesignSystem.ColorName.primaryGradientTop
    private let subtitlePurple = Color(red: 0.42, green: 0.40, blue: 0.62)
    private let titleDark = LoginDesignSystem.ColorName.titleGray

    var body: some View {
        let opacity = isExpired ? 0.45 : 1.0

        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(LoginDesignSystem.Typography.lexendSemiBold(size: 17))
                        .foregroundStyle(titleDark)
                        .multilineTextAlignment(.leading)
                    Text(subtitle)
                        .font(LoginDesignSystem.Typography.lexendLight(size: 14))
                        .foregroundStyle(subtitlePurple)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 8)
                Menu {
                    Button(action: onEdit) {
                        Label("Edit".localized, systemImage: "pencil")
                    }
                    Button(role: .destructive, action: onDelete) {
                        Label("Delete".localized, systemImage: "trash")
                    }
                } label: {
                    Image("seperatorIcon")
                        .frame(width: 24, height: 24)

                }
                .menuStyle(.automatic)
                .opacity(opacity)
            }

            if isExpired {
                Text("Expired".localized)
                    .font(LoginDesignSystem.Typography.lexendLight(size: 12))
                    .foregroundStyle(LoginDesignSystem.ColorName.footerGray)
            }

            if let presentation = dosePresentation {
                HStack(spacing: 0) {
                    switch selectedTimeSlot {
                    case .morning:
                        dosePillButton(presentation: presentation)
                        Spacer(minLength: 0)
                    case .afternoon:
                        Spacer(minLength: 0)
                        dosePillButton(presentation: presentation)
                        Spacer(minLength: 0)
                    case .evening:
                        Spacer(minLength: 0)
                        dosePillButton(presentation: presentation)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isExpired ? Color(red: 0.96, green: 0.96, blue: 0.96) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(red: 0.90, green: 0.90, blue: 0.92), lineWidth: 1)
        )
        .opacity(opacity)
        .contentShape(Rectangle())
        .onTapGesture(perform: onRowTap)
    }

    @ViewBuilder
    private func dosePillButton(presentation: UserMedicationsDosePresentation) -> some View {
        Button(action: onToggleDose) {
            HStack(spacing: 6) {
                Image(systemName: iconName(for: selectedTimeSlot))
                    .font(.system(size: 14, weight: .medium))
                Text(presentation.timeDisplay)
                    .font(LoginDesignSystem.Typography.lexendMedium(size: 13))
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                if presentation.isTaken {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13))
                }
            }
            .foregroundStyle(foreground(for: presentation))
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(background(for: presentation))
            )
            .overlay(
                Capsule()
                    .stroke(border(for: presentation), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!presentation.isInteractive || isExpired)
        .opacity((!presentation.isInteractive || isExpired) ? 0.4 : 1)
    }

    private func iconName(for slot: TimeSlot) -> String {
        switch slot {
        case .morning: return "sunrise.fill"
        case .afternoon: return "sun.max.fill"
        case .evening: return "moon.stars.fill"
        }
    }

    private func foreground(for presentation: UserMedicationsDosePresentation) -> Color {
        if !presentation.isInteractive {
            return .gray
        }
        return presentation.isTaken ? Color(red: 0.93, green: 0.45, blue: 0.45) : brandPurple
    }

    private func border(for presentation: UserMedicationsDosePresentation) -> Color {
        if !presentation.isInteractive {
            return Color.gray.opacity(0.45)
        }
        return presentation.isTaken ? Color(red: 0.93, green: 0.45, blue: 0.45) : brandPurple.opacity(0.85)
    }

    private func background(for presentation: UserMedicationsDosePresentation) -> Color {
        if !presentation.isInteractive {
            return Color(UIColor.lightGray).opacity(0.25)
        }
        if presentation.isTaken {
            return Color(red: 0.98, green: 0.90, blue: 0.90)
        }
        return Color.clear
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Medication card — morning tab") {
    UserMedicationsMedicationCardView(
        title: "Test",
        subtitle: "test nn",
        selectedTimeSlot: .morning,
        dosePresentation: nil,
        isExpired: false,
        onRowTap: {},
        onToggleDose: {},
        onEdit: {},
        onDelete: {}
    )
    .padding()
}
#endif
