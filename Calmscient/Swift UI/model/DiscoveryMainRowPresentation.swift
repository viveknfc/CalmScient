//
//  DiscoveryMainRowPresentation.swift
//  Calmscient
//
//  Row model for the Discovery hub cards.
//
//  Vivek
//  19 May 2026
//

import Foundation

@available(iOS 16.0, *)
struct DiscoveryMainRowPresentation: Identifiable, Hashable {
    let id: Int
    let title: String
    let imageName: String
}
