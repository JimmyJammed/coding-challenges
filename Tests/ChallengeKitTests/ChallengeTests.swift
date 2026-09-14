import Foundation
import Testing
@testable import ChallengeKit
@Test func englishVowels() {
    #expect(VowelCounter.count("AEIOU aeiou") == 10)
    #expect(VowelCounter.count("rhythm é è ö 🦉") == 0)
    #expect(VowelCounter.count("") == 0)
}
@Test func URLParsing() throws {
    #expect(try URLValidator.parse("example.com").absoluteString == "https://example.com")
    for invalid in ["", "https://", "not a url", "https://user:pass@example.com", "ftp://example.com"] {
        #expect(throws: URLValidationError.self) { _ = try URLValidator.parse(invalid) }
    }
}
struct Checker: URLChecking {
    let code: Int
    func status(for request: URLRequest) async throws -> Int {
        #expect(request.httpMethod == "HEAD")
        #expect(request.timeoutInterval == 10)
        return code
    }
}
@Test func URLResponsesAndCancellation() async throws {
    let rejected = try await URLValidator.check("example.com", using: Checker(code: 405))
    #expect(!rejected.isAvailable && rejected.description.contains("HEAD"))
    #expect(try await URLValidator.check("example.com", using: Checker(code: 200)).isAvailable)
    let task = Task { withUnsafeCurrentTask { $0?.cancel() }; return try await URLValidator.check("example.com", using: Checker(code: 200)) }
    await #expect(throws: CancellationError.self) { _ = try await task.value }
}
@Test func persistence() async throws {
    let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: folder) }
    let store = SubmissionStore(url: folder.appendingPathComponent("history.json"))
    #expect(try await store.load().isEmpty)
    _ = try await store.append("Hello")
    #expect(try await store.load().first?.count == 2)
    try await store.clear()
    #expect(try await store.load().isEmpty)
}
@Test func articlesAreOfflineAndUnique() async throws {
    let values = try await SampleArticleLoader().articles()
    #expect(values.count == 3 && Set(values.map(\.id)).count == 3)
}
