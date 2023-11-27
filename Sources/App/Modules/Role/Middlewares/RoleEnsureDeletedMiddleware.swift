import Fluent
import Vapor

extension Role {
    struct EnsureDeletedMiddleware: AsyncMiddleware {
        func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Vapor.Response {
            guard let id: UUID = request.parameters.get("id") else {
                throw Abort(.badRequest, reason: "invalid role id")
            }
            
            guard let role = try await Role.query(on: request.db)
                .withDeleted()
                .field(\.$name)
                .filter(\.$id == id)
                .filter(\.$deletedAt != nil)
                .first()
            else {
                throw Abort(.notFound)
            }
            
            if role.isSystem {
                throw Abort(.notFound)
            }
            
            return try await next.respond(to: request)
        }
    }
}
