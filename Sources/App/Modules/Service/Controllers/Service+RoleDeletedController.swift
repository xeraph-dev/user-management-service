import Fluent
import Vapor

extension Service {
    struct RoleDeletedController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let roles = routes.grouped("deleted")
            roles.get(use: index)

            let role = roles.grouped(Role.EnsureMiddleware(deleted: true)).grouped(":role_id")
            role.get(use: show)
            role.post(use: restore)
            role.delete(use: destroy)
        }

        func index(req: Request) async throws -> [Role.Response] {
            try await req.service.$roles.query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .all()
                .map { try $0.response() }
        }

        func show(req: Request) async throws -> Role.Response {
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
