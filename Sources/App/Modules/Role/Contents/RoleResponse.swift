import Vapor

extension Role {
    struct Response: Content {
        let id: UUID
        let name: String

        init(id: UUID, name: String) {
            self.id = id
            self.name = name
        }
    }

    func response() throws -> Role.Response {
        try Role.Response(id: self.requireID(), name: self.name)
    }
}
