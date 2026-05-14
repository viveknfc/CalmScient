//
// Vivek
// Date: May 14, 2026
//
//  PatientProfileEditView.swift
//  Calmscient
//
//  SwiftUI patient profile edit screen (name, read-only email/phone, password card, submit).
//

import SwiftUI

@available(iOS 16.0, *)
struct PatientProfileEditView: View {
    @ObservedObject var viewModel: PatientProfileEditViewModel

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                ProfileEditNavigationBarView(
                    title: AppHelper.getLocalizeString(str: "Profile"),
                    onBack: { viewModel.dismissScreen() }
                )

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        ProfileEditEditableField(
                            title: NSLocalizedString("First Name", comment: ""),
                            placeholder: NSLocalizedString("First Name", comment: ""),
                            text: $viewModel.firstName,
                            forbiddenCharacters: "<>/"
                        )

                        ProfileEditEditableField(
                            title: NSLocalizedString("Last Name", comment: ""),
                            placeholder: NSLocalizedString("Last Name", comment: ""),
                            text: $viewModel.lastName,
                            forbiddenCharacters: "<>/"
                        )

                        ProfileEditReadOnlyField(
                            title: NSLocalizedString("Email", comment: ""),
                            value: viewModel.email
                        )

                        ProfileEditReadOnlyField(
                            title: NSLocalizedString("Phone Number", comment: ""),
                            value: viewModel.phoneDisplay
                        )

                        ProfileEditPasswordSectionView(viewModel: viewModel)
                            .padding(.top, 8)

                        ProfileEditSubmitButton(
                            title: NSLocalizedString("Submit", comment: ""),
                            isEnabled: !viewModel.isSubmittingProfile && !viewModel.isLoadingProfile,
                            action: { viewModel.submitProfile() }
                        )
                        .padding(.top, 8)
                        .padding(.bottom, 28)
                    }
                    .padding(.horizontal, 22)
                }
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .onAppear { viewModel.onAppear() }
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview {
    PatientProfileEditView(viewModel: PatientProfileEditViewModel())
}
#endif
