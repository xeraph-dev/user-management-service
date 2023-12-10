import Fluent
import Vapor

extension Service {
    struct Controller: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let services = routes.grouped(App.User.EnsureAdminMiddleware()).grouped("services")
            services.grouped(App.User.EnsureSuperAdminMiddleware()).get(use: index)
            services.post(use: create)

            let service = services.grouped(EnsureMiddleware()).grouped(":service_id")
            service.get(use: show)
            service.patch(use: update)
            service.delete(use: delete)

            try services.register(collection: DeletedController())
            try service.register(collection: User.Controller())
            try service.register(collection: RoleController())
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

            let service = try create.service()
            if try await service.exists(on: req.db) {
                throw Abort(.conflict)
            }
            try await service.create(on: req.db, by: req.admin)
            return try service.response()
        }

        func show(req: Request) async throws -> Response {
            try req.service.response()
        }

        func update(req: Request) async throws {
            try Update.validate(content: req)
            let update = try req.content.decode(Update.self)
            try await req.service.update(on: req.db, by: req.admin, update: update)
        }

        func delete(req: Request) async throws {
            try await req.service.delete(on: req.db, by: req.admin)
        }
    }
}
