import Fluent

extension Role {
    struct CreateMigration: AsyncMigration {
        var name: String { "CreateRole" }

        func prepare(on database: Database) async throws {
            try await database.schema(Role.schema)
                .id()
                .field("name", .string, .required)
                .field("service_id", .uuid, .required, .references(Service.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                .field("created_at", .datetime, .required)
                .field("updated_at", .datetime, .required)
                .field("deleted_at", .datetime)
                .field("created_by_id", .uuid, .required, .references(User.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                .field("updated_by_id", .uuid, .required, .references(User.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                .field("deleted_by_id", .uuid, .references(User.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                .unique(on: "name", "service_id")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema(Role.schema).delete()
        }
    }
}
