import Fluent
import Vapor

extension Service.User {
    struct EnsureMiddleware: AsyncMiddleware {
        func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
            guard let id: UUID = request.parameters.get("user_id") else {
                throw Abort(.badRequest)
            }
            
            let user = try await request.service.$users.query(on: request.db).filter(\.$id == id).first()
            guard let user = user, !user.isSystem else {
                throw Abort(.notFound)
            }
            
            request.user = user
                    
            return try await next.respond(to: request)
        }
    }
}
