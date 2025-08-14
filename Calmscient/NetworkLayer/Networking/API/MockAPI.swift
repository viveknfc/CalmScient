//
//  MockAPI.swift
//  NetworkLayer
//
//  
//  
//

import Foundation

enum MockAPI {
    case getBranch(branchID: Int)
    case getBranches(partnerID: Int)
}

extension MockAPI: EndPointType {
 
    
    var baseURL: URL {
        URL(string: "https://run.mocky.io")!
    }

    var path: String {
        switch self {
        case .getBranch:
            return "v3/92a1a70b-ffa6-4bfe-8fb6-e4cf650f5d24"
        case .getBranches:
            return "v3/1837cced-d96e-4d83-a792-6dc74ecfb454"
        }
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .getBranch,
             .getBranches:
            return .get
        }
    }

    var task: HTTPTask {
        switch self {
        case .getBranch(let branchID):
            return .requestParameters(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: ["branch_id": branchID])
        case .getBranches(let partnerID):
            return .requestParameters(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: ["partner_id": partnerID])
        }
    }

    var headers: HTTPHeaders {
        switch self {
        case .getBranch,
             .getBranches:
            return [:]
        }
    }
}
