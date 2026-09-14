import Foundation
public enum VowelCounter {
    /// Counts English a/e/i/o/u; accented characters and y are excluded.
    public static func count(_ text: String) -> Int {
        text.lowercased().filter { "aeiou".contains($0) }.count
    }
}
public struct Submission: Identifiable, Codable, Sendable, Equatable {
    public let id: UUID
    public let text: String
    public let count: Int
    public let date: Date
    public init(text: String) { id = UUID(); self.text = text; count = VowelCounter.count(text); date = Date() }
}
public actor SubmissionStore {
    private let url: URL
    public init(url: URL) { self.url = url }
    public func load() throws -> [Submission] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        return try JSONDecoder().decode([Submission].self, from: Data(contentsOf: url))
    }
    public func append(_ text: String) throws -> [Submission] {
        var values = try load(); values.insert(Submission(text: text), at: 0)
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(values).write(to: url, options: .atomic)
        return values
    }
    public func clear() throws {
        if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }
    }
}
