@testable import App
import XCTVapor

final class UserCreateTests: TestCase {
    func testAllValid() throws {
        let user = createUserCreate()
        let data = try JSONEncoder().encode(user)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertNoThrow(try User.Create.validate(json: json))
    }
    
    func testNameInvalid() throws {
        var user = createUserCreate()
        user.name = ""
        let data = try JSONEncoder().encode(user)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertThrowsError(try User.Create.validate(json: json))
    }
    
    func tesEmailInvalid() throws {
        var user = createUserCreate()
        user.email = "test"
        let data = try JSONEncoder().encode(user)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertThrowsError(try User.Create.validate(json: json))
    }
    
    func testPasswordInvalid() throws {
        var user = createUserCreate()
        user.password = "123"
        let data = try JSONEncoder().encode(user)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertThrowsError(try User.Create.validate(json: json))
    }
    
    func testConfirmInvalid() throws {
        var user = createUserCreate()
        user.confirmPassword = ""
        let data = try JSONEncoder().encode(user)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertThrowsError(try User.Create.validate(json: json))
    }
}
