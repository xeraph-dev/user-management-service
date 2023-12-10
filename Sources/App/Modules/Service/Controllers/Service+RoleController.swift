import Fluent
import Vapor

extension Service {
    struct RoleController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let roles = routes.grouped("roles")
            roles.get(use: index)
            roles.post(use: create)

            let role = roles.grouped(Role.EnsureMiddleware()).grouped(":role_id")
            role.get(use: show)
            role.patch(use: update)
            role.delete(use: delete)

            try roles.register(collection: RoleDeletedController())
        }

        func index(req: Request) async throws -> [Role.Response] {
            try await req.service.$roles.query(on: req.db)
                .filter(\.$name != "system")
                .all()
                .map { try $0.response() }
        }

        func create(req: Request) async throws -> Role.Response {
            try Role.Create.validate(content: req)
            let create = try req.content.decode(Role.Create.self)
            let role = try create.role(service: req.service)
            if try await role.exists(on: req.db) {
                throw Abort(.conflict)
            }

            try await role.create(on: req.db, by: req.admin)
            return try role.response()
        }

        func show(req: Request) async throws -> Role.Response {
            try req.role.response()
        }

        func update(req: Request) async throws {
            try Role.Update.validate(content: req)
            let update = try req.content.decode(Role.Update.self)
            try await req.role.update(on: req.db, by: req.admin, update: update)
        }

        func delete(req: Request) async throws {
            try await req.role.delete(on: req.db, by: req.admin)
        }
    }
}
