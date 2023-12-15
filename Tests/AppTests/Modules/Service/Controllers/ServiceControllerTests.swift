@testable import App
import Fluent
import XCTVapor

final class ServiceControllerTests: TestCase {
    func testIndex() async throws {
        let service1 = try await createService(name: "test1")
        let service2 = try await createService(name: "test2")

        try app.test(.GET, "api/v1/services") { res in
            XCTAssertEqual(res.status, .ok)
            let services = try res.content.decode([Service.Response].self)
            XCTAssertEqual(services.count, 2)
            XCTAssertEqual(services[0], try service1.response())
            XCTAssertEqual(services[1], try service2.response())
        }
    }

    func testCreate() async throws {
        let service1 = Service.Create(name: "test")

        try app.test(.POST, "api/v1/services", beforeRequest: { req in
            try req.content.encode(service1)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let service = try res.content.decode(Service.Response.self)
            XCTAssertEqual(service.name, service1.name)
        })
    }

    func testShow() async throws {
        let service1 = try await createService()

        try app.test(.GET, "api/v1/services/\(service1.requireID())") { res in
            XCTAssertEqual(res.status, .ok)
            let service = try res.content.decode(Service.Response.self)
            XCTAssertEqual(service, try service1.response())
        }
    }

    func testUpdate() async throws {
        let serviceUpdate = Service.Update(name: "testtest")
        let service1 = try await createService()
        service1.name = serviceUpdate.name!

        try await app.test(.PATCH, "api/v1/services/\(service1.requireID())", beforeRequest: { req in
            try req.content.encode(serviceUpdate)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            let service = try await Service.find(service1.id, on: app.db)
            XCTAssertNotNil(service)
            try XCTAssertEqual(service!.response(), service1.response())
        })
    }

    func testDelete() async throws {
        let service1 = try await createService()

        try await app.test(.DELETE, "api/v1/services/\(service1.requireID())") { res in
            XCTAssertEqual(res.status, .noContent)
            let service = try await Service.query(on: app.db)
                .withDeleted()
                .filter(\.$id == service1.requireID())
                .filter(\.$deletedAt != nil)
                .first()
            XCTAssertNotNil(service)
            try XCTAssertEqual(service!.response(), service1.response())
        }
    }
}
