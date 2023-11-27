import Fluent
import Vapor

extension User {
    struct Controller: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let users = routes.grouped("users")
            users.get(use: index)
            users.post(use: create)

            let user = users.grouped(User.EnsureExistsMiddleware()).grouped(":id")
            user.get(use: show)
            user.patch(use: update)
            user.delete(use: delete)

            try users.register(collection: User.DeletedController())
        }

        func index(req: Request) async throws -> [User.Response] {
            try await User.query(on: req.db)
                .filter(\.$name != "system")
                .all()
                .map { try $0.response() }
        }

        func create(req: Request) async throws -> User.Response {
            try User.Create.validate(content: req)

            let create = try req.content.decode(User.Create.self)
            guard create.password == create.confirmPassword else {
                throw Abort(.badRequest, reason: "passwords did not match")
            }

            let user = try create.user()
            if try await user.exists(on: req.db) {
                throw Abort(.conflict, reason: "user already exists")
            }
            try await user.create(on: req.db, by: User.system(on: req.db))
            return try user.response()
        }

        func show(req: Request) async throws -> User.Response {
            try await User.find(req.parameters.get("id"), on: req.db)!.response()
        }

        func update(req: Request) async throws -> HTTPStatus {
            try User.Update.validate(content: req)

            let update = try req.content.decode(User.Update.self)
            guard update.password == update.confirmPassword else {
                throw Abort(.badRequest, reason: "passwords did not match")
            }

            try await User.find(req.parameters.get("id"), on: req.db)!
                .update(on: req.db, by: User.system(on: req.db), update: update)
            return .noContent
        }

        func delete(req: Request) async throws -> HTTPStatus {
            try await User.find(req.parameters.get("id"), on: req.db)!
                .delete(on: req.db, by: User.system(on: req.db))
            return .noContent
        }
    }
}
