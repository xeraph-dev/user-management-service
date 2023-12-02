import Fluent

extension Role {
    struct InsertSystemMigration: AsyncMigration {
        var name: String { "InsertSystemRole" }

        func prepare(on database: Database) async throws {
            guard let user = try await User.query(on: database).field(\.$id).filter(\.$name == "system").first() else {
                throw User.Errors.systemNotExist
            }
            let system = Role()
            system.name = "system"
            try await system.create(on: database, by: user)
        }

        func revert(on database: Database) async throws {
            guard let system = try await Role.query(on: database).field(\.$id).filter(\.$name == "system").first() else {
                throw Role.Errors.systemNotExist
            }
            try await system.delete(on: database)
        }
    }
}
