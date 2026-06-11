//
//  ScreeningRowPresentation.swift
//  Calmscient
//
//  Row model for the screenings list (parity with legacy `ScreeningUpdatedCell`).
//
//  Vivek
//  15 May 2026
//

import Foundation

@available(iOS 16.0, *)
struct ScreeningRowPresentation: Identifiable {
    let screening: Screening

    var id: Int { screening.screeningID }

    var title: String { screening.screeningType }

    var description: String { screening.screeningReminder ?? "" }

    var iconURLString: String { screening.iconUrl }

    var showsViewHistory: Bool { screening.archiveFlag > 0 }
}

#if DEBUG
@available(iOS 16.0, *)
enum ScreeningRowPresentationPreviewData {
    static func sample(
        type: String = "PHQ-9",
        reminder: String = "Evaluates symptoms of depression over the past two weeks.",
        archiveFlag: Int = 1
    ) -> ScreeningRowPresentation? {
        let json = """
        {
          "startDate": null,
          "score": 0,
          "completionDate": null,
          "plid": 1,
          "patientID": 1,
          "screeningID": 1,
          "screeningType": "\(type)",
          "assessmentID": 1,
          "archiveFlag": \(archiveFlag),
          "clientID": 1,
          "iconUrl": "",
          "screeningStatus": "pending",
          "screeningReminder": "\(reminder)"
        }
        """
        guard let data = json.data(using: .utf8),
              let screening = try? JSONDecoder().decode(Screening.self, from: data) else {
            return nil
        }
        return ScreeningRowPresentation(screening: screening)
    }
}
#endif
