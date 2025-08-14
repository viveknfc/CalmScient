//
//  EndPointType.swift
//  NetworkLayer
//
//

import Foundation

protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders { get }
}

protocol EndPointRequest:AnyObject {
    var baseURL: String { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var requestBody: [String:Any] { get }
    var headers: HTTPHeaders { get }
    func getURLRequest() -> URLRequest?
}

extension EndPointRequest {
    func getURLRequest() -> URLRequest? {
        
        guard let url = URL(string: "\(baseURL)\(path)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = self.httpMethod.rawValue
        
        for keyValuePair in self.headers {
            request.setValue(keyValuePair.value, forHTTPHeaderField: keyValuePair.key)
        }
        
        if !self.requestBody.isEmpty {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            } catch {
                return nil
            }
        }
        
        return request
    }
    
    var headers: HTTPHeaders {
        return ["Content-Type":"application/json", "Authorization":"Bearer \(ApplicationSharedInfo.shared.tokenResponse?.accessToken ?? "")"]
    }
}
