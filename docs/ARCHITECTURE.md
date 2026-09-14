# Architecture

ChallengeKit contains reusable Foundation logic. The SwiftUI demo composes three independent screens, with no vendor dependencies. Article detail renders bundled text in a WKWebView and stops loading during dismantle; there is no required remote website. The article list supports asynchronous refresh and search.

URL parsing runs before a request is constructed. The default demo checker returns a simulated response; explicitly enabling live checks uses URLSession. Cancel ends the view's active task. HTTP failure is distinct from parsing failure.

Vowel counting is deterministic. SubmissionStore serializes access and atomically writes a JSON file in Application Support. The demo stores text only on explicit Save result. There is no login, telemetry, PHP endpoint or MySQL connection.
