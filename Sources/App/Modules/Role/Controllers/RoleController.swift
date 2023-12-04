import Fluent
import Vapor

extension Role {
    struct Controller: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let roles = routes.grouped(User.EnsureAdminMiddleware()).grouped("roles")
            roles.get(use: index)
            roles.post(use: create)

            let role = roles.grouped(EnsureMiddleware()).grouped(":role_id")
            role.get(use: show)
            role.patch(use: update)
            role.delete(use: delete)

            try roles.register(collection: DeletedController())
        }

        func index(req: Request) async throws -> [Response] {
            try await query(on: req.db)
                .filter(\.$name != "system")
                .all()
                .map { try $0.response() }
        }

        func create(req: Request) async throws -> Response {
            try Create.validate(content: req)

            let create = try req.content.decode(Create.self)

            let role = try create.role()
            if try await role.exists(on: req.db) {
                throw Abort(.conflict)
            }

            try await role.create(on: req.db, by: req.admin)
            return try role.response()
        }

        func show(req: Request) async throws -> Response {
            try req.role.response()
        }

        func update(req: Request) async throws {
            try Update.validate(content: req)
            let update = try req.content.decode(Update.self)
            try await req.role.update(on: req.db, by: req.admin, update: update)
        }

        func delete(req: Request) async throws {
            try await req.role.delete(on: req.db, by: req.admin)
        }
    }
}
