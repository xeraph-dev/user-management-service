@testable import App
import XCTVapor

final class UserUpdateTests: TestCase {
    func testAllValid() throws {
        let user = User.Update(name: "test", email: "test@test.com", password: "12345678", confirmPassword: "12345678")
        let data = try JSONEncoder().encode(user)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertNoThrow(try User.Update.validate(json: json))
    }
    
    func testNameInvalid() throws {
        var user = User.Update(name: "")
        user.name = ""
        let data = try JSONEncoder().encode(user)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertThrowsError(try User.Update.validate(json: json))
    }
    
    func tesEmailInvalid() throws {
        var user = User.Update(email: "test")
        user.email = "test"
        let data = try JSONEncoder().encode(user)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertThrowsError(try User.Update.validate(json: json))
    }
    
    func testPasswordInvalid() throws {
        var user = User.Update(password: "1234")
        user.password = "123"
        let data = try JSONEncoder().encode(user)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertThrowsError(try User.Update.validate(json: json))
    }
    
    func testConfirmInvalid() throws {
        var user = User.Update(confirmPassword: "")
        user.confirmPassword = ""
        let data = try JSONEncoder().encode(user)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertThrowsError(try User.Update.validate(json: json))
    }
}
