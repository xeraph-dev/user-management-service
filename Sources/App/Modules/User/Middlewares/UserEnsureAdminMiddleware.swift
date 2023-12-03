import Fluent
import Vapor

extension User {
    struct EnsureAdminMiddleware: AsyncMiddleware {
        func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Vapor.Response {
            request.admin = try await User.system(on: request.db)
            return try await next.respond(to: request)
        }
    }
}
