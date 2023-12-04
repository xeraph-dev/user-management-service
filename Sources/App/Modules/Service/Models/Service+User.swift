import Fluent

extension Service {
    final class User: Model {
        enum Errors: Error, CustomStringConvertible {
            case notExists(String, String)
            case systemNotExists

            var description: String {
                switch self {
                case .notExists(let service, let user): "The user '\(user)' is not registered in the service '\(service)'"
                case .systemNotExists: "The system user is not registered in the system service"
                }
            }
        }

        static let schema = "\(Service.schema)+\(App.User.schema)"

        @ID(key: .id)
        var id: UUID?

        @Parent(key: "service_id")
        var service: Service

        @Parent(key: "user_id")
        var user: App.User

        @Timestamp(key: "created_at", on: .create)
        var createdAt: Date?
        @Parent(key: "created_by_id")
        var createdBy: App.User

        func create(on db: Database, by: App.User) async throws {
            $createdBy.id = try by.requireID()
            try await create(on: db)
        }

        static func system(on db: Database) async throws -> Service.User {
            guard let system = try await Service.User.query(on: db)
                .field(\.$id).field(Service.self, \.$id).field(App.User.self, \.$id)
                .join(Service.self, on: \Service.User.$service.$id == \Service.$id)
                .join(App.User.self, on: \Service.User.$user.$id == \App.User.$id)
                .filter(Service.self, \.$name == "system")
                .filter(App.User.self, \.$name == "system")
                .first()
            else {
                throw Errors.systemNotExists
            }

            return system
        }
    }
}
