import XCTest
import MMDB

class MMDBTests: XCTestCase {
    var database: MMDB!
    
    override func setUp() {
        super.setUp()
        database = MMDB()
    }
    
    func testExample() {
        XCTAssertEqual(database.lookup("202.108.22.220")?.isoCode, "CN")
    }
}
