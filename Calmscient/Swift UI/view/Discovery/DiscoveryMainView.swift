//
//  DiscoveryMainView.swift
//  Calmscient
//
//  SwiftUI Discovery hub (three course cards).
//
//  Vivek
//  19 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct DiscoveryMainView: View {

    @ObservedObject var viewModel: DiscoveryMainViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.rows) { row in
                    UserMedicalRecordsRecordCardView(
                        title: row.title,
                        imageName: row.imageName,
                        onTap: { viewModel.openRow(at: row.id) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(LoginDesignSystem.ColorName.pageBackground.ignoresSafeArea())
        // Loading is shown by the app-wide toast activity indicator that the view model
        // drives (`showToastActivity` / `hideToastActivity`). A second SwiftUI
        // `ProgressView` overlay here would render a differently styled spinner on top
        // of it, so it is intentionally not used.
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Discovery main") {
    DiscoveryMainView(viewModel: DiscoveryMainViewModel())
}
#endif
