@testable import App
import Fluent
import XCTVapor

class TestCase: XCTestCase {
    var app: Application!
    var systemUser: User!
    var systemService: Service!
    var systemRole: Role!

    override func setUp() async throws {
        app = Application(.testing)
        try await configure(app)

        try await app.autoMigrate()

        systemUser = try await User.system(on: app.db)
        systemService = try await Service.system(on: app.db)
        systemRole = try await Role.system(on: app.db)

        try await clearDatabase()
    }

    override func tearDown() async throws {
        try await clearDatabase()
        app.shutdown()
    }

    private func clearDatabase() async throws {
        try await Role.query(on: app.db)
            .withDeleted()
            .filter(\.$id != systemRole.requireID())
            .delete(force: true)

        try await Service.User.query(on: app.db)
            .filter(\.$service.$id != systemService.requireID())
            .filter(\.$user.$id != systemUser.requireID())
            .delete(force: true)

        try await Service.query(on: app.db)
            .withDeleted()
            .filter(\.$id != systemService.requireID())
            .delete(force: true)

        try await User.query(on: app.db)
            .withDeleted()
            .filter(\.$id != systemUser.requireID())
            .delete(force: true)
    }

    func createUser(name: String = "test") async throws -> User {
        let user = User(name: name, email: "\(name)@test.com", password: "12345678")
        try await user.create(on: app.db, by: systemUser)
        return user
    }

    func createService(name: String = "test") async throws -> Service {
        let service = Service(name: name)
        try await service.create(on: app.db, by: systemUser)
        return service
    }

    func createRole(name: String = "test", service: Service) async throws -> Role {
        let role = try Role(name: name, service: service)
        try await role.create(on: app.db, by: systemUser)
        return role
    }
}
