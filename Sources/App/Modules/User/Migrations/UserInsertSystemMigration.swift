import Fluent

extension User {
    struct InsertSystemMigration: AsyncMigration {
        var name: String { "InsertSystemUser" }

        func prepare(on database: Database) async throws {
            let system = User()
            system.name = "system"
            system.email = ""
            system.password = ""
            try await system.create(on: database)
        }

        func revert(on database: Database) async throws {
            try await system(on: database).delete(force: true, on: database)
        }
    }
}
