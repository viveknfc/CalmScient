//
//  DayFeedbackSelectionLayout.swift
//  Calmscient
//
//  Shared layout constants for mood / time-spend icon rows.
//
//  Vivek
//  14 May 2026
//
import SwiftUI

@available(iOS 16.0, *)
enum DayFeedbackSelectionLayout {
    /// Single-line caption under each icon so every column keeps emojis on one horizontal line.
    static let captionLineHeight: CGFloat = 14
    /// Fixed row height so every emoji sits on the same baseline regardless of selection scale.
    static let iconSlotHeight: CGFloat = 56
}
