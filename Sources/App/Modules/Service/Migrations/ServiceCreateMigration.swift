import Fluent

extension Service {
    struct CreateMigration: AsyncMigration {
        var name: String { "CreateService" }

        func prepare(on database: Database) async throws {
            try await database.schema(Service.schema)
                .id()
                .field("name", .string, .required)
                .field("created_at", .datetime, .required)
                .field("updated_at", .datetime, .required)
                .field("deleted_at", .datetime)
                .field("created_by_id", .uuid, .required, .references(App.User.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                .field("updated_by_id", .uuid, .required, .references(App.User.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                .field("deleted_by_id", .uuid, .references(App.User.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                .unique(on: "name")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema(Service.schema).delete()
        }
    }
}
