import Fluent
import Vapor

extension User {
    struct EnsureDeletedMiddleware: AsyncMiddleware {
        func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Vapor.Response {
            guard let id: UUID = request.parameters.get("id") else {
                throw Abort(.badRequest, reason: "invalid user id")
            }
            
            guard let user = try await User.query(on: request.db)
                .withDeleted()
                .field(\.$name)
                .filter(\.$id == id)
                .filter(\.$deletedAt != nil)
                .first()
            else {
                throw Abort(.notFound)
            }
            
            if user.isSystem {
                throw Abort(.notFound)
            }
            
            return try await next.respond(to: request)
        }
    }
}
