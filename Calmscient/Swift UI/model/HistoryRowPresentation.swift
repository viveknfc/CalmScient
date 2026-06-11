//
//  HistoryRowPresentation.swift
//  Calmscient
//
//  Row model for screening history list (parity with legacy `HistoryCell`).
//
//  Vivek
//  15 May 2026
//

import Foundation

@available(iOS 16.0, *)
struct HistoryRowPresentation: Identifiable {
    let id: String
    let dateTimeText: String
    let score: Int
    let totalScore: Int

    var progress: Double {
        guard totalScore > 0 else { return 0 }
        return min(max(Double(score) / Double(totalScore), 0), 1)
    }

    init(history: ScreeningHistory) {
        id = "\(history.completionDateTime)-\(history.score)-\(history.screeningID)"
        dateTimeText = Self.formatCompletionDateTime(history.completionDateTime)
        score = history.score
        totalScore = history.totalScore
    }

    private static func formatCompletionDateTime(_ raw: String) -> String {
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd HH:mm:ss"
        input.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())

        guard let date = input.date(from: raw) else {
            return "Invalid Date"
        }

        let output = DateFormatter()
        output.dateFormat = "MM/dd/yyyy | h:mm a"
        output.locale = Locale(identifier: Utility.shared.getLocaleIdentifier())
        return output.string(from: date)
    }
}

#if DEBUG
@available(iOS 16.0, *)
enum HistoryRowPresentationPreviewData {
    static func sample(
        completionDateTime: String = "2026-05-12 12:35:00",
        score: Int = 25,
        totalScore: Int = 30,
        screeningType: String = "PHQ-9"
    ) -> HistoryRowPresentation? {
        let json = """
        {
          "score": \(score),
          "completionDateTime": "\(completionDateTime)",
          "screeningID": 1,
          "screeningType": "\(screeningType)",
          "assessmentID": 1,
          "totalScore": \(totalScore)
        }
        """
        guard let data = json.data(using: .utf8),
              let history = try? JSONDecoder().decode(ScreeningHistory.self, from: data) else {
            return nil
        }
        return HistoryRowPresentation(history: history)
    }
}
#endif
