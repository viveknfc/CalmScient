//
//  HTTPMethod.swift
//  NetworkLayer
//
//

import Foundation

enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

enum NetworkResponseError: Error {
    case authenticationError
    case badRequest
    case outdated
    case failed
    case noData
    case unableToDecode
    case httpURLResponseCastFailed
    case noInternet
    
    var localizedDescription: String {
        switch self {
        case .authenticationError: return "You need to be authenticated first."
        case .badRequest: return "Bad request."
        case .outdated: return "The url you requested is outdated."
        case .failed: return "Network request failed."
        case .noData: return "Response returned with no data to decode."
        case .unableToDecode: return "We could not decode the response."
        case .httpURLResponseCastFailed: return "HTTP url response cast failed."
        case .noInternet: return "No Internet available. Please try again later."
        }
    }
}
