import Fluent
import Vapor

final class Role: Model {
    struct StorageKey: Vapor.StorageKey {
        typealias Value = Role
    }

    static let schema = "roles"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Parent(key: "service_id")
    var service: Service

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    @Parent(key: "created_by_id")
    var createdBy: User

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    @Parent(key: "updated_by_id")
    var updatedBy: User

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    @OptionalParent(key: "deleted_by_id")
    var deletedBy: User?

    var isSystem: Bool {
        name == "system"
    }

    init() {}

    init(id: UUID? = nil, name: String, service: Service) throws {
        self.id = id
        self.name = name
        $service.id = try service.requireID()
    }

    func exists(on db: Database) async throws -> Bool {
        try await Role.query(on: db)
            .field(\.$id)
            .filter(\.$name == name)
            .filter(\.$service.$id == service.requireID())
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
        try await delete(on: db)
    }

    func restore(on db: Database, by: User) async throws {
        $deletedBy.id = nil
        try await update(on: db)
        try await restore(on: db)
    }

    static func system(on db: Database) async throws -> Role {
        guard let system = try await Role.query(on: db)
            .field(\.$id)
            .filter(\.$name == "system")
            .first()
        else {
            throw Errors.systemNotExist
        }

        return system
    }
}

extension Role {
    enum Errors: Error, CustomStringConvertible {
        case systemNotExist

        var description: String {
            switch self {
            case .systemNotExist: "System role does not exist"
            }
        }
    }
}
