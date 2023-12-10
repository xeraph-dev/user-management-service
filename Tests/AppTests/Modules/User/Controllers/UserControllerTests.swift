@testable import App
import Fluent
import XCTVapor

final class UserControllerTests: TestCase {
    func testIndex() async throws {
        let user1 = try await createUser(name: "test1")
        let user2 = try await createUser(name: "test2")

        try app.test(.GET, "api/v1/users") { res in
            XCTAssertEqual(res.status, .ok)
            let users = try res.content.decode([User.Response].self)
            XCTAssertEqual(users.count, 2)
            XCTAssertEqual(users[0], try user1.response())
            XCTAssertEqual(users[1], try user2.response())
        }
    }

    func testCreate() async throws {
        let user1 = createUserCreate()

        try app.test(.POST, "api/v1/users", beforeRequest: { req in
            try req.content.encode(user1)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.Response.self)
            XCTAssertEqual(user.name, user1.name)
            XCTAssertEqual(user.email, user1.email)
        })
    }

    func testShow() async throws {
        let user1 = try await createUser()

        try app.test(.GET, "api/v1/users/\(user1.requireID())") { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.Response.self)
            XCTAssertEqual(user, try user1.response())
        }
    }

    func testUpdate() async throws {
        let userUpdate = User.Update(name: "testtest")
        let user1 = try await createUser()
        user1.name = userUpdate.name!

        try await app.test(.PATCH, "api/v1/users/\(user1.requireID())", beforeRequest: { req in
            try req.content.encode(userUpdate)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            let user = try await User.find(user1.id, on: app.db)
            XCTAssertNotNil(user)
            try XCTAssertEqual(user!.response(), user1.response())
        })
    }

    func testDelete() async throws {
        let user1 = try await createUser()

        try await app.test(.DELETE, "api/v1/users/\(user1.requireID())") { res in
            XCTAssertEqual(res.status, .noContent)
            let user = try await User.query(on: app.db)
                .withDeleted()
                .filter(\.$id == user1.requireID())
                .filter(\.$deletedAt != nil)
                .first()
            XCTAssertNotNil(user)
            try XCTAssertEqual(user!.response(), user1.response())
        }
    }
}
