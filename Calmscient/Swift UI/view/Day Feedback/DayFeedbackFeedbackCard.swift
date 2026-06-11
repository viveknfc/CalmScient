//
//  DayFeedbackFeedbackCard.swift
//  Calmscient
//
//  Shared white card chrome for day-feedback sections.
//
//  Vivek
//  14 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct DayFeedbackFeedbackCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color("AppViewBorderColor").opacity(0.9), lineWidth: 1)
            )
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Feedback Card Container") {
    DayFeedbackFeedbackCard {
        VStack(alignment: .leading, spacing: 8) {
            Text("Card title")
                .font(.headline)
            Text("Card content preview")
                .font(.subheadline)
        }
    }
    .padding()
    .background(Color(red: 0.96, green: 0.96, blue: 0.97))
}
#endif
