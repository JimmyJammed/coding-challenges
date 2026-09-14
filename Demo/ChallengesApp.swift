import SwiftUI
import WebKit
import ChallengeKit
@main struct ChallengesApp: App { var body: some Scene { WindowGroup { ChallengesView() } } }
struct ChallengesView: View {
    @State private var tab = ProcessInfo.processInfo.arguments.contains("--preview-urls") ? 1 : (ProcessInfo.processInfo.arguments.contains("--preview-vowels") ? 2 : 0)
    var body: some View {
        TabView(selection: $tab) {
            ArticlesView().tabItem { Label("Articles", systemImage: "newspaper") }.tag(0)
            URLView().tabItem { Label("URLs", systemImage: "link") }.tag(1)
            VowelsView().tabItem { Label("Vowels", systemImage: "textformat.abc") }.tag(2)
        }
    }
}
struct ArticlesView: View {
    @State private var articles: [Article] = []
    @State private var search = ""
    @State private var error = ""
    @State private var loading = false
    var body: some View {
        NavigationStack {
            List {
                if loading { ProgressView("Loading articles") }
                if !error.isEmpty { Text(error) }
                if !loading && articles.isEmpty { ContentUnavailableView("No articles", systemImage: "newspaper") }
                ForEach(articles.filter { search.isEmpty || $0.title.localizedCaseInsensitiveContains(search) }) { article in
                    NavigationLink {
                        VStack(alignment: .leading) {
                            Text(article.title).font(.title.bold()).padding()
                            ArticleWebView(article: article)
                        }.toolbar { ShareLink(item: article.title + "\n" + article.body) }
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(article.title).font(.headline)
                            Text(article.summary).foregroundStyle(.secondary)
                        }.padding(.vertical, 10)
                    }
                }
            }.navigationTitle("Field Notes").searchable(text: $search)
                .task { await load() }.refreshable { await load() }
        }
    }
    private func load() async {
        loading = true
        defer { loading = false }
        do { articles = try await SampleArticleLoader().articles(); error = "" }
        catch { self.error = String(describing: error) }
    }
}
struct ArticleWebView: UIViewRepresentable {
    let article: Article
    func makeUIView(context: Context) -> WKWebView {
        let web = WKWebView(); web.isOpaque = false; web.backgroundColor = .clear
        return web
    }
    func updateUIView(_ web: WKWebView, context: Context) {
        guard context.coordinator.id != article.id else { return }
        context.coordinator.id = article.id
        let safe = article.body.replacingOccurrences(of: "&", with: "&amp;").replacingOccurrences(of: "<", with: "&lt;").replacingOccurrences(of: ">", with: "&gt;")
        web.loadHTMLString("<meta name='viewport' content='width=device-width, initial-scale=1'><style>:root{color-scheme:light dark}body{font:-apple-system-body;margin:24px;line-height:1.6}</style><p>\(safe)</p>", baseURL: nil)
    }
    func makeCoordinator() -> Coordinator { Coordinator() }
    final class Coordinator { var id: String? }
    static func dismantleUIView(_ web: WKWebView, coordinator: Coordinator) { web.stopLoading(); web.navigationDelegate = nil }
}
struct DemoChecker: URLChecking {
    func status(for request: URLRequest) async throws -> Int { 200 }
}
struct URLView: View {
    @State private var input = "example.com"
    @State private var result = ""
    @State private var live = false
    @State private var task: Task<Void, Never>?
    var body: some View {
        NavigationStack {
            Form {
                TextField("URL", text: $input).textInputAutocapitalization(.never).autocorrectionDisabled()
                Toggle("Check live network", isOn: $live)
                Text("Offline mode validates syntax and uses a simulated HTTP response.").font(.footnote)
                Button("Validate") {
                    task?.cancel()
                    task = Task {
                        do {
                            let value = try await URLValidator.check(input, using: live ? NetworkURLChecker() : DemoChecker())
                            result = value.url.absoluteString + "\n" + value.description
                        } catch is CancellationError { }
                        catch { result = String(describing: error) }
                    }
                }
                Button("Cancel") { task?.cancel() }
                Text(result).accessibilityIdentifier("url-result")
            }.navigationTitle("URL Validator").onDisappear { task?.cancel() }
        }
    }
}
struct VowelsView: View {
    @State private var text = "Hello, world!"
    @State private var history: [Submission] = []
    @State private var error = ""
    private let store = SubmissionStore(url: URL.applicationSupportDirectory.appendingPathComponent("ChallengeKit/history.json"))
    var body: some View {
        NavigationStack {
            Form {
                TextField("Text to count", text: $text, axis: .vertical).accessibilityIdentifier("vowel-input")
                Text("\(VowelCounter.count(text)) vowels").font(.title).accessibilityIdentifier("vowel-count")
                Text("Counts English a, e, i, o, u. Accented characters and y are excluded.").font(.caption)
                Button("Save result") { Task { do { history = try await store.append(text) } catch { self.error = String(describing: error) } } }
                if !error.isEmpty { Text(error) }
                Section("History") {
                    ForEach(history) { value in VStack(alignment: .leading) { Text(value.text); Text("\(value.count) vowels").font(.caption) } }
                    Button("Clear history", role: .destructive) { Task { do { try await store.clear(); history = [] } catch { self.error = String(describing: error) } } }
                }
            }.navigationTitle("Vowel Counter").task { do { history = try await store.load() } catch { self.error = String(describing: error) } }
        }
    }
}
