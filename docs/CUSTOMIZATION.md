# Customization

Implement ArticleLoading for another source and inject it into your own view model. Keep preview fixtures original and offline. Use URLChecking fakes for deterministic errors and slow responses; choose a URLSession configuration appropriate to your app for live use.

Configure SubmissionStore with a temporary directory for tests or an Application Support file for persistence. Change vowel semantics only with explicit documentation and tests.

The app uses semantic typography/colors and native SwiftUI navigation, forms and lists. Test dark mode, VoiceOver, large text, keyboard navigation and iPad rotation when adapting screens. Do not make learning examples depend on an account or production API.
