//
//  ProgressOnCourseWorkCardStyle.swift
//  Calmscient
//
//  Shared card shadow styling for progress on course work screens.
//
//  Vivek
//  18 May 2026
//

import SwiftUI

@available(iOS 16.0, *)
extension View {
    func progressOnCourseWorkCardShadow() -> some View {
        shadow(color: Color("AppViewShadowColor").opacity(0.6), radius: 2, x: 0, y: 1)
    }
}
