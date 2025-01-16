//
//  Array+Extension.swift
//  CalmscientIOS
//
//  Created by NFC on NA.
//

import Foundation

extension Array {
    func convertToJSONStrings<T: Codable>(array: [T]) throws -> [String] {
        let encoder = JSONEncoder()
        
        return try array.map { codableObject in
            let jsonData = try encoder.encode(codableObject)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                throw EncodingError.invalidValue(jsonData, EncodingError.Context(codingPath: [], debugDescription: "Failed to convert data to string."))
            }
            return jsonString
        }
    }
}
