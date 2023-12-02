import Fluent
import Vapor

extension Service {
    struct Controller: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let services = routes.grouped("services")
            services.get(use: index)
            services.post(use: create)

            let service = services.grouped(Service.EnsureExistsMiddleware()).grouped(":id")
            service.get(use: show)
            service.patch(use: update)
            service.delete(use: delete)

            try services.register(collection: Service.DeletedController())
        }

        func index(req: Request) async throws -> [Service.Response] {
            try await Service.query(on: req.db)
                .filter(\.$name != "system")
                .all()
                .map { try $0.response() }
        }

        func create(req: Request) async throws -> Service.Response {
            try Service.Create.validate(content: req)

            let create = try req.content.decode(Service.Create.self)

            let service = try create.service()
            if try await service.exists(on: req.db) {
                throw Abort(.conflict, reason: "service already exists")
            }
            try await service.create(on: req.db, by: App.User.system(on: req.db))
            return try service.response()
        }

        func show(req: Request) async throws -> Service.Response {
            try await Service.find(req.parameters.get("id"), on: req.db)!.response()
        }

        func update(req: Request) async throws -> HTTPStatus {
            try Service.Update.validate(content: req)

            let update = try req.content.decode(Service.Update.self)

            try await Service.find(req.parameters.get("id"), on: req.db)!
                .update(on: req.db, by: App.User.system(on: req.db), update: update)
            return .noContent
        }

        func delete(req: Request) async throws -> HTTPStatus {
            try await Service.find(req.parameters.get("id"), on: req.db)!
                .delete(on: req.db, by: App.User.system(on: req.db))
            return .noContent
        }
    }
}
