import Fluent
import Vapor

extension User {
    struct Controller: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let users = routes.grouped(EnsureAdminMiddleware()).grouped("users")
            users.get(use: index)
            users.post(use: create)

            let user = users.grouped(EnsureMiddleware()).grouped(":user_id")
            user.get(use: show)
            user.patch(use: update)
            user.delete(use: delete)

            try users.register(collection: DeletedController())
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
            guard create.password == create.confirmPassword else {
                throw Abort(.badRequest)
            }

            let user = try create.user()
            if try await user.exists(on: req.db) {
                throw Abort(.conflict)
            }

            try await user.create(on: req.db, by: req.admin)
            return try user.response()
        }

        func show(req: Request) async throws -> Response {
            try req.user.response()
        }

        func update(req: Request) async throws {
            try Update.validate(content: req)

            let update = try req.content.decode(Update.self)
            guard update.password == update.confirmPassword else {
                throw Abort(.badRequest)
            }

            try await req.user.update(on: req.db, by: req.admin, update: update)
        }

        func delete(req: Request) async throws {
            try await req.user.delete(on: req.db, by: req.admin)
        }
    }
}
