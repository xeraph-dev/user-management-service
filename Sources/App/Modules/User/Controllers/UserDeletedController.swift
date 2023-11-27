import Fluent
import Vapor

extension User {
    struct DeletedController: RouteCollection {
        func boot(routes: RoutesBuilder) throws {
            let users = routes.grouped("deleted")
            users.get(use: index)

            let user = users.grouped(User.EnsureDeletedMiddleware()).grouped(":id")
            user.get(use: show)
            user.post(use: restore)
            user.delete(use: destroy)
        }

        func index(req: Request) async throws -> [User.Response] {
            try await User.query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .all()
                .map { try $0.response() }
        }

        func show(req: Request) async throws -> User.Response {
            return try await User.query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .filter(\.$id == req.parameters.get("id")!)
                .first()!
                .response()
        }

        func restore(req: Request) async throws -> HTTPStatus {
            try await User.query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .filter(\.$id == req.parameters.get("id")!)
                .first()!
                .restore(on: req.db, by: User.system(on: req.db))
            return .noContent
        }

        func destroy(req: Request) async throws -> HTTPStatus {
            try await User.query(on: req.db)
                .withDeleted()
                .filter(\.$deletedAt != nil)
                .filter(\.$id == req.parameters.get("id")!)
                .first()!
                .delete(force: true, on: req.db)
            return .noContent
        }
    }
}
