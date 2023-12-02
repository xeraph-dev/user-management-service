import Fluent
import Vapor

extension Service {
    struct EnsureDeletedMiddleware: AsyncMiddleware {
        func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Vapor.Response {
            guard let id: UUID = request.parameters.get("id") else {
                throw Abort(.badRequest, reason: "invalid service id")
            }
            
            guard let service = try await Service.query(on: request.db)
                .withDeleted()
                .field(\.$name)
                .filter(\.$id == id)
                .filter(\.$deletedAt != nil)
                .first()
            else {
                throw Abort(.notFound)
            }
            
            if service.isSystem {
                throw Abort(.notFound)
            }
            
            return try await next.respond(to: request)
        }
    }
}
