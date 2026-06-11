//
//  UserProfileRowViews.swift
//  Calmscient
//
//  Reusable rows for the SwiftUI settings (profile) screen.
//
//  Vivek
//  14 May 2026
//
import SwiftUI

struct UserProfileDefaultRowView: View {
    let title: String
    let assetName: String

    var body: some View {
        HStack(spacing: 12) {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            Text(title)
                .font(.custom(Fonts().lexendRegular, size: 14))
                .foregroundColor(Color.primary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .contentShape(Rectangle())
    }
}

struct UserProfileLogoutRowView: View {
    let title: String
    let assetName: String

    var body: some View {
        HStack(spacing: 12) {
            Image(assetName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
            Text(title)
                .font(.custom(Fonts().lexendRegular, size: 14))
                .foregroundColor(Color.primary)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .contentShape(Rectangle())
    }
}

struct UserProfileLanguageRowView: View {
    let title: String
    let assetName: String
    let languages: [[String: Any]]
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                Text(title)
                    .font(.custom(Fonts().lexendRegular, size: 14))
                    .foregroundColor(Color.primary)
                Spacer(minLength: 0)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 10) {
                    ForEach(languageOptions) { option in
                        UserProfileLanguageChipView(item: option.dictionary) { languageName in
                            onSelect(languageName)
                        }
                    }
                }
                .padding(.trailing, 8)
            }
            .frame(height: 104)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(minHeight: 132)
    }

    private var languageOptions: [UserProfileLanguageOption] {
        languages.compactMap { dict in
            guard let name = dict["languageName"] as? String,
                  !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
            let id = dict["languageId"] as? Int ?? name.hashValue
            return UserProfileLanguageOption(id: id, dictionary: dict)
        }
    }
}

private struct UserProfileLanguageOption: Identifiable {
    let id: Int
    let dictionary: [String: Any]
}

private struct UserProfileLanguageChipView: View {
    let item: [String: Any]
    let onTap: (String) -> Void

    private var name: String { (item["languageName"] as? String) ?? "" }
    private var displayName: String {
        switch name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "english":
            return "profile_language_english".localized
        case "spanish":
            return "profile_language_spanish".localized
        case "japanese":
            return "profile_language_japanese".localized
        case "asl":
            return "profile_language_asl".localized
        default:
            return name
        }
    }
    private var preferred: Bool { (item["preferred"] as? Int) == 1 }
    private var flagURL: URL? {
        guard let s = item["flagUrl"] as? String else { return nil }
        return URL(string: s)
    }

    var body: some View {
        Button(action: {
            let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                onTap(trimmed)
            }
        }) {
            VStack(spacing: 8) {
                flagContent
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
                    )

                Text(displayName)
                    .font(.custom(Fonts().lexendRegular, size: 10))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .foregroundColor(chipForeground)
            }
            .frame(minWidth: 45, maxWidth: 55)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(chipBackground)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var flagContent: some View {
        if let flagURL {
            AsyncImage(url: flagURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    flagPlaceholder
                default:
                    Color.gray.opacity(0.15)
                }
            }
        } else {
            flagPlaceholder
        }
    }

    private var flagPlaceholder: some View {
        ZStack {
            Color.gray.opacity(0.12)
            Text(shortLabel)
                .font(.custom(Fonts().lexendMedium, size: 11))
                .foregroundColor(.secondary)
        }
    }

    private var shortLabel: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.uppercased() == "ASL" { return "ASL" }
        return String(trimmed.prefix(2)).uppercased()
    }

    private var chipBackground: Color {
        if preferred {
            return Color("AppBorderColor")
        }
        return Color("profileCellSeperaionColor")
    }

    private var chipForeground: Color {
        if preferred {
            return .white
        }
        return Color.primary
    }
}

#if DEBUG
#Preview("Default row") {
    UserProfileDefaultRowView(title: "Profile", assetName: "profile_svg")
    .padding()
    .background(Color(UIColor.systemBackground))
}

#Preview("Logout row") {
    UserProfileLogoutRowView(title: "Logout", assetName: "logout_svg")
    .padding()
    .background(Color(UIColor.systemBackground))
}

#Preview("Language row") {
    let sampleLangs: [[String: Any]] = [
        ["languageId": 1, "languageName": "English", "preferred": 1, "flagUrl": ""],
        ["languageId": 2, "languageName": "Spanish", "preferred": 0, "flagUrl": ""],
        ["languageId": 6, "languageName": "Japanese", "preferred": 0, "flagUrl": ""],
        ["languageId": 7, "languageName": "ASL", "preferred": 0, "flagUrl": ""],
    ]
    UserProfileLanguageRowView(
        title: "Language",
        assetName: "language_svg",
        languages: sampleLangs,
        onSelect: { _ in }
    )
    .padding(.vertical)
    .background(Color(UIColor.systemBackground))
}
#endif
