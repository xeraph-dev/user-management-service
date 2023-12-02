import Fluent
import Vapor

extension User {
    struct Controller: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let users = routes.grouped("users")
            users.get(use: index)
            users.post(use: create)

            let user = users.grouped(EnsureExistsMiddleware()).grouped(":id")
            user.get(use: show)
            user.patch(use: update)
            user.delete(use: delete)

            try users.register(collection: DeletedController())
        }

        func index(req: Request) async throws -> [Response] {
            try await query(on: req.db)
                .filter(\.$name != Names.system.rawValue)
                .all()
                .map { try $0.response() }
        }

        func create(req: Request) async throws -> Response {
            try Create.validate(content: req)

            let create = try req.content.decode(Create.self)
            guard create.password == create.confirmPassword else {
                throw Abort(.badRequest, reason: Errors.passwordNotMatch.rawValue)
            }

            let user = try create.user()
            if try await user.exists(on: req.db) {
                throw Abort(.conflict, reason: Errors.alreadyExists.rawValue)
            }

            let system = try await system(on: req.db)
            try await user.create(on: req.db, by: system)
            return try user.response()
        }

        func show(req: Request) async throws -> Response {
            let id: UUID = req.parameters.get("id")!
            return try await find(id, on: req.db)!.response()
        }

        func update(req: Request) async throws -> HTTPStatus {
            try Update.validate(content: req)

            let update = try req.content.decode(Update.self)
            guard update.password == update.confirmPassword else {
                throw Abort(.badRequest, reason: Errors.passwordNotMatch.rawValue)
            }

            let id: UUID = req.parameters.get("id")!
            let system = try await system(on: req.db)
            try await find(id, on: req.db)!.update(on: req.db, by: system, update: update)
            return .noContent
        }

        func delete(req: Request) async throws -> HTTPStatus {
            let id: UUID = req.parameters.get("id")!
            let system = try await system(on: req.db)
            try await find(id, on: req.db)!.delete(on: req.db, by: system)
            return .noContent
        }
    }
}
