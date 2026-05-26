//
//  QuitSymptomModalSectionView.swift
//  Calmscient
//
//  Heading and body pair for ready-to-quit symptom modals.
//
//  Vivek
//  26 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct QuitSymptomModalSectionView: View {

    let heading: String
    let bodyText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            QuitSymptomModalPurpleHeadingView(text: heading)
            QuitSymptomModalBodyTextView(text: bodyText)
        }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Quit symptom section") {
    QuitSymptomModalSectionView(
        heading: "Remind yourself it's normal",
        bodyText: "Feeling grumpy is just your body adjusting to not having nicotine."
    )
    .padding()
}
#endif
