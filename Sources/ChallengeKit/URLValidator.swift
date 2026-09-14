import Foundation
public enum URLValidationError: Error { case empty, malformed, unsupportedScheme, nonHTTPResponse }
public struct URLCheck: Sendable {
    public let url: URL
    public let statusCode: Int
    public var isAvailable: Bool { (200..<400).contains(statusCode) }
    public var description: String {
        if statusCode == 405 || statusCode == 501 { return "Server responded, but does not support HEAD (HTTP \(statusCode))." }
        return "Server responded: HTTP \(statusCode)."
    }
}
public protocol URLChecking: Sendable { func status(for request: URLRequest) async throws -> Int }
public struct NetworkURLChecker: URLChecking {
    private let session: URLSession
    public init(session: URLSession = .shared) { self.session = session }
    public func status(for request: URLRequest) async throws -> Int {
        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLValidationError.nonHTTPResponse }
        return http.statusCode
    }
}
public enum URLValidator {
    public static func parse(_ input: String) throws -> URL {
        var value = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { throw URLValidationError.empty }
        guard !value.contains(where: \.isWhitespace) else { throw URLValidationError.malformed }
        if !value.contains("://") { value = "https://" + value }
        guard let parts = URLComponents(string: value), let host = parts.host, !host.isEmpty,
              parts.user == nil, parts.password == nil, let url = parts.url else { throw URLValidationError.malformed }
        guard ["https", "http"].contains(parts.scheme?.lowercased() ?? "") else { throw URLValidationError.unsupportedScheme }
        return url
    }
    public static func check(_ input: String, using checker: any URLChecking = NetworkURLChecker()) async throws -> URLCheck {
        let url = try parse(input)
        try Task.checkCancellation()
        var request = URLRequest(url: url, timeoutInterval: 10)
        request.httpMethod = "HEAD"
        let status = try await checker.status(for: request)
        try Task.checkCancellation()
        return URLCheck(url: url, statusCode: status)
    }
}
