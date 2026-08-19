//
//  NeedToTalkRowView.swift
//  Calmscient
//
//  One emergency resource row (parity with `NeedToTalkTableViewCell`).
//
//  Cell parity notes:
//   • title  — `FontLM14` => Lexend-Medium 15 (the class overrides the xib's
//              "system semibold 16"), 16pt leading, 7pt top, 21pt tall.
//   • body   — legacy used a `UITextView` with `dataDetectorTypes = [.link, .phoneNumber]`
//              plus explicit links for 988 / 741741 / 678678. Reproduced here with
//              `NSDataDetector` + explicit overrides on an `AttributedString`, so every
//              crisis contact stays tappable.
//   • button — 138×33, `blueAndDarkBule` fill, 4pt radius, Lexend-SemiBold 14 in
//              `blueAndPink`, `MedicationsCellArrow` trailing, 8pt from the trailing
//              edge and 10pt from the bottom.
//

import SwiftUI

@available(iOS 16.0, *)
struct NeedToTalkRowView: View {

    let row: NeedToTalkRowPresentation
    let onLearnMore: () -> Void

    /// `#colorLiteral(red: 0.431372549, green: 0.4196078431, blue: 0.7019607843, alpha: 1)`
    /// from `linkTextAttributes` — sRGB, deliberately distinct from `blueAndPink`.
    private static let linkColor = Color(
        .sRGB,
        red: 0.431372549,
        green: 0.4196078431,
        blue: 0.7019607843,
        opacity: 1
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text(row.title)
                .font(.custom(Fonts().lexendMedium, size: 15))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(height: 21, alignment: .leading)
                .padding(.top, 7)

            if let content = row.content {
                Text(attributedContent(content))
                    .textSelection(.enabled)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
                    .padding(.trailing, 8)
            } else {
                Text(NeedToTalkPresentation.noContentKey.localized)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 2)
                    .padding(.trailing, 8)
            }

            HStack {
                Spacer(minLength: 0)
                learnMoreButton
            }
            .padding(.trailing, 8)
            .padding(.bottom, 10)
        }
        .padding(.leading, 16)
    }

    private var learnMoreButton: some View {
        Button(action: onLearnMore) {
            HStack(spacing: 0) {
                Text(NeedToTalkPresentation.learnMoreKey.localized)
                    .font(.custom(Fonts().lexendSemiBold, size: 14))
                    .foregroundColor(Color("blueAndPink"))
                    .lineLimit(1)

                Spacer(minLength: 4)

                Image("MedicationsCellArrow")
                    .renderingMode(.original)
            }
            .padding(.horizontal, 12)
            .frame(width: 138, height: 33)
            .background(Color("blueAndDarkBule"))
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Attributed content

    private func attributedContent(_ content: String) -> AttributedString {
        var attributed = AttributedString(content)
        attributed.font = .custom(Fonts().lexendRegular, size: 14)
        attributed.foregroundColor = .black

        func applyLink(nsRange: NSRange, url: URL) {
            guard let stringRange = Range(nsRange, in: content),
                  let lower = AttributedString.Index(stringRange.lowerBound, within: attributed),
                  let upper = AttributedString.Index(stringRange.upperBound, within: attributed)
            else { return }

            let range = lower..<upper
            attributed[range].link = url
            attributed[range].foregroundColor = Self.linkColor
            attributed[range].underlineStyle = .single
        }

        // Parity with `dataDetectorTypes = [.link, .phoneNumber]`.
        let detectorTypes = NSTextCheckingResult.CheckingType.link.rawValue
            | NSTextCheckingResult.CheckingType.phoneNumber.rawValue
        if let detector = try? NSDataDetector(types: detectorTypes) {
            let fullRange = NSRange(location: 0, length: (content as NSString).length)
            detector.enumerateMatches(in: content, options: [], range: fullRange) { match, _, _ in
                guard let match else { return }
                let url: URL?
                if match.resultType == .phoneNumber, let number = match.phoneNumber {
                    url = URL(string: "tel://\(number.filter { $0.isNumber })")
                } else {
                    url = match.url
                }
                if let url {
                    applyLink(nsRange: match.range, url: url)
                }
            }
        }

        // Explicit crisis links win over anything the detector produced.
        for (text, link) in NeedToTalkPresentation.crisisLinks {
            let range = (content as NSString).range(of: text)
            if range.location != NSNotFound, let url = URL(string: link) {
                applyLink(nsRange: range, url: url)
            }
        }

        return attributed
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Resource row") {
    NeedToTalkRowView(
        row: NeedToTalkRowPresentation(
            id: 0,
            title: "988 Suicide & Crisis Lifeline",
            content: "Call or text 988 to reach the Suicide & Crisis Lifeline. You can also text 741741 or 678678 to reach a counselor.",
            learnMoreURL: "https://988lifeline.org"
        ),
        onLearnMore: {}
    )
}
#endif
