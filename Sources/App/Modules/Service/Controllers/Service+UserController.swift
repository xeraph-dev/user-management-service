import Fluent
import Vapor

extension Service.User {
    struct Controller: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let users = routes.grouped(User.EnsureAdminMiddleware()).grouped("users")
            users.get(use: index)
            users.post(use: create)

            let user = users.grouped(User.EnsureMiddleware()).grouped(":user_id")
            user.delete(use: destroy)

            try users.register(collection: Service.User.DeletedController())
        }

        func index(req: Request) async throws -> [User.Response] {
            try await req.service.$users.get(on: req.db).map { try $0.response() }
        }

        func create(req: Request) async throws -> User.Response {
            try User.Create.validate(content: req)

            let create = try req.content.decode(User.Create.self)

            let user = try create.user()
            if try await user.exists(on: req.db) {
                throw Abort(.conflict)
            }

            try await req.db.transaction { db in
                try await user.create(on: db, by: req.admin)
                try await user.$services.attach(req.service, on: db) { su in
                    su.$createdBy.id = try req.admin.requireID()
                }
            }

            return try user.response()
        }

        func destroy(req: Request) async throws {
            try await req.user.$services.detach(req.service, on: req.db)
        }
    }
}
