import Fluent
import FluentSQL

extension User {
    struct AddModifiedByReferencesMigration: AsyncMigration {
        var name: String { "AddUserModifiedByReferences" }

        func prepare(on database: Database) async throws {
            try await database.transaction { db in
                try await db.schema(schema)
                    .field("created_by_id", .uuid, .references(schema, "id", onDelete: .restrict, onUpdate: .cascade))
                    .field("updated_by_id", .uuid, .references(schema, "id", onDelete: .restrict, onUpdate: .cascade))
                    .field("deleted_by_id", .uuid, .references(schema, "id", onDelete: .restrict, onUpdate: .cascade))
                    .update()

                let system = try await system(on: db)
                system.$createdBy.id = try system.requireID()
                try await system.update(on: db, by: system)

                if let sql = db as? SQLDatabase {
                    try await sql.raw(.init("""
                    ALTER TABLE \(schema)
                    ALTER COLUMN created_by_id SET NOT NULL,
                    ALTER COLUMN updated_by_id SET NOT NULL
                    """)).run()
                }
            }
        }

        func revert(on database: Database) async throws {
            try await database.schema(schema)
                .deleteField("created_by_id")
                .deleteField("updated_by_id")
                .deleteField("deleted_by_id")
                .update()
        }
    }
}
