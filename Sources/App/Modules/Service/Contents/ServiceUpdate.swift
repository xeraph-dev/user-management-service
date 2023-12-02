import Fluent
import Vapor

extension Service {
    struct Update: Content {
        var name: String?
    }

    func update(on db: Database, by: App.User, update: Update) async throws {
        if let name = update.name {
            self.name = name
        }
        try await self.update(on: db, by: by)
    }
}

extension Service.Update: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String?.self, is: .nil || !.empty, required: false)
    }
}
