import Fluent
import Vapor

final class User: Model {
    enum Errors: String, Error {
        case systemNotExist = "System user does not exist"
        case passwordNotMatch = "Passwords did not match"
        case alreadyExists = "User already exists"
        case notExists = "User does not exists"
        case invalidUserId = "Invaid user id"
    }

    struct StorageKey: Vapor.StorageKey {
        typealias Value = User
    }

    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "password")
    var password: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?

    @Parent(key: "created_by_id")
    var createdBy: User
    @Parent(key: "updated_by_id")
    var updatedBy: User
    @OptionalParent(key: "deleted_by_id")
    var deletedBy: User?

    @Children(for: \.$createdBy)
    var usersCreated: [User]
    @Children(for: \.$updatedBy)
    var usersUpdated: [User]
    @Children(for: \.$deletedBy)
    var usersDeleted: [User]

    @Siblings(through: Service.User.self, from: \.$user, to: \.$service)
    var services: [Service]

    var isSystem: Bool {
        name == "system"
    }

    init() {}

    init(id: UUID? = nil, name: String, email: String, password: String) {
        self.id = id
        self.name = name
        self.email = email
        self.password = password
    }

    func exists(on db: Database) async throws -> Bool {
        try await User.query(on: db)
            .field(\.$id)
            .filter(\.$name == name)
            .count() > 0
    }

    func create(on db: Database, by: User) async throws {
        $createdBy.id = try by.requireID()
        $updatedBy.id = try by.requireID()
        try await create(on: db)
    }

    func update(on db: Database, by: User) async throws {
        $updatedBy.id = try by.requireID()
        try await update(on: db)
    }

    func delete(force: Bool = false, on db: Database, by: User) async throws {
        if !force {
            $deletedBy.id = try by.requireID()
            try await update(on: db)
        }
        try await delete(force: force, on: db)
    }

    func restore(on db: Database, by: User) async throws {
        $deletedBy.id = nil
        try await update(on: db)
        try await restore(on: db)
    }

    static func system(on db: Database) async throws -> User {
        guard let system = try await User.query(on: db)
            .field(\.$id)
            .filter(\.$name == "system")
            .first()
        else {
            throw Errors.systemNotExist
        }

        return system
    }
}
