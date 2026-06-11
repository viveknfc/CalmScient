//
//  LoginDesignSystem.swift
//  Calmscient
//
//  Centralized colors and typography for SwiftUI login (matches new login spec).
//
//  Vivek
//  14 May 2026
//
import SwiftUI

enum LoginDesignSystem {

    enum ColorName {
        static let navy = Color(red: 0.12, green: 0.16, blue: 0.35)
        static let coral = Color(red: 0.95, green: 0.45, blue: 0.42)
        static let purple = Color(red: 0.45, green: 0.32, blue: 0.75)
        static let purpleDeep = Color(red: 0.35, green: 0.22, blue: 0.62)
        static let linkBlue = Color(red: 0.2, green: 0.45, blue: 0.85)
        static let fieldBorder = Color(red: 0.88, green: 0.88, blue: 0.9)
        static let titleGray = Color(red: 0.35, green: 0.35, blue: 0.38)
        static let placeholderGray = Color(red: 0.65, green: 0.65, blue: 0.68)
        static let footerGray = Color(red: 0.45, green: 0.45, blue: 0.48)
        static let lavenderWave = Color(red: 0.93, green: 0.9, blue: 0.98)
        static let pageBackground = Color.white
        static let loginGradient = LinearGradient(
            colors: [
                Color(hex: "#6D6BB3"),
                Color(hex: "#2C3349")
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        static let primaryGradientTop = Color(hex: "#6D6BB3")
        static let borderGray = Color(hex: "#2C3349")
    }

    enum Typography {
        private static let fonts = Fonts()

        static func lexendLight(size: CGFloat) -> Font {
            Font.custom(fonts.lexendLight, size: size)
        }

        static func lexendMedium(size: CGFloat) -> Font {
            Font.custom(fonts.lexendMedium, size: size)
        }

        static func lexendSemiBold(size: CGFloat) -> Font {
            Font.custom(fonts.lexendSemiBold, size: size)
        }

        static func lexendBold(size: CGFloat) -> Font {
            Font.custom(fonts.lexendBold, size: size)
        }
        
        static func lexendRegular(size: CGFloat) -> Font {
            Font.custom(fonts.lexendRegular, size: size)
        }
    }
}
