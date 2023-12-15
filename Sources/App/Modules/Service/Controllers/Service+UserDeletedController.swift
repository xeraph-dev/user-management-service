import Fluent
import Vapor

extension Service.User {
    struct DeletedController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let users = routes.grouped("deleted")
            users.get(use: index)

            let user = users.grouped(User.EnsureMiddleware(deleted: true)).grouped(":user_id")
        }

        func index(req: Request) async throws -> [User.Response] {
            try await req.service.$users.query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .sort(\.$deletedAt, .descending)
                .all()
                .map { try $0.response() }
        }
    }
}
