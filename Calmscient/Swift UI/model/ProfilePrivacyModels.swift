//
//  ProfilePrivacyModels.swift
//  Calmscient
//
//  Vivek
//  14 May 2026
//
//  Patient consent rows for the profile privacy sheet (`getPatientPrivacy` / `updatePatientConsent`).
//

import Foundation

struct PatientPrivacyConsentItem: Identifiable, Equatable {
    let consentListId: Int
    let consentListName: String
    var consentFlag: Int

    var id: Int { consentListId }

    var isConsentGranted: Bool { consentFlag == 1 }
}
