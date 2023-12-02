import Fluent

final class Service: Model {
    static let schema = "services"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    @Parent(key: "created_by_id")
    var createdBy: App.User

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?
    @Parent(key: "updated_by_id")
    var updatedBy: App.User

    @Timestamp(key: "deleted_at", on: .delete)
    var deletedAt: Date?
    @OptionalParent(key: "deleted_by_id")
    var deletedBy: App.User?

    var isSystem: Bool {
        name == "system"
    }

    init() {}

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }

    func exists(on db: Database) async throws -> Bool {
        try await Service.query(on: db)
            .field(\.$id)
            .filter(\.$name == name)
            .count() > 0
    }

    func create(on db: Database, by: App.User) async throws {
        $createdBy.id = try by.requireID()
        $updatedBy.id = try by.requireID()
        try await create(on: db)
    }

    func update(on db: Database, by: App.User) async throws {
        $updatedBy.id = try by.requireID()
        try await update(on: db)
    }

    func delete(force: Bool = false, on db: Database, by: App.User) async throws {
        if !force {
            $deletedBy.id = try by.requireID()
            try await update(on: db)
        }
        try await delete(force: force, on: db)
    }

    func restore(on db: Database, by: App.User) async throws {
        $deletedBy.id = nil
        try await update(on: db)
        try await restore(on: db)
    }

    static func system(on db: Database) async throws -> Self {
        try await query(on: db)
            .filter(\.$name == "system")
            .first()!
    }
}

extension Service {
    enum Errors: Error, CustomStringConvertible {
        case systemNotExist
        case alreadyExists

        var description: String {
            switch self {
            case .systemNotExist: "System service does not exist"
            case .alreadyExists: "Service already exists"
            }
        }
    }
}
