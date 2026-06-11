//
//  UserMedicalRecordsView.swift
//  Calmscient
//
//  SwiftUI hub for medications, appointments, and screenings.
//
//  Vivek
//  14 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
struct UserMedicalRecordsView: View {

    @ObservedObject var viewModel: UserMedicalRecordsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(Array(viewModel.rows.enumerated()), id: \.offset) { index, row in
                    UserMedicalRecordsRecordCardView(
                        title: row.title,
                        imageName: row.imageName,
                        onTap: { viewModel.openRow(at: index) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(LoginDesignSystem.ColorName.pageBackground.ignoresSafeArea())
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Medical records screen") {
    UserMedicalRecordsView(viewModel: UserMedicalRecordsViewModel())
}
#endif
