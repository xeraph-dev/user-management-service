import Fluent
import Vapor

extension User {
    struct DeletedController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let users = routes.grouped("deleted")
            users.get(use: index)

            let user = users.grouped(EnsureMiddleware(deleted: true)).grouped(":user_id")
            user.get(use: show)
            user.post(use: restore)
            user.delete(use: destroy)
        }

        func index(req: Request) async throws -> [Response] {
            try await query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .all()
                .map { try $0.response() }
        }

        func show(req: Request) async throws -> Response {
            try req.user.response()
        }

        func restore(req: Request) async throws {
            try await req.user.restore(on: req.db, by: req.admin)
        }

        func destroy(req: Request) async throws {
            try await req.user.delete(force: true, on: req.db, by: req.admin)
        }
    }
}
