@testable import App
import Fluent
import XCTVapor

final class ServiceRoleControllerTests: TestCase {
    func testIndex() async throws {
        let service1 = try await createService()
        let role1 = try await createRole(name: "test1", service: service1)
        let role2 = try await createRole(name: "test2", service: service1)

        try app.test(.GET, "api/v1/services/\(service1.requireID())/roles") { res in
            XCTAssertEqual(res.status, .ok)
            let roles = try res.content.decode([Role.Response].self)
            XCTAssertEqual(roles.count, 2)
            XCTAssertEqual(roles[0], try role1.response())
            XCTAssertEqual(roles[1], try role2.response())
        }
    }

    func testCreate() async throws {
        let service1 = try await createService()
        let role1 = Role.Create(name: "test")

        try app.test(.POST, "api/v1/services/\(service1.requireID())/roles", beforeRequest: { req in
            try req.content.encode(role1)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let role = try res.content.decode(Role.Response.self)
            XCTAssertEqual(role.name, role1.name)
        })
    }

    func testShow() async throws {
        let service1 = try await createService()
        let role1 = try await createRole(service: service1)

        try app.test(.GET, "api/v1/services/\(service1.requireID())/roles/\(role1.requireID())") { res in
            XCTAssertEqual(res.status, .ok)
            let role = try res.content.decode(Role.Response.self)
            XCTAssertEqual(role, try role1.response())
        }
    }

    func testUpdate() async throws {
        let service1 = try await createService()
        let roleUpdate = Role.Update(name: "testtest")
        let role1 = try await createRole(service: service1)
        role1.name = roleUpdate.name!

        try await app.test(.PATCH, "api/v1/services/\(service1.requireID())/roles/\(role1.requireID())", beforeRequest: { req in
            try req.content.encode(roleUpdate)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            let role = try await service1.$roles.query(on: app.db).filter(\.$id == role1.requireID()).first()
            XCTAssertNotNil(role)
            try XCTAssertEqual(role!.response(), role1.response())
        })
    }

    func testDelete() async throws {
        let service1 = try await createService()
        let role1 = try await createRole(service: service1)

        try await app.test(.DELETE, "api/v1/services/\(service1.requireID())/roles/\(role1.requireID())") { res in
            XCTAssertEqual(res.status, .noContent)
            let role = try await service1.$roles.query(on: app.db)
                .withDeleted()
                .filter(\.$id == role1.requireID())
                .filter(\.$deletedAt != nil)
                .first()
            XCTAssertNotNil(role)
            try XCTAssertEqual(role!.response(), role1.response())
        }
    }
}
