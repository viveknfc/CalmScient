//
//  HomeRoute.swift
//  Calmscient
//
//  Destinations for the SwiftUI Home tab `NavigationStack`.
//
//  As with `ExercisesRoute`, every Home view model keeps its UIKit push/pop as the
//  fallback and only uses the route closures when they are set. That keeps the
//  screens working from the tabs that are still UIKit (Discovery pushes into
//  Screenings, Need To Talk and the web viewer).
//

import Foundation
import SwiftUI

// MARK: - Reference payload box

/// Carries a reference-type payload inside a `Hashable` navigation route without
/// forcing the model itself to adopt `Hashable`.
///
/// `MedicineDetails`, `MedicalAppointmentDetailsByDate` and `AddEditMedicationViewModel`
/// are all classes that the pushing view model has already built, so identity is the
/// correct notion of equality here — two routes are the same destination only when
/// they carry the very same object.
struct RouteBox<T: AnyObject>: Hashable {
    let value: T

    init(_ value: T) { self.value = value }

    static func == (lhs: RouteBox<T>, rhs: RouteBox<T>) -> Bool {
        lhs.value === rhs.value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(value))
    }
}

// MARK: - HealthMetric hashing

/// `HealthMetric` is `Identifiable` + `Equatable` with a stable `String` id, so it can
/// travel in a route directly once it hashes on that id.
extension HealthMetric: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Routes

enum HomeRoute: Hashable {

    // Dashboard level

    /// Only reachable when Medications is the tab root (`isInitalView`, set when the
    /// mood screen is submitted with the medication flag). The legacy stack "went home"
    /// by pushing a fresh `HomeDashboardHostingController`; this is that screen.
    case homeDashboard
    case userProfile
    case userMedicalRecords
    case weeklySummaryDashboard
    case healthMetrics
    case needToTalk
    case dayFeedback(hideSkipButton: Bool, dashboardNavigationTitle: String)
    case favoritesWeb(urlString: String, title: String)
    case exercise(ExercisesRoute)

    // Medical records branch
    case userMedications
    case nextAppointments
    case screeningList

    // Medications
    case addEditMedication(RouteBox<AddEditMedicationViewModel>)
    case medicationsDetail(RouteBox<MedicineDetails>)

    // Appointments
    case addNewAppointment
    case editAppointment(RouteBox<MedicalAppointmentDetailsByDate>)
    case appointmentDetails(RouteBox<MedicalAppointmentDetailsByDate>)

    // Screenings
    //
    // The legacy hosting controllers were configured after construction
    // (`configure(selectedScreening:…)`), and questions carried an
    // `onSubmissionSuccess` closure through to the result screen. A route cannot carry a
    // closure, so the payload and the two provenance flags travel here instead and the
    // questions destination appends `.screeningResult` itself.
    case screeningQuestions(RouteBox<Screening>, fromParticular: Bool, fromParticular1: Bool)
    case screeningResult(RouteBox<Screening>, fromParticular: Bool, fromParticular1: Bool)
    case screeningHistory(RouteBox<Screening>)

    // Weekly summary / journal / course work
    //
    // The dashboard row fans out to three different screens, so the decision happens in
    // `WeeklySummaryDashboardViewModel.openRow` (as `WeeklySummaryDashboardNavigation`
    // used to do) rather than inside a single destination.
    case weeklySummaryGraph(WeeklySummaryItems)
    case journalEntry
    case progressOnCourseWork
    /// `PatientCourseWorkItem` is already `Hashable`, so the payload travels by value.
    case progressOnCourseWorkDetail(courses: [PatientCourseWorkItem], selectedIndex: Int)

    // Profile
    case patientProfileEdit
    case profilePrivacy
    // NOTE: alarm settings is *presented* as a bottom sheet (with detents + a dimming
    // view), not pushed — so it stays a `present()` call and is deliberately not a route.

    // Health kit
    case healthMetricDetail(HealthMetric)
    /// "Search" in the calendar popup -> wearable data for every day of the range.
    case healthDataRange(startDate: Date, endDate: Date)

    // Shared with Discovery (kept as routes so Home can reach them natively)
    case takingControlIndex(initialSegment: Int)
    case takingControlIntroSecond
}
