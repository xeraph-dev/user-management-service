import Fluent

extension Service {
    struct InsertSystemMigration: AsyncMigration {
        var name: String { "InsertSystemService" }

        func prepare(on database: Database) async throws {
            guard let user = try await App.User.query(on: database).field(\.$id).filter(\.$name == "system").first() else {
                throw App.User.Errors.systemNotExist
            }
            let system = Service()
            system.name = "system"
            try await system.create(on: database, by: user)
        }

        func revert(on database: Database) async throws {
            try await system(on: database).delete(force: true, on: database)
        }
    }
}
