@testable import App
import XCTVapor

final class ServiceUpdateTests: TestCase {
    func testAllValid() throws {
        let service = Service.Update(name: "test")
        let data = try JSONEncoder().encode(service)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertNoThrow(try Service.Update.validate(json: json))
    }

    func testNameInvalid() throws {
        let service = Service.Update(name: "")
        let data = try JSONEncoder().encode(service)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertThrowsError(try Service.Update.validate(json: json))
    }
}
