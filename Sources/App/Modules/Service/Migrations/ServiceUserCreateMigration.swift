import Fluent

extension Service.User {
    struct CreateMigration: AsyncMigration {
        var name: String { "CreateServiceUser" }

        func prepare(on database: Database) async throws {
            try await database.schema(Service.User.schema)
                .id()
                .field("service_id", .uuid, .required, .references(Service.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                .field("user_id", .uuid, .required, .references(App.User.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                .field("created_at", .datetime, .required)
                .field("updated_at", .datetime, .required)
                .field("deleted_at", .datetime)
                .field("created_by_id", .uuid, .required, .references(User.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                .field("updated_by_id", .uuid, .required, .references(User.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                .field("deleted_by_id", .uuid, .references(User.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema(Service.User.schema).delete()
        }
    }
}
