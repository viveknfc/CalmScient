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

// MARK: - APILogger

/// Console-only tracer for every outgoing API call in the app.
///
/// Prints the complete absolute URL — query string included, exactly as the server
/// receives it — the HTTP method, and the parameters that were sent with it.
///
/// Debug builds only. In a Release build `isEnabled` is `false`, so nothing is ever
/// printed on a shipped device and no patient data reaches Console.app.
///
/// This type is deliberately inert. It only calls `print`: it never mutates the
/// `URLRequest`, never throws, never returns a value anyone acts on and never touches
/// a callback or a response. Adding or removing a `logRequest(...)` line therefore
/// cannot change how the app behaves.
enum APILogger {

    // MARK: - Switches

    #if DEBUG
    /// Master switch. Set to `false` to silence the tracer without removing call sites.
    static var isEnabled = true
    #else
    /// Release builds stay silent — no request bodies reach a user's device console.
    static var isEnabled = false
    #endif

    /// Longest parameter dump printed, in characters. Stops a large payload
    /// (e.g. screening answers) from flooding the console.
    static var maxParameterLength = 6000

    // MARK: - Logging

    /// Logs one outgoing API call.
    ///
    /// - Parameters:
    ///   - request:   The request about to be sent. The URL is read from here, so
    ///                `"url"`-placement query parameters show up in the printed URL.
    ///   - params:    The parameter dictionary the caller passed in. Pass `nil` to let
    ///                the logger decode `request.httpBody` instead.
    ///   - placement: `"url"`, `"body"` or `"header"` — where the params were put.
    ///   - label:     Optional caller name, useful when one URL is hit from two paths.
    static func logRequest(
        _ request: URLRequest?,
        params: Any? = nil,
        placement: String? = nil,
        label: String? = nil
    ) {
        guard isEnabled else { return }

        let method = request?.httpMethod ?? "?"
        let absoluteURL = request?.url?.absoluteString ?? "<invalid URL>"

        var lines: [String] = []
        lines.append("")
        lines.append("┌───────────────── API CALL ─────────────────")
        if let label = label, !label.isEmpty {
            lines.append("│ Caller    : \(label)")
        }
        lines.append("│ \(method) \(absoluteURL)")
        if let placement = placement, !placement.isEmpty {
            lines.append("│ Params in : \(placement)")
        }
        lines.append("│ Params    :")
        lines.append(prefixEveryLine(of: parameterDescription(params: params, request: request)))
        lines.append("└────────────────────────────────────────────")

        // One `print` for the whole block: concurrent calls stay readable instead of
        // interleaving line by line.
        print(lines.joined(separator: "\n"))
    }

    // MARK: - Formatting helpers

    private static func parameterDescription(params: Any?, request: URLRequest?) -> String {
        if let params = params {
            if let dictionary = params as? [String: Any] {
                guard !dictionary.isEmpty else { return "(none)" }
                return prettyJSON(from: dictionary) ?? plainDescription(of: dictionary)
            }
            return truncated(String(describing: params))
        }

        guard let body = request?.httpBody, !body.isEmpty else {
            // No body, so any parameters are query items already visible in the URL
            // above. Repeat them broken out, which is easier to scan than a raw query.
            let queryItems = URLComponents(string: request?.url?.absoluteString ?? "")?.queryItems
            if let queryItems = queryItems, !queryItems.isEmpty {
                return queryItems
                    .map { "\($0.name) = \($0.value ?? "")" }
                    .joined(separator: "\n")
            }
            return "(none)"
        }

        // A multipart body holds raw image bytes — print its size, not its contents.
        let contentType = request?.value(forHTTPHeaderField: "Content-Type") ?? ""
        if contentType.localizedCaseInsensitiveContains("multipart") {
            return "<multipart form data, \(body.count) bytes>"
        }

        if let object = try? JSONSerialization.jsonObject(with: body, options: .allowFragments),
           let pretty = prettyJSON(from: object) {
            return pretty
        }
        return truncated(String(data: body, encoding: .utf8) ?? "<\(body.count) bytes, not UTF-8>")
    }

    private static func prettyJSON(from object: Any) -> String? {
        guard JSONSerialization.isValidJSONObject(object) else { return nil }
        guard let data = try? JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys]
        ), let text = String(data: data, encoding: .utf8) else {
            return nil
        }
        return truncated(text)
    }

    /// Fallback for a dictionary JSON cannot serialise (a `Date`, a custom object…).
    private static func plainDescription(of dictionary: [String: Any]) -> String {
        truncated(
            dictionary.keys.sorted()
                .map { "\($0) = \(dictionary[$0] ?? "")" }
                .joined(separator: "\n")
        )
    }

    private static func truncated(_ text: String) -> String {
        guard text.count > maxParameterLength else { return text }
        return String(text.prefix(maxParameterLength))
            + "\n… truncated (\(text.count) characters total)"
    }

    private static func prefixEveryLine(of text: String) -> String {
        text.split(separator: "\n", omittingEmptySubsequences: false)
            .map { "│   \($0)" }
            .joined(separator: "\n")
    }
}
