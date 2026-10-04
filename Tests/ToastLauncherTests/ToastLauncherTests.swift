import XCTest
@testable import ToastLauncher

final class ToastLauncherTests: XCTestCase {
    // Exercises the deprecated template type on purpose; marking the test
    // deprecated silences the deprecation warning inside it.
    @available(*, deprecated)
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(ToastLauncher().text, "Hello, World!")
    }
}
