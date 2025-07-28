import XCTest
@testable import ZEMI

final class ZEMITests: XCTestCase {
    func testExample() throws {
        
        let user = User()
        user.name = "John Krasinski"
        
        
        
        print(user.toString())
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
}
