import Fluent
import FluentSQL

extension User {
    struct CreateMigration: AsyncMigration {
        var name: String { "CreateUser" }

        func prepare(on database: Database) async throws {
            try await database.transaction { db in
                try await db.schema(User.schema)
                    .id()
                    .field("name", .string, .required)
                    .field("email", .string, .required)
                    .field("password", .string, .required)
                    .field("created_at", .datetime, .required)
                    .field("created_by_id", .uuid, .references(User.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                    .field("updated_at", .datetime, .required)
                    .field("updated_by_id", .uuid, .references(User.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                    .field("deleted_at", .datetime)
                    .field("deleted_by_id", .uuid, .references(User.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                    .unique(on: "name")
                    .unique(on: "email")
                    .create()

                let system = User()
                system.name = "system"
                system.email = "system@system.com"
                system.password = ""
                try await system.create(on: db)
                system.$createdBy.id = system.id!
                try await system.update(on: db, by: system)

                if let sql = db as? SQLDatabase {
                    try await sql.raw(.init("""
                    ALTER TABLE \(User.schema)
                    ALTER COLUMN created_by_id SET NOT NULL,
                    ALTER COLUMN updated_by_id SET NOT NULL
                    """)).run()
                }
            }
        }

        func revert(on database: Database) async throws {
            try await database.transaction { db in
                try await db.schema(User.schema)
                    .deleteField("created_by_id")
                    .deleteField("updated_by_id")
                    .deleteField("deleted_by_id")
                    .update()
                try await db.schema(User.schema).delete()
            }
        }
    }
}
