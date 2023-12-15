@testable import App
import XCTVapor

final class ServiceUserEnsureMiddlewareTests: TestCase {
    func testWorks() async throws {
        let service1 = try await createService()
        let user1 = try await createUser()

        let systemId = try service1.requireID().uuidString
        let userId = try user1.requireID().uuidString

        try await user1.$services.attach(service1, on: app.db) { su in
            su.$createdBy.id = try user1.requireID()
        }

        app.grouped("path", ":service_id", ":user_id", "testing")
            .grouped(Service.EnsureMiddleware())
            .grouped(User.EnsureMiddleware())
            .get { try $0.user.response() }

        try app.test(.GET, "path/\(systemId)/\(userId)/testing") { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.Response.self)
            XCTAssertEqual(user, try user1.response())
        }
    }

    func testDeletedWorks() async throws {
        let service1 = try await createService()
        let user1 = try await createUser()

        let systemId = try service1.requireID().uuidString
        let userId = try user1.requireID().uuidString

        try await user1.$services.attach(service1, on: app.db) { su in
            su.$createdBy.id = try user1.requireID()
        }

        try await service1.delete(on: app.db, by: systemUser)
        try await user1.delete(on: app.db, by: systemUser)

        app.grouped("path", ":service_id", ":user_id", "testing")
            .grouped(Service.EnsureMiddleware(deleted: true))
            .grouped(User.EnsureMiddleware(deleted: true))
            .get { try $0.user.response() }

        try app.test(.GET, "path/\(systemId)/\(userId)/testing") { res in
            XCTAssertEqual(res.status, .ok)
            let user = try res.content.decode(User.Response.self)
            XCTAssertEqual(user, try user1.response())
        }
    }
}
