//
//  NetworkHelper.swift
//  NetworkLayer
//

import Foundation

typealias ResultWithError<T> = Result<T, Error>

struct NetworkHelper {
    
    static let shared = NetworkHelper()
    private init() {}

    func handle<T: Decodable>(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ResultWithError<T> {
        
        // 🚫 No Internet check FIRST
        if !NetworkMonitor.shared.isConnected {
            return .failure(NetworkResponseError.noInternet)
        }
        
        
        if let error = error {
            let nsError = error as NSError
            
            if nsError.code == NSURLErrorNotConnectedToInternet ||
               nsError.code == NSURLErrorNetworkConnectionLost {
                return .failure(NetworkResponseError.noInternet)
            }
            
            return .failure(error)
        }

        guard let response = response as? HTTPURLResponse else {
            return .failure(NetworkResponseError.httpURLResponseCastFailed)
        }

        switch handleNetworkResponse(response) {
            
        case .success:
            guard let responseData = data else {
                return .failure(NetworkResponseError.noData)
            }
            
            do {
                let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                print(jsonData)
                
                let apiResponse = try JSONDecoder().decode(T.self, from: responseData)
                return .success(apiResponse)
                
            } catch {
                return .failure(NetworkResponseError.unableToDecode)
            }
            
        case .failure(let error):
            return .failure(error)
        }
    }

    private func handleNetworkResponse(_ response: HTTPURLResponse) -> ResultWithError<Void> {
        
        switch response.statusCode {
        case 200...299: return .success(())
        case 401...500: return .failure(NetworkResponseError.authenticationError)
        case 501...599: return .failure(NetworkResponseError.badRequest)
        case 600: return .failure(NetworkResponseError.outdated)
        default: return .failure(NetworkResponseError.failed)
        }
    }
}



import Network

final class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    private(set) var isConnected: Bool = true
    
    var onStatusChange: ((Bool) -> Void)?
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            
            let connected = path.status == .satisfied
            
            guard self?.isConnected != connected else { return }
            self?.isConnected = connected
            
            print("🌐 Network status changed: \(connected)")
            
            DispatchQueue.main.async {
                self?.onStatusChange?(connected)
                
                NotificationCenter.default.post(
                    name: .networkStatusChanged,
                    object: connected
                )
            }
        }
        
        monitor.start(queue: queue)
    }
}
