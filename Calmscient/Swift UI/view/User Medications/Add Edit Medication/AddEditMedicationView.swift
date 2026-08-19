//
//  AddEditMedicationView.swift
//  Calmscient
//
//  Composes add / edit medication subviews (`Add Edit Medication` folder).
//

//  Vivek
//  15 May 2026
//
import SwiftUI

struct AddEditMedicationView: View {

    @ObservedObject var viewModel: AddEditMedicationViewModel
    @FocusState private var focusedField: AddEditMedicationFormField?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                AddEditMedicationLabeledTextField(
                    title: AppHelper.getLocalizeString(str: "Medication"),
                    text: viewModel.bindingForMedicationField(maxLength: 2000, allowAngleBrackets: false),
                    field: .medication,
                    showCounter: false,
                    focusedField: $focusedField
                )

                AddEditMedicationLabeledTextField(
                    title: AppHelper.getLocalizeString(str: "Provider"),
                    text: viewModel.bindingForProviderField(maxLength: 2000, allowAngleBrackets: false),
                    field: .provider,
                    showCounter: false,
                    focusedField: $focusedField
                )

                AddEditMedicationLabeledTextField(
                    title: AppHelper.getLocalizeString(str: "Dosage"),
                    text: viewModel.bindingForDosageField(maxLength: 2000, allowAngleBrackets: false),
                    field: .dosage,
                    showCounter: false,
                    focusedField: $focusedField
                )

                AddEditMedicationDirectionField(
                    direction: viewModel.bindingForDirectionField(),
                    focusedField: $focusedField
                )

                AddEditMedicationWithMealRow(withMeal: $viewModel.withMeal)

                AddEditMedicationExpiryRow(
                    dateDisplay: viewModel.expiryDateMMddYYYY,
                    onTap: {
                        focusedField = nil
                        viewModel.openExpiryPicker()
                    }
                )

                AddEditMedicationScheduleSectionView(
                    sectionTitle: viewModel.scheduleSectionTitle,
                    slotAlarmsVersion: viewModel.slotAlarmsVersion,
                    rowAt: { viewModel.rowPresentation(at: $0) },
                    onRowTap: { index in
                        focusedField = nil
                        viewModel.openTimeAndAlarmSheet(forSlotIndex: index)
                    },
                    onToggleSlot: { index in
                        let row = viewModel.rowPresentation(at: index)
                        viewModel.setSlotScheduled(!row.isSlotScheduled, slotIndex: index)
                    },
                    onToggleAlarm: { index in
                        let row = viewModel.rowPresentation(at: index)
                        viewModel.setAlarmEnabled(!row.alarmEnabled, slotIndex: index)
                    }
                )

                AddEditMedicationSaveCancelBar(
                    onCancel: {
                        focusedField = nil
                        viewModel.confirmCancelEditing()
                    },
                    onSave: {
                        focusedField = nil
                        viewModel.saveIfValid()
                    }
                )
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
        }
        .background(Color("AppBackGroundColor").ignoresSafeArea())
        // Replaces the host's `UITapGestureRecognizer` (which used
        // `cancelsTouchesInView = false`); `simultaneousGesture` likewise lets taps
        // still reach buttons and fields underneath.
        .simultaneousGesture(TapGesture().onEnded { focusedField = nil })
        .scrollDismissesKeyboard(.interactively)
    }
}

#if DEBUG
#Preview("Add medication — full form") {
    NavigationView {
        AddEditMedicationView(
            viewModel: AddEditMedicationViewModel(isEditMode: false, medicationData: nil, refreshControlClosure: nil)
        )
    }
}
#endif
