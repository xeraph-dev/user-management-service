import Fluent
import Vapor

extension Service {
    struct DeletedController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let services = routes.grouped("deleted")
            services.get(use: index)
            
            let service = services.grouped(Service.EnsureDeletedMiddleware()).grouped(":id")
            service.get(use: show)
            service.post(use: restore)
            service.delete(use: destroy)
        }

        func index(req: Request) async throws -> [Service.Response] {
            try await Service.query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .all()
                .map { try $0.response() }
        }
        
        func show(req: Request) async throws -> Service.Response {
            return try await Service.query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .filter(\.$id == req.parameters.get("id")!)
                .first()!
                .response()
        }
        
        func restore(req: Request) async throws -> HTTPStatus {
            try await Service.query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .filter(\.$id == req.parameters.get("id")!)
                .first()!
                .restore(on: req.db, by: App.User.system(on: req.db))
            return .noContent
        }
        
        func destroy(req: Request) async throws -> HTTPStatus {
            try await Service.query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .filter(\.$id == req.parameters.get("id")!)
                .first()!
                .delete(force: true, on: req.db)
            return .noContent
        }
    }
}
