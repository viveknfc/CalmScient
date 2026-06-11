//
//  MedicationDetailToolbarView.swift
//  Calmscient
//
//  Edit / delete icon row (parity with legacy `MedicationsDetailViewController` buttons).
//

//  Vivek
//  15 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
struct MedicationDetailToolbarView: View {
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Spacer(minLength: 0)
            Button(action: onEdit) {
                Image("editIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)

            Button(action: onDelete) {
                Image("deleteIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
            .padding(.leading, 15)
            .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 15)
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(Color.white)
    }
}

#if DEBUG
@available(iOS 16.0, *)
#Preview("Medication detail toolbar") {
    MedicationDetailToolbarView(onEdit: {}, onDelete: {})
}
#endif
