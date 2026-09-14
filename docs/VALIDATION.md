# Validation — 2026-09-14

Host: macOS 26.6.2 (25G83), Apple Silicon; Xcode 26.6 (17F113), Swift 6.3.3. Source: this modernization PR; release receipt records the exact merged commit.

- `swift test`: five tests passed for English vowel semantics, URL parsing, HEAD statuses/cancellation, persistence and offline articles.
- CodingChallenges iPhone 17 Pro / iOS 26.5 UI test passed: all three tabs, offline URL response, vowel count and save history.
- Final simulator build passed with explicit article loading/empty state.
- The application consumes ChallengeKit through SPM without third-party packages.

Unavailable/unverified: Xcode 27, iOS 18/27 runtime, real network redirects/unreachable hosts, VoiceOver, large text, dark mode and physical keyboard review. URLSession is responsible for redirect handling; the current injected-transport tests do not validate real redirect chains. No account or server is required for tested demos.

Local commands: `swift test`; open CodingChallenges.xcodeproj and Test on an installed simulator. Keep unavailable checks distinct from failures.

Independent temporary SPM executable consumer: built and ran successfully with this package as a dependency. iPhone preview images were captured from the simulator and visually reviewed.

The offline exercise UI test also passed on an iPad Pro 13-inch simulator running iPadOS 26.5. Initial iPad runs failed because the test assumed an iPhone tab-bar container, then encountered duplicate accessibility wrappers. The corrected first-match tab-button query passed; no application navigation change was needed.
