//
//  UserMedicationsView.swift
//  Calmscient
//
//  SwiftUI medications list (parity with legacy `UserMedicationsViewController`).
//
//  Vivek
//  14 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct UserMedicationsView: View {

    @ObservedObject var viewModel: UserMedicationsViewModel

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                UserMedicationsCalendarHeaderView(provider: viewModel)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        UserMedicationsTimeSlotPickerView(
                            selection: Binding(
                                get: { viewModel.selectedTimeSlot },
                                set: { viewModel.setTimeSlot($0) }
                            )
                        )

                        infoAndTakeAllRow

                        if viewModel.showEmptyState {
                            Text("No Records".localized)
                                .font(LoginDesignSystem.Typography.lexendMedium(size: 18))
                                .foregroundStyle(LoginDesignSystem.ColorName.footerGray)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                        } else {
                            ForEach(viewModel.medicationRows, id: \.userMedicationsRowIdentity) { row in
                                card(for: row)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }

            Button {
                viewModel.openAddMedication()
            } label: {
                Image("AddButton")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 14)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
        // Loading is shown by the app-wide toast activity indicator that the view model
        // drives (`showToastActivity` / `hideToastActivity`). A second SwiftUI
        // `ProgressView` overlay used to be stacked on top of it here, which made two
        // spinners appear at once.
    }

    private var infoAndTakeAllRow: some View {
        HStack(alignment: .center, spacing: 10) {
            Image("InfoIcon")
                .resizable()
                .frame(width: 20, height: 20)
            Text(viewModel.infoBannerText)
                .font(LoginDesignSystem.Typography.lexendLight(size: 12))
                .foregroundStyle(LoginDesignSystem.ColorName.primaryGradientTop)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            takeAllCompactButton
        }
    }

    private var takeAllCompactButton: some View {
        Button {
            viewModel.toggleTakeAllForCurrentSlot()
        } label: {
            Text(viewModel.takeAllTitle)
                .font(LoginDesignSystem.Typography.lexendMedium(size: 12))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .foregroundStyle(viewModel.takeAllUsesTakenStyle ? Color(red: 0.93, green: 0.45, blue: 0.45) : LoginDesignSystem.ColorName.primaryGradientTop)
        .background(
            Capsule()
                .stroke(viewModel.takeAllUsesTakenStyle ? Color(red: 0.93, green: 0.45, blue: 0.45) : LoginDesignSystem.ColorName.primaryGradientTop, lineWidth: 1)
        )
        .opacity(viewModel.takeAllEnabled ? 1 : 0.45)
        .disabled(!viewModel.takeAllEnabled)
        .fixedSize(horizontal: true, vertical: false)
    }

    @ViewBuilder
    private func card(for row: MedicineDetails) -> some View {
        let medical = row.medicationDetailsByDate.first?.medicalDetails
        let expired = medical?.expired == 1
        let title = row.medicationDetailsByDate.first?.medicineName ?? ""
        let subtitle = medical?.directions ?? ""
        let slot = viewModel.selectedTimeSlot
        let dose = UserMedicationsDosePresentation.build(record: row, timeSlot: slot)

        UserMedicationsMedicationCardView(
            title: title,
            subtitle: subtitle,
            selectedTimeSlot: slot,
            dosePresentation: dose,
            isExpired: expired,
            onRowTap: { viewModel.openMedicationDetail(row) },
            onToggleDose: { viewModel.toggleDoseTaken(for: row, timeSlot: slot) },
            onEdit: { viewModel.openEditMedication(row) },
            onDelete: { viewModel.confirmDeleteMedication(row) }
        )
    }
}

@available(iOS 16.0, *)
private extension MedicineDetails {
    var userMedicationsRowIdentity: String {
        let m = medicationDetailsByDate.first?.medicalDetails
        return "\(m?.prescriptionID ?? 0)-\(m?.medicationId ?? 0)"
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Medications screen") {
    UserMedicationsView(viewModel: UserMedicationsViewModel())
}
#endif
