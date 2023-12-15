@testable import App
import Fluent
import XCTVapor

final class ServiceRoleDeletedControllerTests: TestCase {
    func testIndex() async throws {
        let service1 = try await createService(name: "test1")
        let role1 = try await createRole(name: "test1", service: service1)
        let role2 = try await createRole(name: "test2", service: service1)
        try await role1.delete(on: app.db, by: systemUser)
        try await role2.delete(on: app.db, by: systemUser)

        try app.test(.GET, "api/v1/services/\(service1.requireID())/roles/deleted") { res in
            XCTAssertEqual(res.status, .ok)
            let roles = try res.content.decode([Role.Response].self)
            XCTAssertEqual(roles.count, 2)
            XCTAssertEqual(roles[0], try role1.response())
            XCTAssertEqual(roles[1], try role2.response())
        }
    }

    func testShow() async throws {
        let service1 = try await createService()
        let role1 = try await createRole(name: "test1", service: service1)
        try await role1.delete(on: app.db, by: systemUser)

        try app.test(.GET, "api/v1/services/\(service1.requireID())/roles/deleted/\(role1.requireID())") { res in
            XCTAssertEqual(res.status, .ok)
            let role = try res.content.decode(Role.Response.self)
            XCTAssertEqual(role, try role1.response())
        }
    }

    func testRestore() async throws {
        let service1 = try await createService()
        let role1 = try await createRole(name: "test1", service: service1)
        try await role1.delete(on: app.db, by: systemUser)

        try await app.test(.POST, "api/v1/services/\(service1.requireID())/roles/deleted/\(role1.requireID())") { res in
            XCTAssertEqual(res.status, .noContent)
            let role = try await Role.find(role1.id, on: app.db)
            XCTAssertNotNil(role)
            try XCTAssertEqual(role!.response(), role1.response())
        }
    }

    func testDestroy() async throws {
        let service1 = try await createService()
        let role1 = try await createRole(name: "test1", service: service1)
        try await role1.delete(on: app.db, by: systemUser)

        try await app.test(.DELETE, "api/v1/services/\(service1.requireID())/roles/deleted/\(role1.requireID())") { res in
            XCTAssertEqual(res.status, .noContent)
            let role = try await Role.find(role1.requireID(), on: app.db)
            XCTAssertNil(role)
        }
    }
}
