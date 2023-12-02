import Fluent

extension Service.User {
    struct AddSystemUserToSystemMigration: AsyncMigration {
        var name: String { "AddSystemUserToSystemService" }

        func prepare(on database: Database) async throws {
            guard let user = try await User.query(on: database).field(\.$id).filter(\.$name == "system").first() else {
                throw User.Errors.systemNotExist
            }

            guard let system = try await Service.query(on: database).field(\.$id).filter(\.$name == "system").first() else {
                throw Service.Errors.systemNotExist
            }

            let serviceUser = Service.User()
            serviceUser.$service.id = try system.requireID()
            serviceUser.$user.id = try user.requireID()
            try await serviceUser.create(on: database, by: user)
        }

        func revert(on database: Database) async throws {
            guard let system = try await User.query(on: database).field(\.$id).filter(\.$name == "system").first() else {
                throw User.Errors.systemNotExist
            }

            guard let serviceUser = try await Service.User.query(on: database)
                .field(\.$id)
                .join(Service.self, on: \Service.User.$service.$id == \Service.$id)
                .join(User.self, on: \Service.User.$user.$id == \User.$id)
                .filter(Service.self, \.$name == "system")
                .filter(User.self, \.$name == "system")
                .first()
            else {
                throw Service.User.Errors.notExists("system", "system")
            }

            try await serviceUser.delete(force: true, on: database, by: system)
        }
    }
}
