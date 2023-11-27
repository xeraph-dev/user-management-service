import Fluent
import Vapor

extension Role {
    struct EnsureExistsMiddleware: AsyncMiddleware {
        func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Vapor.Response {
            guard let id: UUID = request.parameters.get("id") else {
                throw Abort(.badRequest, reason: "invalid role id")
            }
            
            guard let role = try await Role.query(on: request.db).field(\.$name).filter(\.$id == id).first() else {
                guard try await Role.query(on: request.db).withDeleted().filter(\.$id == id).count() == 0 else {
                    throw Abort(.gone)
                }
                
                throw Abort(.notFound)
            }
            
            if role.isSystem {
                throw Abort(.notFound)
            }
            
            return try await next.respond(to: request)
        }
    }
}
