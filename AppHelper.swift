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
        guard let language = UserDefaults.standard.string(forKey: "Language"),
              let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            // fallback → return the key itself if not found
            return str
        }

        return NSLocalizedString(str, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}

