import XCTest
final class ChallengesUITests: XCTestCase {
    @MainActor func testOfflineExercises() {
        let app = XCUIApplication(); app.launch()
        XCTAssertTrue(app.staticTexts["A small garden, a shared city"].waitForExistence(timeout: 5))
        app.buttons["URLs"].firstMatch.tap()
        app.buttons["Validate"].tap()
        XCTAssertTrue(app.staticTexts["url-result"].label.contains("https://example.com"))
        app.buttons["Vowels"].firstMatch.tap()
        XCTAssertEqual(app.staticTexts["vowel-count"].label, "3 vowels")
        app.buttons["Save result"].tap()
        XCTAssertTrue(app.staticTexts["Hello, world!"].exists)
    }
}
