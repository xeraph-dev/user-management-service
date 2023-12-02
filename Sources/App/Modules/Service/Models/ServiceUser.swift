import Fluent

extension Service {
    final class User: Model {
        enum Errors: Error, CustomStringConvertible {
            case notExists(String, String)

            var description: String {
                switch self {
                case .notExists(let service, let user): "The user '\(user)' is not registered in the service '\(service)'"
                }
            }
        }

        static let schema = "\(Service.schema)+\(App.User.schema)"

        @ID(key: .id)
        var id: UUID?

        @Parent(key: "service_id")
        var service: Service

        @Parent(key: "user_id")
        var user: App.User

        @Timestamp(key: "created_at", on: .create)
        var createdAt: Date?
        @Parent(key: "created_by_id")
        var createdBy: App.User

        @Timestamp(key: "updated_at", on: .update)
        var updatedAt: Date?
        @Parent(key: "updated_by_id")
        var updatedBy: App.User

        @Timestamp(key: "deleted_at", on: .delete)
        var deletedAt: Date?
        @OptionalParent(key: "deleted_by_id")
        var deletedBy: App.User?

        func create(on db: Database, by: App.User) async throws {
            $createdBy.id = try by.requireID()
            $updatedBy.id = try by.requireID()
            try await create(on: db)
        }

        func update(on db: Database, by: App.User) async throws {
            $updatedBy.id = try by.requireID()
            try await update(on: db)
        }

        func delete(force: Bool = false, on db: Database, by: App.User) async throws {
            if !force {
                $deletedBy.id = try by.requireID()
                try await update(on: db)
            }
            try await delete(force: force, on: db)
        }

        func restore(on db: Database, by: App.User) async throws {
            $deletedBy.id = nil
            try await update(on: db)
            try await restore(on: db)
        }
    }
}
