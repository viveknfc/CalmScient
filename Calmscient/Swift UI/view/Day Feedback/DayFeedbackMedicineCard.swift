//
//  DayFeedbackMedicineCard.swift
//  Calmscient
//
//  Medication question + 3-option segmented choice in one card.
//
//  Vivek
//  14 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct DayFeedbackMedicineCard: View {
    @ObservedObject var viewModel: UserIntroDayFeedbackViewModel

    var body: some View {
        DayFeedbackFeedbackCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(medicineQuestionText())
                    .font(LoginDesignSystem.Typography.lexendMedium(size: 16))
                    .foregroundStyle(LoginDesignSystem.ColorName.titleGray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 12) {
                    medicineButton(title: "Yes", value: "3")
                    medicineButton(title: "No", value: "1")
                    medicineButton(title: "Not yet", value: "2")
                }
//                .padding(.top, 16)
            }
        }
    }

    private func medicineQuestionText() -> String {
        UserDefaults.standard.bool(forKey: "Morning")
            ? AppHelper.getLocalizeString(str: "Did_you_take_your_meds_this_morning")
            : AppHelper.getLocalizeString(str: "Did_you_take_your_meds")
    }

    private func medicineButton(title: String, value: String) -> some View {
        let selected = viewModel.medicineSelectionValue == value
        return Button {
            viewModel.setMedicineSelection(value)
        } label: {
            Text(AppHelper.getLocalizeString(str: title))
                .font(LoginDesignSystem.Typography.lexendRegular(size: 14))
                .foregroundStyle(selected ? Color.white : LoginDesignSystem.ColorName.footerGray)
                .frame(maxWidth: .infinity)
                .frame(height: 28)
                .background(
                    Capsule()
                        .fill(selected ? LoginDesignSystem.ColorName.primaryGradientTop : Color.white)
                )
                .overlay(
                    Capsule()
                        .stroke(LoginDesignSystem.ColorName.footerGray, lineWidth: selected ? 0 : 1.5)
                )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 10)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Medicine Card") {
    let vm = UserIntroDayFeedbackViewModel()
    vm.medicineSelectionValue = "3"
    return DayFeedbackMedicineCard(viewModel: vm)
        .padding()
        .background(Color(red: 0.96, green: 0.96, blue: 0.97))
}
#endif
