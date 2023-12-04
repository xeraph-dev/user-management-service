import Fluent

extension Role {
    struct InsertSystemMigration: AsyncMigration {
        var name: String { "InsertSystemRole" }

        func prepare(on database: Database) async throws {
            let service = try await Service.system(on: database)
            let user = try await User.system(on: database)

            let system = Role()
            system.name = "system"
            system.$service.id = try service.requireID()

            try await system.create(on: database, by: user)
        }

        func revert(on database: Database) async throws {
            try await system(on: database).delete(force: true, on: database)
        }
    }
}
