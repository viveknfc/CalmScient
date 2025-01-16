//
//  Language.swift
//  CalmscientIOS
//
//  Created by NFC User on 24/12/24.
//

import Foundation

extension Bundle {
    private static var onceToken: Void = {
        object_setClass(Bundle.main, LanguageBundle.self)
    }()
    
    static func setLanguage(_ language: String) {
        defer { _ = Bundle.onceToken }
        objc_setAssociatedObject(Bundle.main, &associatedLanguageKey, Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj")!)!, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private var associatedLanguageKey: UInt8 = 0

private class LanguageBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let bundle = objc_getAssociatedObject(self, &associatedLanguageKey) as? Bundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}
