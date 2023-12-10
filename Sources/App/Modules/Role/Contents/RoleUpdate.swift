import Fluent
import Vapor

extension Role {
    struct Update: Content {
        var name: String?
    }

    func update(on db: Database, by: User, update: Update) async throws {
        self.name = update.name ?? self.name
        try await self.update(on: db, by: by)
    }
}

extension Role.Update: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String?.self, is: .nil || !.empty, required: false)
    }
}
