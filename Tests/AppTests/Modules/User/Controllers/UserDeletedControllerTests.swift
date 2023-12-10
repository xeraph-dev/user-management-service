@testable import App
import Fluent
import XCTVapor

final class UserDeletedControllerTests: TestCase {
    func testIndex() async throws {
        let user1 = try await createUser(name: "test1")
        let user2 = try await createUser(name: "test2")
        try await user1.delete(on: app.db, by: systemUser)
        try await user2.delete(on: app.db, by: systemUser)

        try app.test(.GET, "api/v1/users/deleted") { res in
            XCTAssertEqual(res.status, .ok)
            let users = try res.content.decode([User.Response].self)
            XCTAssertEqual(users.count, 2)
            XCTAssertEqual(users[0], try user1.response())
            XCTAssertEqual(users[1], try user2.response())
        }
    }

    func testShow() async throws {
        let user1 = try await createUser()
        try await user1.delete(on: app.db, by: systemUser)

        try app.test(.GET, "api/v1/users/deleted/\(user1.requireID())") { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.Response.self)
            XCTAssertEqual(user, try user1.response())
        }
    }

    func testRestore() async throws {
        let user1 = try await createUser()
        try await user1.delete(on: app.db, by: systemUser)

        try await app.test(.POST, "api/v1/users/deleted/\(user1.requireID())") { res in
            XCTAssertEqual(res.status, .noContent)
            let user = try await User.find(user1.id, on: app.db)
            XCTAssertNotNil(user)
            try XCTAssertEqual(user!.response(), user1.response())
        }
    }

    func testDestroy() async throws {
        let user1 = try await createUser()
        try await user1.delete(on: app.db, by: systemUser)

        try await app.test(.DELETE, "api/v1/users/deleted/\(user1.requireID())") { res in
            XCTAssertEqual(res.status, .noContent)
            let user = try await User.query(on: app.db)
                .withDeleted()
                .filter(\.$id == user1.requireID())
                .filter(\.$deletedAt != nil)
                .first()
            XCTAssertNil(user)
        }
    }
}
