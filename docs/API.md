# ChallengeKit API

- Article: immutable Codable/Identifiable content. ArticleLoading is an asynchronous injectable source; SampleArticleLoader returns three original, offline articles.
- URLValidator.parse: trims surrounding whitespace, defaults to HTTPS, rejects empty hosts, credentials and unsupported schemes. Syntax success is not a promise that a host exists.
- URLValidator.check: uses an injectable URLChecking transport, HEAD and a ten-second timeout; checks cancellation before and after the request. NetworkURLChecker uses URLSession redirect behavior. HTTP 405/501 means the server rejected HEAD, not malformed input. No automatic GET download fallback.
- VowelCounter.count: case-insensitive English a/e/i/o/u. Accented graphemes and y do not count; Unicode canonical representation does not turn é into e.
- SubmissionStore: actor with load/append/clear; creates parent directories and writes JSON atomically. Configure the file URL explicitly in a consumer. Invalid persisted JSON throws rather than silently erasing history.

Add this repository as a Swift package and select ChallengeKit. UI code is an example application, not part of the library product.

## Exercise previews

[Article Browser](../previews/iphone.png) · [URL Validator](../previews/urls.png) · [Vowel Counter](../previews/vowels.png)
