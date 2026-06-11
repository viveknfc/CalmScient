//
//  VersionCheckModels.swift
//  Calmscient
//
//  Decodable types for splash screen version validation API.
//
//  Vivek
//  27 May 2026
//
import Foundation

struct VersionResponse: Decodable {
    let flexibleVersion: String
    let mandatoryVersion: String
    let status: Status
    let mandatoryUpdate: Bool
    let flexibleUpdate: Bool
}

struct Status: Decodable {
    let responseCode: Int
    let responseMessage: String
}
