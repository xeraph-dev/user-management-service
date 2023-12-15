@testable import App
import XCTVapor

final class UserCreateTests: TestCase {
    func testAllValid() throws {
        let user = User.Create(name: "test", email: "test@test.com", password: "12345678", confirmPassword: "12345678")
        let data = try JSONEncoder().encode(user)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertNoThrow(try User.Create.validate(json: json))
    }

    func testNameInvalid() throws {
        let user = User.Create(name: "", email: "test@test.com", password: "12345678", confirmPassword: "12345678")
        let data = try JSONEncoder().encode(user)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertThrowsError(try User.Create.validate(json: json))
    }

    func tesEmailInvalid() throws {
        let user = User.Create(name: "test", email: "", password: "12345678", confirmPassword: "12345678")
        let data = try JSONEncoder().encode(user)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertThrowsError(try User.Create.validate(json: json))
    }

    func testPasswordInvalid() throws {
        let user = User.Create(name: "test", email: "test@test.com", password: "", confirmPassword: "12345678")
        let data = try JSONEncoder().encode(user)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertThrowsError(try User.Create.validate(json: json))
    }

    func testConfirmInvalid() throws {
        let user = User.Create(name: "test", email: "test@test.com", password: "12345678", confirmPassword: "")
        let data = try JSONEncoder().encode(user)
        let json = String(data: data, encoding: .utf8)!
        XCTAssertThrowsError(try User.Create.validate(json: json))
    }
}
