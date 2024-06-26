import Vapor

extension Role {
    struct Response: Content, Equatable {
        let id: UUID
        let name: String
    }

    func response() throws -> Role.Response {
        try Role.Response(id: requireID(), name: name)
    }
}
