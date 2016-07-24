import EventKit
import Foundation
import PromiseKit
import XCTest

class Test_EventKit_Swift: XCTestCase {
    func test() {
        // EventKit behaves differently in CI :(
        guard !isTravis() else { return }

        let ex = expectation(description: "")
        EKEventStoreRequestAccess().then { _ in
            ex.fulfill()
        }
        waitForExpectations(timeout: 30, handler: nil)
    }
}
