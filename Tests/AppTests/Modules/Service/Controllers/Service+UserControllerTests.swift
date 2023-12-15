@testable import App
import Fluent
import XCTVapor

final class ServiceUserControllerTests: TestCase {
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

        try app.test(.GET, "api/v1/services/\(service1.requireID())/users") { res in
            XCTAssertEqual(res.status, .ok)
            let users = try res.content.decode([User.Response].self)
            XCTAssertEqual(users.count, 2)
            XCTAssertEqual(users[0], try user1.response())
            XCTAssertEqual(users[1], try user2.response())
        }
    }

    func testCreate() async throws {
        let service1 = try await createService()
        let user1 = User.Create(name: "test", email: "test@test.com", password: "12345678", confirmPassword: "12345678")

        try await app.test(.POST, "api/v1/services/\(service1.requireID())/users", beforeRequest: { req in
            try req.content.encode(user1)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.Response.self)
            XCTAssertEqual(user.name, user1.name)
            let serviceUser = try await service1.$users.query(on: app.db).filter(\.$id == user.id).first()
            XCTAssertNotNil(serviceUser)
            XCTAssertEqual(user, try serviceUser!.response())
        })
    }

    func testDestroy() async throws {
        let service1 = try await createService()
        let user1 = try await createUser()
        try await user1.$services.attach(service1, on: app.db) { su in
            su.$createdBy.id = try self.systemUser.requireID()
        }

        try await app.test(.DELETE, "api/v1/services/\(service1.requireID())/users/\(user1.requireID())") { res in
            XCTAssertEqual(res.status, .noContent)
            let serviceUser = try await service1.$users.query(on: app.db).filter(\.$id == user1.requireID()).first()
            XCTAssertNil(serviceUser)
        }
    }
}
