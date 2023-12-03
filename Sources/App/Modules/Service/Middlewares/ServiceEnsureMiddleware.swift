import Fluent
import Vapor

extension Service {
    struct EnsureMiddleware: AsyncMiddleware {
        let deleted: Bool

        init(deleted: Bool = false) {
            self.deleted = deleted
        }

        func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Vapor.Response {
            guard let id: UUID = request.parameters.get("service_id") else {
                throw Abort(.badRequest)
            }

            let builder = query(on: request.db).filter(\.$id == id)
            let builderDeleted = builder.copy().withDeleted().filter(\.$deletedAt != nil)

            let service = try await !deleted ? builder.first() : builderDeleted.first()
            guard let service = service, !service.isSystem else {
                throw Abort(.notFound)
            }

            request.service = service

            return try await next.respond(to: request)
        }
    }
}
