//
//  NetworkLogger.swift
//  NetworkLayer
//
//

import Foundation

final class NetworkLogger {
    static func log(request: URLRequest) {
        print("\n - - - - - - - - - - OUTGOING - - - - - - - - - - \n")
        defer { print(" - - - - - - - - - -  END - - - - - - - - - - \n") }
        
        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: urlAsString)

        let method = request.httpMethod ?? ""
        let path = urlComponents?.path ?? ""
        let query = urlComponents?.query ?? ""
        let host = urlComponents?.host ?? ""

        var logOutput = """
                        \(urlAsString) \n
                        \(method) \(path)?\(query) HTTP/1.1 \n
                        HOST: \(host)\n
                        """
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            logOutput += "\(key): \(value) \n"
        }
        if let body = request.httpBody {
            logOutput += "\n \(NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "")"
        }
        print(logOutput)
    }

    static func log(response: Data?) {
        
        print("\n - - - - - - - - - - INCOMING RESPONSE - - - - - - - - - - \n")
        defer { print(" - - - - - - - - - -  END - - - - - - - - - - \n") }
        guard let responseData = response else {
            return
        }
        var logOutput = """
            """
        let jsonData =  String(data: responseData, encoding: .utf8)
        logOutput += "\n \(jsonData ?? "NOT FOUND")"
        print("viv log output from here",logOutput)
    }
}
