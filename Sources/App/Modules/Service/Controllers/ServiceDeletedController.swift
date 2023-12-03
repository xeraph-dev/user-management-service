import Fluent
import Vapor

extension Service {
    struct DeletedController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let services = routes.grouped("deleted")
            services.get(use: index)
            
            let service = services.grouped(EnsureMiddleware(deleted: true)).grouped(":service_id")
            service.get(use: show)
            service.post(use: restore)
            service.delete(use: destroy)
        }

        func index(req: Request) async throws -> [Response] {
            try await query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .all()
                .map { try $0.response() }
        }
        
        func show(req: Request) async throws -> Response {
            try req.service.response()
        }
        
        func restore(req: Request) async throws {
            try await req.service.restore(on: req.db, by: req.admin)
        }
        
        func destroy(req: Request) async throws {
            try await req.service.delete(force: true, on: req.db, by: req.admin)
        }
    }
}
