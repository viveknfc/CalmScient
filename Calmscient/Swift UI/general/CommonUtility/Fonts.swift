//
//  Fonts.swift
//  HealthApp
//
//  Created by KA on 11/03/24.
//

import Foundation
import UIKit

struct Fonts{
    let lexendBold = "Lexend-Bold"//Bold 700
    let lexendLight = "Lexend-Light"//Light 300
    let lexendRegular = "Lexend-Regular"//Regular 400
    let lexendMedium = "Lexend-Medium"//Medium 500
    let lexendSemiBold = "Lexend-SemiBold"//SemiBold 600
}


// MARK: - Convenience API (additive; existing Fonts()/FontXX usages unchanged)
extension UIFont {
    enum Lexend {
        case light, regular, medium, semiBold, bold
        var fontName: String {
            switch self {
            case .light:    return "Lexend-Light"
            case .regular:  return "Lexend-Regular"
            case .medium:   return "Lexend-Medium"
            case .semiBold: return "Lexend-SemiBold"
            case .bold:     return "Lexend-Bold"
            }
        }
    }

    /// Lexend font at the given weight/size, falling back to the system font if unavailable.
    static func lexend(_ weight: Lexend, _ size: CGFloat) -> UIFont {
        UIFont(name: weight.fontName, size: size) ?? .systemFont(ofSize: size)
    }
}
