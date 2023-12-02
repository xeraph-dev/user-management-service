import Vapor

extension Service {
    struct Response: Content {
        let id: UUID
        let name: String
    }

    func response() throws -> Service.Response {
        try Service.Response(id: self.requireID(), name: self.name)
    }
}
