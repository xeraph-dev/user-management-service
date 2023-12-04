import Fluent
import Vapor

extension Role {
    struct DeletedController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let roles = routes.grouped("deleted")
            roles.get(use: index)

            let role = roles.grouped(EnsureMiddleware(deleted: true)).grouped(":role_id")
            role.get(use: show)
            role.post(use: restore)
            role.delete(use: destroy)
        }

        func index(req: Request) async throws -> [Response] {
            try await query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .all()
                .map { try $0.response() }
        }

        func show(req: Request) async throws -> Response {
            try req.role.response()
        }

        func restore(req: Request) async throws {
            try await req.role.restore(on: req.db, by: req.admin)
        }

        func destroy(req: Request) async throws {
            try await req.role.delete(force: true, on: req.db, by: req.admin)
        }
    }
}
