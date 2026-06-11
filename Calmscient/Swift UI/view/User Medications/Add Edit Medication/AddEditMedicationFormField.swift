//
//  AddEditMedicationFormField.swift
//  Calmscient
//
//  Shared focus identity for add / edit medication form fields.
//

//  Vivek
//  15 May 2026
//
import SwiftUI

enum AddEditMedicationFormField: Hashable {
    case medication
    case provider
    case dosage
    case direction
}

#if DEBUG
#Preview("Form field — cases (documentation)") {
    VStack(alignment: .leading, spacing: 8) {
        Text("AddEditMedicationFormField")
            .font(.caption)
            .foregroundStyle(.secondary)
        Text(String(describing: AddEditMedicationFormField.medication))
        Text(String(describing: AddEditMedicationFormField.direction))
    }
    .padding()
}
#endif
