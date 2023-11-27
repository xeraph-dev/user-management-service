import Fluent
import Vapor

final class User: Model {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "password")
    var password: String

    @Parent(key: "role_id")
    var role: Role

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    @Parent(key: "created_by_id")
    var createdBy: User
    @Children(for: \.$createdBy)
    var usersCreated: [User]

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    @Parent(key: "updated_by_id")
    var updatedBy: User
    @Children(for: \.$updatedBy)
    var usersUpdated: [User]

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    @OptionalParent(key: "deleted_by_id")
    var deletedBy: User?
    @Children(for: \.$deletedBy)
    var usersDeleted: [User]

    var isSystem: Bool {
        name == "system"
    }

    init() {}

    init(id: UUID? = nil, name: String, email: String, password: String, role: Role) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
        self.$role.id = role.id!
    }

    func exists(on db: Database) async throws -> Bool {
        try await User.query(on: db)
            .field(\.$id)
            .filter(\.$name == name)
            .count() > 0
    }

    func create(on db: Database, by: User) async throws {
        $createdBy.id = by.id!
        $updatedBy.id = by.id!
        try await create(on: db)
    }

    func update(on db: Database, by: User) async throws {
        $updatedBy.id = by.id!
        try await update(on: db)
    }

    func delete(on db: Database, by: User) async throws {
        $deletedBy.id = by.id
        try await update(on: db)
        try await delete(on: db)
    }

    func restore(on db: Database, by: User) async throws {
        $deletedBy.id = nil
        try await update(on: db)
        try await restore(on: db)
    }

    static func system(on db: Database) async throws -> Self {
        try await query(on: db)
            .join(Role.self, on: \User.$role.$id == \Role.$id)
            .filter(User.self, \.$name == "system")
            .filter(Role.self, \.$name == "system")
            .first()!
    }
}
