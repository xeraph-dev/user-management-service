import Fluent
import Vapor

extension Role {
    struct DeletedController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let roles = routes.grouped("deleted")
            roles.get(use: index)
            
            let role = roles.grouped(Role.EnsureDeletedMiddleware()).grouped(":id")
            role.get(use: show)
            role.post(use: restore)
            role.delete(use: destroy)
        }

        func index(req: Request) async throws -> [Role.Response] {
            try await Role.query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .all()
                .map { try $0.response() }
        }
        
        func show(req: Request) async throws -> Role.Response {
            return try await Role.query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .filter(\.$id == req.parameters.get("id")!)
                .first()!
                .response()
        }
        
        func restore(req: Request) async throws -> HTTPStatus {
            try await Role.query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .filter(\.$id == req.parameters.get("id")!)
                .first()!
                .restore(on: req.db, by: User.system(on: req.db))
            return .noContent
        }
        
        func destroy(req: Request) async throws -> HTTPStatus {
            try await Role.query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .filter(\.$id == req.parameters.get("id")!)
                .first()!
                .delete(force: true, on: req.db)
            return .noContent
        }
    }
}
