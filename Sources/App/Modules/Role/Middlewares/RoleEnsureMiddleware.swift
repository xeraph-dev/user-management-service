import Fluent
import Vapor

extension Role {
    struct EnsureMiddleware: AsyncMiddleware {
        let deleted: Bool
        
        init(deleted: Bool = false) {
            self.deleted = deleted
        }

        func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Vapor.Response {
            let serviceId: Any? = request.parameters.get("service_id")
            guard let roleId: UUID = request.parameters.get("role_id") else {
                throw Abort(.badRequest)
            }
            
            let base = serviceId != nil ? request.service.$roles.query(on: request.db) : Role.query(on: request.db)
            let builder = base.filter(\Role.$id == roleId)
            let builderDeleted = builder.copy().withDeleted().filter(\Role.$deletedAt != nil)
            
            let role = try await !deleted ? builder.first() : builderDeleted.first()
            guard let role = role, !role.isSystem else {
                throw Abort(.notFound)
            }
            
            request.role = role
            
            return try await next.respond(to: request)
        }
    }
}
