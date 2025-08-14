//
//  ThemeManager.swift
//  CalmscientIOS
//
//  Created by NFC User on 23/12/24.
//

import Foundation
import UIKit

enum Theme {
    case light
    case dark
}

struct ThemeManager {
    static var currentTheme: Theme = .light

    static var backgroundColor: UIColor {
        switch currentTheme {
        case .light: return .white
        case .dark: return .black
        }
    }

    static var textColor: UIColor {
        switch currentTheme {
        case .light: return .black
        case .dark: return .white
        }
    }
}
