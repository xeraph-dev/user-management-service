import Fluent
import Vapor

extension User {
    struct EnsureMiddleware: AsyncMiddleware {
        let deleted: Bool

        init(deleted: Bool = false) {
            self.deleted = deleted
        }

        func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Vapor.Response {
            guard let id: UUID = request.parameters.get("user_id") else {
                throw Abort(.badRequest)
            }

            let builder = query(on: request.db).filter(\.$id == id)
            let builderDeleted = builder.copy().withDeleted().filter(\.$deletedAt != nil)

            let user = try await !deleted ? builder.first() : builderDeleted.first()
            guard let user = user, !user.isSystem else {
                throw Abort(.notFound)
            }

            request.user = user

            return try await next.respond(to: request)
        }
    }
}
