//
//  AppHelper.swift
//  LocalizationDemo
//
//  Created by Krishna on 24/06/19.
//  Copyright © 2019 Krishna. All rights reserved.
//

import UIKit

class AppHelper: NSObject {

    static func getLocalizeString(str: String) -> String {
        guard let language = resolvedLanguageCode(),
              let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            // fallback → return the key itself if not found
            return str
        }

        return NSLocalizedString(str, tableName: nil, bundle: bundle, value: "", comment: "")
    }

    private static func resolvedLanguageCode() -> String? {
        if let appLanguage = UserDefaults.standard.string(forKey: "appLanguage"), !appLanguage.isEmpty {
            UserDefaults.standard.set(appLanguage, forKey: "Language")
            return appLanguage
        }

        if let language = UserDefaults.standard.string(forKey: "Language"), !language.isEmpty {
            return language
        }

        let selectedLanguageID = UserDefaults.standard.integer(forKey: "SelectedLanguageID")
        let fallbackLanguage: String
        switch selectedLanguageID {
        case 2:
            fallbackLanguage = "es"
        case 3:
            fallbackLanguage = "ja"
        default:
            fallbackLanguage = "en"
        }
        UserDefaults.standard.set(fallbackLanguage, forKey: "Language")
        return fallbackLanguage
    }
}

