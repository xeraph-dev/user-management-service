@testable import App
import XCTVapor

final class ServiceEnsureMiddlewareTests: TestCase {
    func testWorks() async throws {
        let service1 = try await createService()
        let id = try service1.requireID().uuidString

        app.grouped("path", ":service_id", "testing")
            .grouped(Service.EnsureMiddleware())
            .get { try $0.service.response() }

        try app.test(.GET, "path/\(id)/testing") { res in
            XCTAssertEqual(res.status, .ok)
            let service = try res.content.decode(Service.Response.self)
            XCTAssertEqual(service, try service1.response())
        }
    }

    func testDeletedWorks() async throws {
        let service1 = try await createService()
        try await service1.delete(on: app.db, by: systemUser)
        let id = try service1.requireID().uuidString

        app.grouped("path", ":service_id", "testing")
            .grouped(Service.EnsureMiddleware(deleted: true))
            .get { try $0.service.response() }

        try app.test(.GET, "path/\(id)/testing") { res in
            XCTAssertEqual(res.status, .ok)
            let service = try res.content.decode(Service.Response.self)
            XCTAssertEqual(service, try service1.response())
        }
    }
}
