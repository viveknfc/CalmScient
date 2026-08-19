//
//  MedicationsDetailViewModel.swift
//  Calmscient
//
//  State and navigation parity with legacy `MedicationsDetailViewController`.
//

//  Vivek
//  15 May 2026
//
import Foundation
import SwiftUI
import UIKit

@available(iOS 16.0, *)
@MainActor
final class MedicationsDetailViewModel: ObservableObject {

    weak var hostViewController: UIViewController?

    // MARK: - SwiftUI navigation
    //
    // Set by `HomeTabView` when this screen is shown inside the Home `NavigationStack`.
    // While nil, every call below falls through to the existing UIKit push/pop, which is
    // what the still-UIKit Discovery tab uses when it pushes into these screens.
    var onOpenRoute: ((HomeRoute) -> Void)?
    var onClose: (() -> Void)?
    var onCloseToRoot: (() -> Void)?

    private(set) var medicineDetails: MedicineDetails

    @Published private(set) var medicineTitle: String = ""
    @Published private(set) var providerTitle: String = ""
    @Published private(set) var dosageValue: String = ""
    @Published private(set) var directionsValue: String = ""
    @Published private(set) var scheduleRows: [MedicationDetailScheduleRowPresentation] = []

    @Published private(set) var scheduleSectionTitle: String = "Schedule Time & Alarm".localized

    /// Falls back to the key window so this screen still shows toasts when it is
    /// presented without a `hostViewController` (SwiftUI-navigated Home tab).
    private var anchorView: UIView? { Toast.resolvedAnchor(hostViewController?.view) }

    init(medicineDetails: MedicineDetails) {
        self.medicineDetails = medicineDetails
        recomputeDisplay()
    }

    func onHostWillAppear() {
        recomputeDisplay()
    }

    func recomputeDisplay() {
        guard let details = medicineDetails.medicationDetailsByDate.first?.medicalDetails else {
            medicineTitle = ""
            providerTitle = ""
            dosageValue = ""
            directionsValue = ""
            scheduleRows = []
            return
        }

        medicineTitle = details.medicineName
        providerTitle = details.providerName ?? ""
        dosageValue = details.medicineDosage
        directionsValue = details.directions

        let filtered = details.scheduledTimeList.filter { schedule in
            schedule.scheduledTimes.contains { $0.isDefault == 0 }
        }
        let sorted = filtered.sorted {
            ($0.scheduledTimes.first?.medicineTime ?? "") < ($1.scheduledTimes.first?.medicineTime ?? "")
        }
        scheduleRows = sorted.compactMap { MedicationDetailScheduleRowPresentation.build(from: $0) }
    }

    func openEditMedication() {
        let vm = AddEditMedicationViewModel(
            isEditMode: true,
            medicationData: medicineDetails,
            refreshControlClosure: { [weak self] _ in
                self?.recomputeDisplay()
            }
        )
        if let onOpenRoute {
            onOpenRoute(.addEditMedication(RouteBox(vm)))
            return
        }
        guard let nav = hostViewController?.navigationController else { return }
        let vc = AddEditMedicationHostingController(viewModel: vm)
        vc.title = "Edit medications"
        nav.pushViewController(vc, animated: true)
    }

    func confirmDeleteMedication() {
        let alert = UIAlertController(
            title: AppHelper.getLocalizeString(str: "Confirm Deletion"),
            message: AppHelper.getLocalizeString(str: "Are you sure you want to delete this medication?"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: AppHelper.getLocalizeString(str: "No"), style: .cancel))
        alert.addAction(UIAlertAction(title: AppHelper.getLocalizeString(str: "Yes"), style: .destructive) { [weak self] _ in
            self?.deleteMedication()
        })
        if let cancel = alert.actions.first(where: { $0.title == AppHelper.getLocalizeString(str: "No") }) {
            cancel.setValue(#colorLiteral(red: 0.431, green: 0.420, blue: 0.702, alpha: 1), forKey: "titleTextColor")
        }
        hostViewController?.present(alert, animated: true)
    }

    private func deleteMedication() {
        guard let prescriptionID = medicineDetails.medicationDetailsByDate.first?.medicalDetails.prescriptionID else { return }
        let params: [String: Int] = ["prescriptionID": prescriptionID]
        guard let host = hostViewController else { return }

        anchorView?.showToastActivity()
        APIService.deletMedicationAPICalling(
            host,
            params: params,
            method: "POST",
            accessToken: ApplicationSharedInfo.shared.tokenResponse!.accessToken,
            acces: false,
            parameterPlacement: "body"
        ) { [weak self] response in
            Task { @MainActor in
                self?.handleDeleteMedicationResponse(response)
            }
        }
    }

    private func handleDeleteMedicationResponse(_ response: AnyObject) {
        anchorView?.hideToastActivity()

        if let responseString = response as? String {
            print("Response received from delete Medication API calling is", responseString)
            return
        }

        if let responseDict = response as? [String: Any],
           let responseMessage = responseDict["responseMessage"] as? String {
            print("Response Message:", responseMessage)
            anchorView?.showToast(message: responseMessage)
            if let onClose {
            onClose()
            return
        }
        hostViewController?.navigationController?.popViewController(animated: true)
        } else {
            print("Response Message not found or is not a string.")
        }
    }
}
