import Fluent
import Vapor

extension User {
    struct Update: Content {
        var name: String?
        var email: String?
        var password: String?
        var confirmPassword: String?
        var roleId: UUID?
    }

    func update(on db: Database, by: User, update: Update) async throws {
        if let name = update.name {
            self.name = name
        }
        if let email = update.email {
            self.email = email
        }
        if let password = update.password {
            self.password = password
        }
        if let roleId = update.roleId {
            self.$role.id = roleId
        }
        try await self.update(on: db, by: by)
    }
}

extension User.Update: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String?.self, is: .nil || !.empty, required: false)
        validations.add("email", as: String?.self, is: .nil || .email, required: false)
        validations.add("password", as: String?.self, is: .nil || .count(8...), required: false)
        validations.add("confirmPassword", as: String?.self, is: .nil || !.empty, required: false)
        validations.add("roleId", as: UUID?.self, required: false)
    }
}
