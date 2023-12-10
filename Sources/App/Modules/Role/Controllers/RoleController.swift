import Fluent
import Vapor

extension Role {
    struct Controller: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let roles = routes.grouped(User.EnsureSuperAdminMiddleware()).grouped("roles")
            roles.get(use: index)

            let role = roles.grouped(EnsureMiddleware()).grouped(":role_id")
            role.get(use: show)
            role.delete(use: delete)

            try roles.register(collection: DeletedController())
        }

        func index(req: Request) async throws -> [Response] {
            try await query(on: req.db)
                .filter(\.$name != "system")
                .with(\.$service)
                .all()
                .map { try $0.response() }
        }

        func show(req: Request) async throws -> Response {
            try await req.role.$service.load(on: req.db)
            return try req.role.response()
        }

        func delete(req: Request) async throws {
            try await req.role.delete(on: req.db, by: req.admin)
        }
    }
}
