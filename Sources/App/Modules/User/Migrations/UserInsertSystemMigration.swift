import Fluent

extension User {
    struct InsertSystemMigration: AsyncMigration {
        var name: String { "InsertSystemUser" }

        func prepare(on database: Database) async throws {
            let system = User()
            system.name = Names.system.rawValue
            system.email = ""
            system.password = ""
            try await system.create(on: database)
        }

        func revert(on database: Database) async throws {
            guard let system = try await query(on: database)
                .field(\.$id)
                .filter(\.$name == Names.system.rawValue)
                .first()
            else {
                throw Errors.systemNotExist
            }

            try await system.delete(force: true, on: database, by: system)
        }
    }
}
