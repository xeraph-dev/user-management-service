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
        try Response(
            id: self.requireID(),
            name: self.name,
            email: self.email
        )
    }
}
