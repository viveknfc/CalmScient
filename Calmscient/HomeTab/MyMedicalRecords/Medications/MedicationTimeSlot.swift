//
//  MedicationTimeSlot.swift
//  Calmscient
//
//  Shared day-part filter for medications list (UIKit cell + SwiftUI).
//

import Foundation

enum TimeSlot: Int, CaseIterable, Identifiable {
    case morning
    case afternoon
    case evening

    var id: Int { rawValue }
}
