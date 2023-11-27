import Vapor

extension User {
    struct Response: Content {
        let id: UUID
        let name: String
        let email: String
        let role: Role.Response?

        init(id: UUID, name: String, email: String, role: Role.Response?) {
            self.id = id
            self.name = name
            self.email = email
            self.role = role
        }
    }

    func response() throws -> User.Response {
        try Response(
            id: self.requireID(),
            name: self.name,
            email: self.email,
            role: self.$role.value?.response()
        )
    }
}
