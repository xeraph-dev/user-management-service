import Vapor

extension User {
    struct Response: Content {
        let id: UUID
        let name: String
        let email: String

        init(id: UUID, name: String, email: String) {
            self.id = id
            self.name = name
            self.email = email
        }
    }

    func response() throws -> Response {
        let id = try self.requireID()
        return Response(
            id: id,
            name: self.name,
            email: self.email
        )
    }
}
