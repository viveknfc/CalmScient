//
//  UserMedicationsBottomDateStripView.swift
//  Calmscient
//
//  Medications calendar header — uses shared `MedicalCalendarHeaderView`.
//
//  Vivek
//  14 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
typealias UserMedicationsCalendarHeaderView = MedicalCalendarHeaderView<UserMedicationsViewModel>

#if DEBUG
@available(iOS 16.0, *)
#Preview("Calendar header") {
    UserMedicationsCalendarHeaderView(provider: UserMedicationsViewModel())
}
#endif
