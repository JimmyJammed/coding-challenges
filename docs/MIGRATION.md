# Migration

The maintained runtime is a new Swift 6 implementation. Use the revision in HISTORY to inspect or restore the old three exercise directories and their dependency notices. Root LICENSE preserves the original license verbatim.

Replace legacy app projects with CodingChallenges.xcodeproj, or import ChallengeKit from SPM. Remove vendored AFNetworking/other dependency references and personal Xcode state. Replace callback-based article/network code with ArticleLoading and URLValidator.check. Replace server-backed vowel submissions with SubmissionStore; old PHP/MySQL data is not automatically imported. Export old data separately if needed.

English a/e/i/o/u counting is now explicit. URL validity and reachability are separate concepts; a host declining HEAD is reported as such. Historic Facebook login is removed from the active runtime.
