//
//  UserProfileView.swift
//  Calmscient
//
//  SwiftUI settings screen (replaces storyboard table layout).
//
//  Vivek
//  14 May 2026
//
import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: UserProfileViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                UserProfileHeaderView(
                    profileImage: viewModel.profileImage,
                    versionText: viewModel.versionLabelText,
                    onGalleryTap: { viewModel.presentPhotoOptions() }
                )

                VStack(spacing: 0) {
                    ForEach(Array(viewModel.cellTitles.enumerated()), id: \.offset) { index, title in
                        rowView(index: index, title: title)
                        if index < viewModel.cellTitles.count - 1 {
                            Divider().padding(.leading, 56)
                        }
                    }
                }
                .padding(.top, 16)
            }
        }
        .refreshable { await viewModel.refresh() }
        .background(Color(UIColor.systemBackground))
        .onAppear { viewModel.onAppear() }
    }

    @ViewBuilder
    private func rowView(index: Int, title: String) -> some View {
        let asset = viewModel.rowAssetName(at: index)
        if index == 1 {
            UserProfileLanguageRowView(
                title: title,
                assetName: asset,
                languages: viewModel.languagesData,
                onSelect: { viewModel.selectLanguage(languageName: $0) }
            )
        } else if index == viewModel.cellTitles.count - 1 {
            Button {
                viewModel.handleRowTap(at: index)
            } label: {
                UserProfileLogoutRowView(title: title, assetName: asset)
            }
            .buttonStyle(.plain)
        } else {
            Button {
                viewModel.handleRowTap(at: index)
            } label: {
                UserProfileDefaultRowView(title: title, assetName: asset)
            }
            .buttonStyle(.plain)
        }
    }
}

#if DEBUG
#Preview("User profile (settings)") {
    NavigationView {
        UserProfileView(viewModel: UserProfileViewModel())
    }
}
#endif
