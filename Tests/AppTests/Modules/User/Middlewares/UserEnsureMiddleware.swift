@testable import App
import XCTVapor

final class UserEnsureMiddlewareTests: TestCase {
    func testWorks() async throws {
        let user1 = try await createUser()
        let id = try user1.requireID().uuidString

        app.grouped("path", ":user_id", "testing")
            .grouped(User.EnsureMiddleware())
            .get { try $0.user.response() }

        try app.test(.GET, "path/\(id)/testing") { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.Response.self)
            XCTAssertEqual(user, try user1.response())
        }
    }

    func testDeletedWorks() async throws {
        let user1 = try await createUser()
        try await user1.delete(on: app.db, by: systemUser)
        let id = try user1.requireID().uuidString

        app.grouped("path", ":user_id", "testing")
            .grouped(User.EnsureMiddleware(deleted: true))
            .get { try $0.user.response() }

        try app.test(.GET, "path/\(id)/testing") { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.Response.self)
            XCTAssertEqual(user, try user1.response())
        }
    }
}
