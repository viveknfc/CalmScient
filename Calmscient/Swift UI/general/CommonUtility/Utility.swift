//
//  Utility.swift
//  MentalHealth
//
//  Created by KA on 16/02/24.
//

import Foundation

class Utility {
    
    // Shared instance
    static let shared = Utility()
    
    // Private initializer to prevent creating multiple instances
    private init() {}
    
    func getLocaleIdentifier() -> String {
        let name = PatientLanguagePreference.normalizedDisplayName(PatientLanguagePreference.currentDisplayName())
        switch name {
        case "spanish":
            return "es_ES"
        case "japanese":
            return "ja_JP"
        default:
            return "en_US_POSIX"
        }
    }
}

