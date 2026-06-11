//
//  MedicationsDetailView.swift
//  Calmscient
//
//  SwiftUI medications detail screen (parity with `MedicationsDetailViewController`).
//

//  Vivek
//  15 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct MedicationsDetailView: View {

    @ObservedObject var viewModel: MedicationsDetailViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                MedicationDetailHeaderView(
                    medicineName: viewModel.medicineTitle,
                    providerName: viewModel.providerTitle
                )

                MedicationDetailToolbarView(
                    onEdit: { viewModel.openEditMedication() },
                    onDelete: { viewModel.confirmDeleteMedication() }
                )

                MedicationDetailDosageDirectionCardView(
                    dosageLabel: "Dosage".localized,
                    directionLabel: "Direction".localized,
                    dosageText: viewModel.dosageValue,
                    directionsText: viewModel.directionsValue
                )
                .padding(.horizontal, 16)
                .padding(.top, 15)

                Text(viewModel.scheduleSectionTitle)
                    .font(LoginDesignSystem.Typography.lexendRegular(size: 18))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 16)
                    .padding(.top, 32)
                    .padding(.bottom, 8)

                if viewModel.scheduleRows.isEmpty {
                    Text("No Records Found")
                        .font(LoginDesignSystem.Typography.lexendRegular(size: 16))
                        .foregroundStyle(LoginDesignSystem.ColorName.footerGray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.scheduleRows) { row in
                            MedicationDetailScheduleRowView(row: row)
                        }
                    }
                    .padding(.horizontal, 16)
                }

                Spacer(minLength: 24)
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

#if DEBUG
@available(iOS 16.0, *)
private enum MedicationsDetailPreviewData {
    static let json = """
    {
      "date": "05/14/2026",
      "medicationDetailsByDate": [
        {
          "medicineName": "Test",
          "numberOfTablets": 1,
          "dosageTime": [],
          "medicalDetails": {
            "medicationId": 1,
            "medicineName": "Test",
            "medicineDosage": "200",
            "providerName": "test2",
            "prescriptionID": 99,
            "providerId": 1,
            "directions": "test nn",
            "scheduledTimeList": [
            {
              "scheduledTimes": [
                {
                  "medicineTime": "08:00:00",
                  "alarmTime": "2026-05-14 08:00:00",
                  "alarmId": 1,
                  "pmtId": "101",
                  "medicineTaken": "0",
                  "alarmEnabled": "1",
                  "alarmInterval": "05",
                  "repeat": ["Mon"],
                  "isDefault": 0
                }
              ]
            },
            {
              "scheduledTimes": [
                {
                  "medicineTime": "14:00:00",
                  "alarmTime": "2026-05-14 14:00:00",
                  "alarmId": 2,
                  "pmtId": "102",
                  "medicineTaken": "0",
                  "alarmEnabled": "1",
                  "alarmInterval": "05",
                  "repeat": ["Mon"],
                  "isDefault": 0
                }
              ]
            }
          ],
            "withMeal": 0,
            "endDate": "12/31/2026",
            "expired": 0
          }
        }
      ]
    }
    """

    @MainActor static func makeViewModel() -> MedicationsDetailViewModel {
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        do {
            let md = try decoder.decode(MedicineDetails.self, from: data)
            return MedicationsDetailViewModel(medicineDetails: md)
        } catch {
            fatalError("Preview JSON decode failed: \(error)")
        }
    }
}

@available(iOS 16.0, *)
#Preview("Medications detail screen") {
    MedicationsDetailView(viewModel: MedicationsDetailPreviewData.makeViewModel())
}
#endif
