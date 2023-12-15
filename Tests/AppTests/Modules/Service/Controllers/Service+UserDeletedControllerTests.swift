@testable import App
import Fluent
import XCTVapor

final class ServiceUserDeletedControllerTests: TestCase {
    func testIndex() async throws {
        let service1 = try await createService()
        let user1 = try await createUser(name: "test1")
        let user2 = try await createUser(name: "test2")

        try await user1.$services.attach(service1, on: app.db) { su in
            su.$createdBy.id = try self.systemUser.requireID()
        }
        try await user2.$services.attach(service1, on: app.db) { su in
            su.$createdBy.id = try self.systemUser.requireID()
        }

        try await user1.delete(on: app.db, by: systemUser)
        try await user2.delete(on: app.db, by: systemUser)

        try app.test(.GET, "api/v1/services/\(service1.requireID())/users/deleted") { res in
            XCTAssertEqual(res.status, .ok)
            let users = try res.content.decode([User.Response].self)
            XCTAssertEqual(users.count, 2)
            XCTAssertEqual(users[0], try user2.response())
            XCTAssertEqual(users[1], try user1.response())
        }
    }
}
