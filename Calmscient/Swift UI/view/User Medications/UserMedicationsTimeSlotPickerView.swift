//
//  UserMedicationsTimeSlotPickerView.swift
//  Calmscient
//
//  Morning / afternoon / evening control (matches segmented look from reference UI).
//
//  Vivek
//  14 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct UserMedicationsTimeSlotPickerView: View {

    @Binding var selection: TimeSlot

    private let brandPurple = LoginDesignSystem.ColorName.primaryGradientTop
    private let trackGrey = Color(red: 0.96, green: 0.96, blue: 0.97)

    /// Where the title sits inside its third of the bar (Morning leading, Afternoon center, Evening trailing).
    private enum SlotTitleBias {
        case leading, center, trailing

        var frameAlignment: Alignment {
            switch self {
            case .leading: return .leading
            case .center: return .center
            case .trailing: return .trailing
            }
        }

        var textAlignment: TextAlignment {
            switch self {
            case .leading: return .leading
            case .center: return .center
            case .trailing: return .trailing
            }
        }
    }

    var body: some View {
        HStack(spacing: 0) {
            // Fixed LTR: Morning (leading) → Afternoon (center) → Evening (trailing), regardless of app layout direction.
            segmentButton(.morning, title: "Morning".localized, titleBias: .leading)
            segmentButton(.afternoon, title: "Afternoon".localized, titleBias: .center)
            segmentButton(.evening, title: "Evening".localized, titleBias: .trailing)
        }
        .frame(maxWidth: .infinity)
        .padding(4)
        .background(trackGrey)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color(red: 0.93, green: 0.93, blue: 0.94), lineWidth: 1)
        )
        .environment(\.layoutDirection, .leftToRight)
    }

    @ViewBuilder
    private func segmentButton(_ slot: TimeSlot, title: String, titleBias: SlotTitleBias) -> some View {
        let isOn = selection == slot
        Button {
            selection = slot
        } label: {
            Text(title)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 12))
                .foregroundStyle(isOn ? Color.white : brandPurple)
                .multilineTextAlignment(titleBias.textAlignment)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: titleBias.frameAlignment)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(
                    Group {
                        if isOn {
                            Capsule()
                                .fill(brandPurple)
                        } else {
                            Color.clear
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Time slot picker") {
    struct Holder: View {
        @State private var slot = TimeSlot.morning
        var body: some View {
            UserMedicationsTimeSlotPickerView(selection: $slot)
                .padding()
        }
    }
    return Holder()
}
#endif
