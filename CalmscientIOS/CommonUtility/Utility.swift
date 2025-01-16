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
        let languageID = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        switch languageID {
        case 1:
            return "en_US_POSIX"
        case 2:
            return "es_ES"
        default:
            return "en_US_POSIX"
        }
    }
}

