import Fluent
import Vapor

extension User {
    struct Update: Content {
        var name: String?
        var email: String?
    }

    func update(on db: Database, by: User, update: Update) async throws {
        if let name = update.name {
            self.name = name
        }
        if let email = update.email {
            self.email = email
        }
        try await self.update(on: db, by: by)
    }
}

extension User.Update: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String?.self, is: .nil || !.empty, required: false)
        validations.add("email", as: String?.self, is: .nil || .email, required: false)
    }
}
