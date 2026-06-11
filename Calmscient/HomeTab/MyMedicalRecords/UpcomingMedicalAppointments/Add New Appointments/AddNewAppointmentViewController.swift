//
//  AddNewAppointmentViewController.swift
//  Calmscient
//
//  Storyboard shell that embeds `AddNewAppointmentHostingController` (SwiftUI).
//
//  Vivek
//  15 May 2026
//

import UIKit

final class AddNewAppointmentViewController: ViewController {

    var forEditMedicalAppointmentsData: MedicalAppointmentDetailsByDate?
    var EditVc: Bool?

    private var appointmentHost: AddNewAppointmentHostingController?

    override func viewDidLoad() {
        super.viewDidLoad()
        installSwiftUIAppointmentHost()
    }

    private func installSwiftUIAppointmentHost() {
        view.subviews.forEach { $0.removeFromSuperview() }

        let isEdit = EditVc ?? false
        let host = AddNewAppointmentHostingController(
            isEditMode: isEdit,
            editPayload: forEditMedicalAppointmentsData
        )
        appointmentHost = host
        addChild(host)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        host.didMove(toParent: self)
    }
}
