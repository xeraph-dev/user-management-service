@testable import App
import XCTVapor

class TestCase: XCTestCase {
    var app: Application!
    var systemUser: User!

    override func setUp() async throws {
        app = Application(.testing)
        try await configure(app)

        try await app.autoRevert()
        try await app.autoMigrate()

        systemUser = try await User.system(on: app.db)
    }

    override func tearDown() async throws {
        try await app.autoRevert()
        app.shutdown()
    }

    func createUser(name: String = "test") async throws -> User {
        let user = User(name: name, email: "\(name)@test.com", password: "12345678")
        try await user.create(on: app.db, by: systemUser)
        return user
    }

    func createUserCreate(name: String = "test") -> User.Create {
        User.Create(name: name, email: "\(name)@test.com", password: "12345678", confirmPassword: "12345678")
    }
}
