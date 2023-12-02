import Fluent
import Vapor

extension User {
    struct DeletedController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let users = routes.grouped("deleted")
            users.get(use: index)

            let user = users.grouped(EnsureDeletedMiddleware()).grouped(":id")
            user.get(use: show)
            user.post(use: restore)
            user.delete(use: destroy)
        }

        func index(req: Request) async throws -> [Response] {
            try await query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .all()
                .map { try $0.response() }
        }

        func show(req: Request) async throws -> Response {
            let id: UUID = req.parameters.get("id")!
            return try await query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .filter(\.$id == id)
                .first()!
                .response()
        }

        func restore(req: Request) async throws -> HTTPStatus {
            let id: UUID = req.parameters.get("id")!
            let system = try await system(on: req.db)
            try await query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .filter(\.$id == id)
                .first()!
                .restore(on: req.db, by: system)
            return .noContent
        }

        func destroy(req: Request) async throws -> HTTPStatus {
            let id: UUID = req.parameters.get("id")!
            try await query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .filter(\.$id == id)
                .first()!
                .delete(force: true, on: req.db)
            return .noContent
        }
    }
}
