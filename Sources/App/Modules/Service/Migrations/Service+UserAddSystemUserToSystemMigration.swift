import Fluent

extension Service.User {
    struct AddSystemUserToSystemMigration: AsyncMigration {
        var name: String { "AddSystemUserToSystemService" }

        func prepare(on database: Database) async throws {
            let user = try await App.User.system(on: database)
            let service = try await Service.system(on: database)

            let serviceUser = Service.User()
            serviceUser.$service.id = try service.requireID()
            serviceUser.$user.id = try user.requireID()
            try await serviceUser.create(on: database, by: user)
        }

        func revert(on database: Database) async throws {
            try await Service.User.system(on: database).delete(force: true, on: database)
        }
    }
}
