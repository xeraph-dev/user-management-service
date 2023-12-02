import Fluent

extension User {
    struct CreateMigration: AsyncMigration {
        var name: String { "CreateUser" }

        func prepare(on database: Database) async throws {
            try await database.schema(schema)
                .id()
                .field("name", .string, .required)
                .field("email", .string, .required)
                .field("password", .string, .required)
                .field("created_at", .datetime, .required)
                .field("updated_at", .datetime, .required)
                .field("deleted_at", .datetime)
                .unique(on: "name")
                .unique(on: "email")
                .create()
        }

        func revert(on database: Database) async throws {
            try await database.schema(schema).delete()
        }
    }
}
