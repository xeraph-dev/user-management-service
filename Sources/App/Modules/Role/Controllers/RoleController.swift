import Fluent
import Vapor

extension Role {
    struct Controller: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let roles = routes.grouped("roles")
            roles.get(use: index)
            roles.post(use: create)

            let role = roles.grouped(Role.EnsureExistsMiddleware()).grouped(":id")
            role.get(use: show)
            role.patch(use: update)
            role.delete(use: delete)

            try roles.register(collection: Role.DeletedController())
        }

        func index(req: Request) async throws -> [Role.Response] {
            try await Role.query(on: req.db)
                .filter(\.$name != "system")
                .all()
                .map { try $0.response() }
        }

        func create(req: Request) async throws -> Role.Response {
            try Role.Create.validate(content: req)

            let create = try req.content.decode(Role.Create.self)

            let role = try create.role()
            if try await role.exists(on: req.db) {
                throw Abort(.conflict, reason: "role already exists")
            }
            try await role.create(on: req.db, by: User.system(on: req.db))
            return try role.response()
        }

        func show(req: Request) async throws -> Role.Response {
            try await Role.find(req.parameters.get("id"), on: req.db)!.response()
        }

        func update(req: Request) async throws -> HTTPStatus {
            try Role.Update.validate(content: req)

            let update = try req.content.decode(Role.Update.self)

            try await Role.find(req.parameters.get("id"), on: req.db)!
                .update(on: req.db, by: User.system(on: req.db), update: update)
            return .noContent
        }

        func delete(req: Request) async throws -> HTTPStatus {
            try await Role.find(req.parameters.get("id"), on: req.db)!
                .delete(on: req.db, by: User.system(on: req.db))
            return .noContent
        }
    }
}
