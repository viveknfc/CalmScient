//
//  WearableHealthService.swift
//  Calmscient
//
//  Fetches the cross-platform wearable health payload from the backend and
//  decodes it into the shared `WearableHealthResponse` schema — the same shape
//  the Android (Health Connect) client posts. One decoder, both platforms.
//
//  12 August 2026
//

import Foundation

@available(iOS 16.0, *)
enum WearableHealthService {

    enum ServiceError: LocalizedError {
        case notLoggedIn
        case invalidURL
        case invalidResponse
        case http(Int)

        var errorDescription: String? {
            switch self {
            case .notLoggedIn:     return "No logged-in patient / access token."
            case .invalidURL:      return "Could not build the wearable-data URL."
            case .invalidResponse: return "Unexpected response from the server."
            case .http(let code):  return "Server returned HTTP \(code)."
            }
        }
    }

    private static var endpoint: String { APIService.BaseUrl + APIService.WearableData }

    /// GETs the wearable day for `patientId` on `date` and returns the best
    /// matching `WearableHealthDay` (or nil when the server has no data).
    ///
    /// Mirrors `getRequestWithToken`'s auth (Bearer) and "url" parameter
    /// placement, but stays `async` and strongly typed for the SwiftUI screen.
    static func fetch(patientId: Int, date: Date) async throws -> WearableHealthDay? {
        guard let token = ApplicationSharedInfo.shared.tokenResponse?.accessToken else {
            throw ServiceError.notLoggedIn
        }

        let dateString = WearableHealthDay.dayFormatter.string(from: date)
        guard var components = URLComponents(string: endpoint) else {
            throw ServiceError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "patientId", value: String(patientId)),
            URLQueryItem(name: "date", value: dateString)
        ]
        guard let url = components.url else { throw ServiceError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("🌐 [Wearable] GET \(url.absoluteString)")

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw ServiceError.invalidResponse }
        guard http.statusCode == 200 else { throw ServiceError.http(http.statusCode) }

        let decoded = try JSONDecoder().decode(WearableHealthResponse.self, from: data)
        return decoded.day(matching: dateString)
    }
}
