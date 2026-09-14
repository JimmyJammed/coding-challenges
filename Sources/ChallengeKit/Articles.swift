import Foundation
public struct Article: Identifiable, Codable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let summary: String
    public let body: String
    public init(id: String, title: String, summary: String, body: String) { self.id = id; self.title = title; self.summary = summary; self.body = body }
}
public protocol ArticleLoading: Sendable { func articles() async throws -> [Article] }
public struct SampleArticleLoader: ArticleLoading {
    public init() {}
    public func articles() async throws -> [Article] {
        try Task.checkCancellation()
        return [
            Article(id: "gardens", title: "A small garden, a shared city", summary: "Neighbors turn a quiet corner into a gathering place.", body: "The first planter arrived on a Saturday. By the end of the month, the corner held herbs, flowers, and a bench built from reclaimed timber. This fictional story is included for offline demonstration."),
            Article(id: "light", title: "Designing with daylight", summary: "Simple observations can reshape a room.", body: "Watch how the light moves before choosing where a chair belongs. Morning and evening can make the same space feel entirely different. This original sample article needs no network service."),
            Article(id: "walk", title: "The long way home", summary: "A familiar route becomes a new discovery.", body: "Taking one unfamiliar turn revealed a bookshop, a mural, and a path beside the water. Original fictional content for the article-browser exercise.")
        ]
    }
}
