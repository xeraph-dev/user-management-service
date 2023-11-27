import Fluent
import FluentSQL

extension Role {
    struct CreateMigration: AsyncMigration {
        var name: String { "CreateRole" }

        func prepare(on database: Database) async throws {
            try await database.transaction { db in
                try await db.schema(Role.schema)
                    .id()
                    .field("name", .string, .required)
                    .field("created_at", .datetime, .required)
                    .field("created_by_id", .uuid, .required, .references(User.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                    .field("updated_at", .datetime, .required)
                    .field("updated_by_id", .uuid, .required, .references(User.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                    .field("deleted_at", .datetime)
                    .field("deleted_by_id", .uuid, .references(User.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                    .unique(on: "name")
                    .create()

                let user = try await User.query(on: db).field(\.$id).filter(\.$name == "system").first()!
                let system = Role()
                system.name = "system"
                try await system.create(on: db, by: user)

                try await db.schema(User.schema)
                    .field("role_id", .uuid, .references(Role.schema, "id", onDelete: .restrict, onUpdate: .cascade))
                    .update()

                user.$role.id = system.id!
                try await user.update(on: db, by: user)

                if let sql = db as? SQLDatabase {
                    try await sql.raw(.init("""
                    ALTER TABLE \(User.schema)
                    ALTER COLUMN role_id SET NOT NULL
                    """)).run()
                }
            }
        }

        func revert(on database: Database) async throws {
            try await database.transaction { db in
                try await db.schema(User.schema).deleteField("role_id").update()
                try await db.schema(Role.schema).delete()
            }
        }
    }
}
