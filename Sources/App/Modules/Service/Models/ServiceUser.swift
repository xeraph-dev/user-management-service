import Fluent

extension Service {
    final class User: Model {
        enum Errors: Error, CustomStringConvertible {
            case notExists(String, String)

            var description: String {
                switch self {
                case .notExists(let service, let user): "The user '\(user)' is not registered in the service '\(service)'"
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
    }
}
