//
//  BreathingTechniqueView.swift
//  Calmscient
//
//  SwiftUI breathing technique index (parity with legacy `BreathingTechnique`).
//
//  Vivek
//  20 May 2026
//

import SwiftUI

struct BreathingTechniqueView: View {

    @ObservedObject var viewModel: BreathingTechniqueViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                BreathingTechniqueHeroImageView(imageName: viewModel.heroImageName)

                Text(viewModel.sectionTitle)
                    .font(LoginDesignSystem.Typography.lexendMedium(size: 18))
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                VStack(spacing: 17) {
                    ForEach(viewModel.exerciseRows) { row in
                        BreathingTechniqueExerciseCardView(title: row.title) {
                            viewModel.openExercise(at: row.id)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 17)
                .padding(.bottom, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground).ignoresSafeArea())
    }
}

#if DEBUG
#Preview("Breathing technique") {
    let viewModel = BreathingTechniqueViewModel()
    viewModel.applyPreviewState()
    return BreathingTechniqueView(viewModel: viewModel)
}
#endif
