@testable import App
import Fluent
import XCTVapor

final class ServiceDeletedControllerTests: TestCase {
    func testIndex() async throws {
        let service1 = try await createService(name: "test1")
        let service2 = try await createService(name: "test2")
        try await service1.delete(on: app.db, by: systemUser)
        try await service2.delete(on: app.db, by: systemUser)

        try app.test(.GET, "api/v1/services/deleted") { res in
            XCTAssertEqual(res.status, .ok)
            let services = try res.content.decode([Service.Response].self)
            XCTAssertEqual(services.count, 2)
            XCTAssertEqual(services[0], try service1.response())
            XCTAssertEqual(services[1], try service2.response())
        }
    }

    func testShow() async throws {
        let service1 = try await createService()
        try await service1.delete(on: app.db, by: systemUser)

        try app.test(.GET, "api/v1/services/deleted/\(service1.requireID())") { res in
            XCTAssertEqual(res.status, .ok)
            let service = try res.content.decode(Service.Response.self)
            XCTAssertEqual(service, try service1.response())
        }
    }

    func testRestore() async throws {
        let service1 = try await createService()
        try await service1.delete(on: app.db, by: systemUser)

        try await app.test(.POST, "api/v1/services/deleted/\(service1.requireID())") { res in
            XCTAssertEqual(res.status, .noContent)
            let service = try await Service.find(service1.id, on: app.db)
            XCTAssertNotNil(service)
            try XCTAssertEqual(service!.response(), service1.response())
        }
    }

    func testDestroy() async throws {
        let service1 = try await createService()
        try await service1.delete(on: app.db, by: systemUser)

        try await app.test(.DELETE, "api/v1/services/deleted/\(service1.requireID())") { res in
            XCTAssertEqual(res.status, .noContent)
            let service = try await Service.query(on: app.db)
                .withDeleted()
                .filter(\.$id == service1.requireID())
                .filter(\.$deletedAt != nil)
                .first()
            XCTAssertNil(service)
        }
    }
}
