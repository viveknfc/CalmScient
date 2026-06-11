//
//  ScreeningResultPresentation.swift
//  Calmscient
//
//  Presentation model for screening results (parity with legacy `ScreeningResultVC`).
//
//  Vivek
//  15 May 2026
//

import Foundation

@available(iOS 16.0, *)
struct ScreeningResultPresentation {
    let screeningName: String
    let score: Int
    let totalScore: Int
    let testDateText: String
    let testTimeText: String

    var progress: Double {
        guard totalScore > 0 else { return 0 }
        return min(max(Double(score) / Double(totalScore), 0), 1)
    }

    init(results: ScreeningSuccessResults) {
        screeningName = results.screeningName
        score = results.score
        totalScore = results.total

        let parsed = Self.parseScreeningDate(results.screeningDate)
        testDateText = parsed.date
        testTimeText = parsed.time
    }

    private static func parseScreeningDate(_ raw: String) -> (date: String, time: String) {
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd HH:mm:ss"
        input.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())

        guard let date = input.date(from: raw) else {
            return ("", "")
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())

        return (dateFormatter.string(from: date), timeFormatter.string(from: date))
    }
}

#if DEBUG
@available(iOS 16.0, *)
enum ScreeningResultPresentationPreviewData {
    static func sample(
        screeningName: String = "PHQ-9",
        score: Int = 14,
        total: Int = 30,
        screeningDate: String = "2026-05-15 17:52:00"
    ) -> ScreeningResultPresentation? {
        let json = """
        {
          "patientID": 1,
          "firstName": "Preview",
          "lastName": "User",
          "patientAccountNumber": "1",
          "screeningName": "\(screeningName)",
          "screeningId": 1,
          "screeningDate": "\(screeningDate)",
          "score": \(score),
          "total": \(total),
          "averageResult": null,
          "screeningReminder": "Weekly",
          "assessmentId": 1
        }
        """
        guard let data = json.data(using: .utf8),
              let results = try? JSONDecoder().decode(ScreeningSuccessResults.self, from: data) else {
            return nil
        }
        return ScreeningResultPresentation(results: results)
    }
}
#endif
