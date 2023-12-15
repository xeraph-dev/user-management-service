@testable import App
import XCTVapor

final class ServiceCreateTests: TestCase {
    func testAllValid() throws {
        let service = Service.Create(name: "test")
        let data = try JSONEncoder().encode(service)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertNoThrow(try Service.Create.validate(json: json))
    }

    func testNameInvalid() throws {
        let service = Service.Create(name: "")
        let data = try JSONEncoder().encode(service)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertThrowsError(try Service.Create.validate(json: json))
    }
}
