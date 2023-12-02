import Fluent
import Vapor

extension User {
    struct EnsureDeletedMiddleware: AsyncMiddleware {
        func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Vapor.Response {
            guard let id: UUID = request.parameters.get("id") else {
                throw Abort(.badRequest, reason: Errors.invalidUserId.rawValue)
            }
            
            guard let user = try await query(on: request.db)
                .withDeleted()
                .field(\.$name)
                .filter(\.$id == id)
                .filter(\.$deletedAt != nil)
                .first()
            else {
                throw Abort(.notFound, reason: Errors.notExists.rawValue)
            }
            
            if user.isSystem {
                throw Abort(.notFound, reason: Errors.notExists.rawValue)
            }
            
            return try await next.respond(to: request)
        }
    }
}
